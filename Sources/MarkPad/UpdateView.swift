import AppKit
import SwiftUI

/// Software update dialog presented when a newer release is found.
struct UpdateView: View {
    let release: GitHubRelease
    let currentVersion: String
    let onClose: () -> Void

    @AppStorage(UpdateChecker.DefaultsKey.automaticallyCheck)
    private var automaticallyCheck = true

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                if let appIcon = NSApp.applicationIconImage {
                    Image(nsImage: appIcon)
                        .resizable()
                        .frame(width: 64, height: 64)
                } else {
                    Image(systemName: "arrow.down.circle.fill")
                        .resizable()
                        .frame(width: 64, height: 64)
                        .foregroundStyle(.tint)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("A new version of MarkPad is available!")
                        .font(.headline)

                    Text("MarkPad \(release.version?.description ?? release.tagName) is now available (you have \(currentVersion)).")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Release Notes:")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                ScrollView {
                    Text(release.body ?? "No release notes provided.")
                        .font(.system(.body, design: .default))
                        .textSelection(.enabled)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 180)
                .background(Color(nsColor: .textBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                )
            }

            HStack {
                Toggle("Automatically check for updates", isOn: $automaticallyCheck)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()
            }

            Divider()

            HStack {
                Button("Remind Me Later") {
                    onClose()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("View on GitHub") {
                    NSWorkspace.shared.open(release.htmlURL)
                    onClose()
                }

                Button("Download Update") {
                    if let asset = release.appZipAsset {
                        NSWorkspace.shared.open(asset.browserDownloadURL)
                    } else {
                        NSWorkspace.shared.open(release.htmlURL)
                    }
                    onClose()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 520, height: 380)
    }
}
