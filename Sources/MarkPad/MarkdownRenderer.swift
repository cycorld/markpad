import Foundation

struct RenderResult {
    let html: String
    let headings: [HeadingInfo]
}

/// Markdown → HTML for the preview: protect math spans, render, splice math back in, expand `[TOC]`.
enum MarkdownRenderer {
    static func render(_ markdown: String) -> RenderResult {
        let (protected, spans) = MathProtector.extract(markdown)
        let (rendered, headings) = HTMLRenderer.render(protected)
        var html = MathProtector.restore(rendered, spans: spans)
        html = expandTOC(in: html, headings: headings)
        return RenderResult(html: html, headings: headings)
    }

    static func html(from markdown: String) -> String {
        render(markdown).html
    }

    // MARK: - Table of contents

    /// A paragraph consisting solely of `[TOC]` or `[[toc]]` (any case) becomes a nested list of the document's headings.
    private static let tocMarker = try? NSRegularExpression(pattern: #"<p>\[\[?toc\]\]?</p>\n?"#, options: .caseInsensitive)

    private static func expandTOC(in html: String, headings: [HeadingInfo]) -> String {
        guard let tocMarker, html.range(of: "toc", options: .caseInsensitive) != nil else { return html }
        let range = NSRange(html.startIndex..., in: html)
        guard tocMarker.firstMatch(in: html, range: range) != nil else { return html }
        let toc = NSRegularExpression.escapedTemplate(for: tocHTML(headings))
        return tocMarker.stringByReplacingMatches(in: html, range: range, withTemplate: toc)
    }

    static func tocHTML(_ headings: [HeadingInfo]) -> String {
        guard !headings.isEmpty else { return "<nav class=\"toc\"></nav>\n" }
        var html = "<nav class=\"toc\">"
        var open: [Int] = []
        for heading in headings {
            while let top = open.last, top > heading.level {
                html += "</li></ul>"
                open.removeLast()
            }
            if open.last == heading.level {
                html += "</li>"
            } else {
                html += "<ul>"
                open.append(heading.level)
            }
            html += "<li><a href=\"#\(heading.id)\">\(HTMLRenderer.escape(heading.text))</a>"
        }
        while !open.isEmpty {
            html += "</li></ul>"
            open.removeLast()
        }
        return html + "</nav>\n"
    }
}
