import AppKit
import SwiftUI

/// Window controller for the standalone Software Update dialog window.
@MainActor
final class UpdateWindowController: NSWindowController {
    static let shared = UpdateWindowController()

    private init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 380),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "Software Update"
        window.isReleasedWhenClosed = false
        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(release: GitHubRelease, currentVersion: String) {
        guard let window else { return }
        window.contentView = NSHostingView(rootView: UpdateView(
            release: release,
            currentVersion: currentVersion,
            onClose: { [weak self] in
                self?.close()
            }
        ))
        window.center()
        showWindow(nil)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
