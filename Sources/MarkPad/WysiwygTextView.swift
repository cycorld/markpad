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

    private var configuration: MarkdownEditorConfiguration {
        var config = MarkdownEditorConfiguration.default
        config.textInsets = TextInsets(horizontal: 28, vertical: 20)
        config.safeAreaInsets = SafeAreaInsets(top: 16, leading: 16, bottom: 24, trailing: 16)
        return config
    }

    var body: some View {
        NativeTextViewWrapper(
            text: $text,
            configuration: configuration,
            fontName: "SF Pro",
            fontSize: 15,
            documentId: documentId
        )
    }
}
