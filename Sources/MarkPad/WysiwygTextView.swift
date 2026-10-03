import AppKit
import MarkdownEngine
import MarkdownEngineCodeBlocks
import SwiftUI

/// TextKit 2 live WYSIWYG markdown editor powered by MarkdownEngine.
///
/// Provides in-place live formatting for headings, bold, italic, lists,
/// task checkboxes, code blocks with syntax highlighting, and blockquotes directly in the editing pane.
struct WysiwygTextView: View {
    @Binding var text: String
    var documentId: String = "default"

    /// Shared syntax highlighter bridge backed by HighlighterSwift with automatic light/dark switching.
    /// Reused statically to preserve token/language cache and prevent recreating JSContext on keystrokes.
    private static let syntaxHighlighter = HighlighterSwiftBridge(
        lightTheme: "github",
        darkTheme: "github-dark"
    )

    private var configuration: MarkdownEditorConfiguration {
        var config = MarkdownEditorConfiguration.default
        config.textInsets = TextInsets(horizontal: 28, vertical: 20)
        config.safeAreaInsets = SafeAreaInsets(top: 16, leading: 16, trailing: 16, bottom: 24)
        config.services = MarkdownEditorServices(
            syntaxHighlighter: Self.syntaxHighlighter
        )
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
