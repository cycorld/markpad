import XCTest
@testable import MarkPad

final class HTMLRendererTests: XCTestCase {
    private func render(_ markdown: String) -> String { HTMLRenderer.render(markdown).html }

    func testDuplicateHeadingIdsGetSuffixes() {
        let (html, headings) = HTMLRenderer.render("# 표\n\n## 표\n\n## Other\n\n### 표")
        XCTAssertEqual(headings.map(\.id), ["표", "표-1", "other", "표-2"])
        XCTAssertEqual(headings.map(\.level), [1, 2, 2, 3])
        XCTAssertEqual(headings.map(\.line), [1, 3, 5, 7])
        XCTAssertTrue(html.contains("<h2 id=\"표-1\">"), html)
    }

    func testTOCMarkerExpandsToNestedList() {
        let html = MarkdownRenderer.html(from: "[TOC]\n\n# A\n\n## B\n\n### C\n\n## D\n\n# E")
        let expected = "<nav class=\"toc\"><ul><li><a href=\"#a\">A</a><ul><li><a href=\"#b\">B</a><ul><li><a href=\"#c\">C</a></li></ul></li><li><a href=\"#d\">D</a></li></ul></li><li><a href=\"#e\">E</a></li></ul></nav>\n"
        XCTAssertTrue(html.hasPrefix(expected), html)
        XCTAssertFalse(html.contains("[TOC]"))
    }

    func testLowercaseDoubleBracketTOCAndInlineCodeUntouched() {
        XCTAssertTrue(MarkdownRenderer.html(from: "[[toc]]\n\n# A").hasPrefix("<nav class=\"toc\">"))
        XCTAssertTrue(MarkdownRenderer.html(from: "`[TOC]`\n\n# A").contains("<code>[TOC]</code>"))
    }

    func testTextIsEscaped() {
        XCTAssertEqual(render("a < b & c"), "<p>a &lt; b &amp; c</p>\n")
    }

    func testCodeBlockIsEscapedAndKeepsLanguage() {
        let html = render("```swift\nif a < b { }\n```\n")
        XCTAssertEqual(html, "<pre><code class=\"language-swift\">if a &lt; b { }\n</code></pre>\n")
    }

    func testInlineCodeIsEscaped() {
        XCTAssertEqual(render("`<div>`"), "<p><code>&lt;div&gt;</code></p>\n")
    }

    func testRawHTMLBlocksPassThrough() {
        XCTAssertEqual(render("<div>hi</div>").trimmingCharacters(in: .whitespacesAndNewlines), "<div>hi</div>")
    }

    func testHeadingGetsSlugIdAndInlineMarkup() {
        XCTAssertEqual(render("## Hello **World** 표"), "<h2 id=\"hello-world-표\">Hello <strong>World</strong> 표</h2>\n")
    }

    func testTaskListAndTable() {
        let html = render("- [x] done\n\n| a | b |\n|---|:-:|\n| 1 | 2 |\n")
        XCTAssertTrue(html.contains("<li><input type=\"checkbox\" disabled=\"\" checked=\"\" /> <p>done</p>"), html)
        XCTAssertTrue(html.contains("<th align=\"center\">b</th>"), html)
    }

    func testLinkAttributesAreEscaped() {
        XCTAssertEqual(render("[x](http://e.com/?a=1&b=\"2\")"), "<p><a href=\"http://e.com/?a=1&amp;b=&quot;2&quot;\">x</a></p>\n")
    }
}
