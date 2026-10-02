import SwiftUI

/// Settings → Updates: current version info, automatic check toggle, and manual check button.
struct UpdateSettingsView: View {
    @ObservedObject private var checker = UpdateChecker.shared
    @AppStorage(UpdateChecker.DefaultsKey.automaticallyCheck)
    private var automaticallyCheck = true

    var body: some View {
        Form {
            Section("Current Version") {
                LabeledContent("MarkPad", value: "\(checker.currentVersionString) (\(checker.currentBuildString))")
                LabeledContent("Update Source", value: "GitHub Releases (\(UpdateChecker.repoOwner)/\(UpdateChecker.repoName))")
            }

            Section("Automatic Updates") {
                Toggle("Automatically check for updates", isOn: $automaticallyCheck)
                if let lastDate = checker.lastCheckedDate {
                    LabeledContent("Last checked", value: lastDate.formatted(date: .abbreviated, time: .shortened))
                } else {
                    LabeledContent("Last checked", value: "Never")
                }
            }

            Section {
                HStack {
                    Button(checker.isChecking ? "Checking…" : "Check for Updates Now") {
                        checker.checkForUpdates(explicit: true)
                    }
                    .disabled(checker.isChecking)

                    if checker.isChecking {
                        ProgressView()
                            .controlSize(.small)
                            .padding(.leading, 6)
                    }

                    Spacer()

                    Link("GitHub Releases ↗", destination: URL(string: "https://github.com/\(UpdateChecker.repoOwner)/\(UpdateChecker.repoName)/releases")!)
                        .font(.caption)
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 480)
        .navigationTitle("Updates")
    }
}
