import AppKit

/// DocumentGroup always spawns an "Untitled" window at launch, even when a file was opened, and restores
/// empty untitled windows from earlier sessions. Close the blank ones once launch has settled.
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Self.closeBlankUntitledDocuments()
        }
    }

    private static func closeBlankUntitledDocuments() {
        let documents = NSDocumentController.shared.documents
        let blanks = documents.filter { $0.fileURL == nil && isEmpty($0) }
        let keep = documents.count == blanks.count ? 1 : 0
        for document in blanks.dropFirst(keep) {
            document.close()
        }
    }

    /// SwiftUI marks a fresh untitled document as edited, so inspect the editor text instead of `isDocumentEdited`.
    private static func isEmpty(_ document: NSDocument) -> Bool {
        document.windowControllers.allSatisfy { controller in
            guard let root = controller.window?.contentView else { return true }
            return textViews(in: root).allSatisfy { $0.string.isEmpty }
        }
    }

    private static func textViews(in view: NSView) -> [NSTextView] {
        if let textView = view as? NSTextView { return [textView] }
        return view.subviews.flatMap(textViews(in:))
    }
}
