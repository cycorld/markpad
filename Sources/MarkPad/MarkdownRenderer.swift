/// Markdown → HTML for the preview: protect math spans, render, splice math back in.
enum MarkdownRenderer {
    static func html(from markdown: String) -> String {
        let (protected, spans) = MathProtector.extract(markdown)
        return MathProtector.restore(HTMLRenderer.render(protected), spans: spans)
    }
}
