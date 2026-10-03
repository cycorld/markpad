import AppKit
import Foundation
import Sparkle
import SwiftUI

/// Observable model that tracks Sparkle's update state for SwiftUI menus and settings.
final class SparkleUpdaterViewModel: ObservableObject {
    @Published var canCheckForUpdates = false

    init(updater: SPUUpdater) {
        updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }
}

/// Menu button for checking for updates.
struct CheckForUpdatesView: View {
    @ObservedObject private var model: SparkleUpdaterViewModel
    private let updater: SPUUpdater

    init(updater: SPUUpdater) {
        self.updater = updater
        self.model = SparkleUpdaterViewModel(updater: updater)
    }

    var body: some View {
        Button("Check for Updates…", action: updater.checkForUpdates)
            .disabled(!model.canCheckForUpdates)
    }
}

/// Settings → Updates panel powered by Sparkle.
struct SparkleSettingsView: View {
    private let updater: SPUUpdater
    @State private var automaticallyChecksForUpdates: Bool
    @State private var automaticallyDownloadsUpdates: Bool

    init(updater: SPUUpdater) {
        self.updater = updater
        self._automaticallyChecksForUpdates = State(initialValue: updater.automaticallyChecksForUpdates)
        self._automaticallyDownloadsUpdates = State(initialValue: updater.automaticallyDownloadsUpdates)
    }

    var body: some View {
        Form {
            Section("Automatic Updates") {
                Toggle("Automatically check for updates", isOn: $automaticallyChecksForUpdates)
                    .onChange(of: automaticallyChecksForUpdates) { newValue in
                        updater.automaticallyChecksForUpdates = newValue
                    }

                Toggle("Automatically download and install updates", isOn: $automaticallyDownloadsUpdates)
                    .disabled(!automaticallyChecksForUpdates)
                    .onChange(of: automaticallyDownloadsUpdates) { newValue in
                        updater.automaticallyDownloadsUpdates = newValue
                    }
            }

            Section("Status") {
                LabeledContent("Current Version", value: "\(versionString) (Build \(buildString))")

                HStack {
                    Spacer()
                    Button("Check for Updates Now…") {
                        updater.checkForUpdates()
                    }
                }
                .padding(.top, 4)
            }
        }
        .formStyle(.grouped)
        .frame(width: 480)
        .navigationTitle("Updates")
    }

    private var versionString: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }

    private var buildString: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
}
