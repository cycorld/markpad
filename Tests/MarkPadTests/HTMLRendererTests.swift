import XCTest
@testable import MarkPad

final class HTMLRendererTests: XCTestCase {
    func testTextIsEscaped() {
        XCTAssertEqual(HTMLRenderer.render("a < b & c"), "<p>a &lt; b &amp; c</p>\n")
    }

    func testCodeBlockIsEscapedAndKeepsLanguage() {
        let html = HTMLRenderer.render("```swift\nif a < b { }\n```\n")
        XCTAssertEqual(html, "<pre><code class=\"language-swift\">if a &lt; b { }\n</code></pre>\n")
    }

    func testInlineCodeIsEscaped() {
        XCTAssertEqual(HTMLRenderer.render("`<div>`"), "<p><code>&lt;div&gt;</code></p>\n")
    }

    func testRawHTMLBlocksPassThrough() {
        XCTAssertEqual(HTMLRenderer.render("<div>hi</div>").trimmingCharacters(in: .whitespacesAndNewlines), "<div>hi</div>")
    }

    func testHeadingGetsSlugIdAndInlineMarkup() {
        XCTAssertEqual(HTMLRenderer.render("## Hello **World** 표"), "<h2 id=\"hello-world-표\">Hello <strong>World</strong> 표</h2>\n")
    }

    func testTaskListAndTable() {
        let html = HTMLRenderer.render("- [x] done\n\n| a | b |\n|---|:-:|\n| 1 | 2 |\n")
        XCTAssertTrue(html.contains("<li><input type=\"checkbox\" disabled=\"\" checked=\"\" /> <p>done</p>"), html)
        XCTAssertTrue(html.contains("<th align=\"center\">b</th>"), html)
    }

    func testLinkAttributesAreEscaped() {
        XCTAssertEqual(HTMLRenderer.render("[x](http://e.com/?a=1&b=\"2\")"), "<p><a href=\"http://e.com/?a=1&amp;b=&quot;2&quot;\">x</a></p>\n")
    }
}
