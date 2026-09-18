import AppKit
import SwiftUI

/// Plain-text NSTextView wrapper: monospaced, no smart quotes/dashes, find bar, undo.
struct MarkdownTextView: NSViewRepresentable {
    @Binding var text: String
    var jump: JumpRequest? = nil

    func makeCoordinator() -> Coordinator { Coordinator(text: $text) }

    func makeNSView(context: Context) -> NSScrollView {
        let scroll = NSTextView.scrollableTextView()
        guard let textView = scroll.documentView as? NSTextView else { return scroll }

        textView.delegate = context.coordinator
        textView.string = text
        textView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.textColor = .labelColor
        textView.textContainerInset = NSSize(width: 16, height: 18)

        textView.isRichText = false
        textView.allowsUndo = true
        textView.usesFindBar = true
        textView.isIncrementalSearchingEnabled = true

        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isAutomaticLinkDetectionEnabled = false
        textView.smartInsertDeleteEnabled = false

        return scroll
    }

    func updateNSView(_ scroll: NSScrollView, context: Context) {
        context.coordinator.text = $text
        guard let textView = scroll.documentView as? NSTextView else { return }
        if textView.string != text {
            textView.string = text
        }
        if let jump, jump.token != context.coordinator.lastJump {
            context.coordinator.lastJump = jump.token
            Self.select(line: jump.heading.line, in: textView)
        }
    }

    /// Selects the given 1-based line and centers it.
    private static func select(line: Int, in textView: NSTextView) {
        guard line > 0 else { return }
        let text = textView.string as NSString
        var location = 0
        var current = 1
        while current < line, location < text.length {
            let lineRange = text.lineRange(for: NSRange(location: location, length: 0))
            location = lineRange.upperBound
            current += 1
        }
        guard location <= text.length else { return }
        let range = text.lineRange(for: NSRange(location: location, length: 0))
        let selection = NSRange(location: range.location, length: max(0, range.length - 1))
        textView.setSelectedRange(selection)
        textView.scrollRangeToVisible(selection)
        textView.centerSelectionInVisibleArea(nil)
        textView.window?.makeFirstResponder(textView)
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var text: Binding<String>
        var lastJump: UUID?

        init(text: Binding<String>) {
            self.text = text
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            text.wrappedValue = textView.string
        }
    }
}
