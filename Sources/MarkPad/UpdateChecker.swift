import AppKit
import Foundation
import SwiftUI

/// Checks GitHub Releases as the Single Source of Truth for MarkPad updates.
@MainActor
public final class UpdateChecker: ObservableObject {
    public static let shared = UpdateChecker()

    public enum DefaultsKey {
        public static let automaticallyCheck = "checkForUpdatesAutomatically"
        public static let lastCheckTimestamp = "lastUpdateCheckTimestamp"
    }

    public static let defaults: [String: Any] = [
        DefaultsKey.automaticallyCheck: true,
        DefaultsKey.lastCheckTimestamp: 0.0
    ]

    public static let repoOwner = "cycorld"
    public static let repoName = "markpad"

    @Published public private(set) var isChecking = false
    @Published public private(set) var latestRelease: GitHubRelease?
    @Published public private(set) var updateAvailable = false
    @Published public var lastCheckedDate: Date? {
        didSet {
            if let date = lastCheckedDate {
                UserDefaults.standard.set(date.timeIntervalSince1970, forKey: DefaultsKey.lastCheckTimestamp)
            }
        }
    }

    public var currentVersion: SemanticVersion {
        let versionStr = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
        return SemanticVersion(versionStr) ?? SemanticVersion(major: 0, minor: 0, patch: 0)
    }

    public var currentVersionString: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }

    public var currentBuildString: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    }

    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
        let timestamp = UserDefaults.standard.double(forKey: DefaultsKey.lastCheckTimestamp)
        if timestamp > 0 {
            self.lastCheckedDate = Date(timeIntervalSince1970: timestamp)
        }
    }

    /// Checks for updates against GitHub Releases.
    /// - Parameter explicit: When `true` (user initiated), shows an alert if already up-to-date or on network failure.
    ///                       When `false` (background launch check), silently completes without error dialogs.
    public func checkForUpdates(explicit: Bool = true) {
        guard !isChecking else { return }
        isChecking = true

        let url = URL(string: "https://api.github.com/repos/\(Self.repoOwner)/\(Self.repoName)/releases/latest")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("MarkPad/\(currentVersionString)", forHTTPHeaderField: "User-Agent")

        Task {
            defer { self.isChecking = false }
            do {
                let (data, response) = try await session.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    if httpResponse.statusCode == 404 {
                        throw NSError(
                            domain: "UpdateChecker",
                            code: 404,
                            userInfo: [NSLocalizedDescriptionKey: "No releases found on GitHub repository \(Self.repoOwner)/\(Self.repoName)."]
                        )
                    }
                    throw NSError(
                        domain: "UpdateChecker",
                        code: httpResponse.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "GitHub API returned HTTP status \(httpResponse.statusCode)."]
                    )
                }

                let decoder = JSONDecoder()
                let release = try decoder.decode(GitHubRelease.self, from: data)
                self.lastCheckedDate = Date()
                self.latestRelease = release

                guard let remoteVersion = release.version else {
                    if explicit {
                        self.showErrorAlert(message: "Couldn't parse release version '\(release.tagName)' from GitHub.")
                    }
                    return
                }

                if remoteVersion > self.currentVersion {
                    self.updateAvailable = true
                    UpdateWindowController.shared.show(release: release, currentVersion: self.currentVersionString)
                } else {
                    self.updateAvailable = false
                    if explicit {
                        self.showUpToDateAlert()
                    }
                }
            } catch {
                if explicit {
                    self.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }

    /// Background update check on app launch, throttled to at most once per 24 hours.
    public func checkOnLaunchIfNeeded() {
        guard UserDefaults.standard.bool(forKey: DefaultsKey.automaticallyCheck) else { return }

        let now = Date().timeIntervalSince1970
        let lastCheck = UserDefaults.standard.double(forKey: DefaultsKey.lastCheckTimestamp)
        let oneDay: TimeInterval = 86400

        if now - lastCheck >= oneDay {
            checkForUpdates(explicit: false)
        }
    }

    private func showUpToDateAlert() {
        let alert = NSAlert()
        alert.messageText = "You're up to date!"
        alert.informativeText = "MarkPad \(currentVersionString) is currently the newest version available."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    private func showErrorAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = "Check for Updates Failed"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
