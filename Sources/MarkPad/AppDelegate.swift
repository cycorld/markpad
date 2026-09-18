import AppKit

/// Launch-time housekeeping:
/// - DocumentGroup always spawns an "Untitled" window at launch, even when a file was opened, and restores
///   empty untitled windows from earlier sessions — the blank ones are closed once launch has settled.
/// - `MarkPad --export-pdf in.md out.pdf` renders a file to PDF headlessly and exits (scripting / CI).
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        UserDefaults.standard.register(defaults: PrintOptions.defaults)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        if let (input, output) = Self.exportArguments() {
            export(input, to: output)
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Self.closeBlankUntitledDocuments()
        }
    }

    // MARK: - Headless PDF export

    private static func exportArguments() -> (URL, URL)? {
        let arguments = CommandLine.arguments
        guard let flag = arguments.firstIndex(of: "--export-pdf"), flag + 2 < arguments.count else { return nil }
        return (URL(fileURLWithPath: arguments[flag + 1]), URL(fileURLWithPath: arguments[flag + 2]))
    }

    private func export(_ input: URL, to output: URL) {
        guard let markdown = try? String(contentsOf: input, encoding: .utf8) else {
            FileHandle.standardError.write(Data("cannot read \(input.path)\n".utf8))
            exit(2)
        }
        let source = PrintSource(
            html: MarkdownRenderer.html(from: markdown),
            baseURL: input.deletingLastPathComponent(),
            title: input.deletingPathExtension().lastPathComponent,
            fileName: input.lastPathComponent
        )
        PrintController.shared.exportPDF(source, to: output, host: nil) { ok in
            exit(ok ? 0 : 1)
        }
    }

    // MARK: - Blank window cleanup

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
