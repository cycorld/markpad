import Markdown

/// Isolated so `Markdown.Text` never shadows `SwiftUI.Text` in view files.
enum MarkdownRenderer {
    static func html(from markdown: String) -> String {
        HTMLFormatter.format(markdown)
    }
}
