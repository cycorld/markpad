import AppKit
import MarkdownEngine
import SwiftUI

/// TextKit 2 live WYSIWYG markdown editor powered by MarkdownEngine.
///
/// Provides in-place live formatting for headings, bold, italic, lists,
/// task checkboxes, code blocks, and blockquotes directly in the editing pane.
struct WysiwygTextView: View {
    @Binding var text: String
    var documentId: String = "default"

    var body: some View {
        NativeTextViewWrapper(
            text: $text,
            fontName: "SF Pro",
            fontSize: 15,
            documentId: documentId
        )
    }
}
