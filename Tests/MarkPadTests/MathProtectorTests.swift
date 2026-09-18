import XCTest
@testable import MarkPad

final class MathProtectorTests: XCTestCase {
    private func render(_ md: String) -> String { MarkdownRenderer.html(from: md) }

    func testInlineMathSurvivesEmphasisParsing() {
        let html = render("Euler: $a_1 + b_1 = c_1$ done")
        XCTAssertTrue(html.contains("<span class=\"math\">a_1 + b_1 = c_1</span>"), html)
        XCTAssertFalse(html.contains("<em>"), html)
    }

    func testDisplayMathSpansLines() {
        let html = render("$$\n\\int_0^1 x^2\\,dx\n$$")
        XCTAssertTrue(html.contains("<span class=\"math math-display\">\n\\int_0^1 x^2\\,dx\n</span>"), html)
    }

    func testDollarPricesAreNotMath() {
        let html = render("Costs $5 and $10 today")
        XCTAssertFalse(html.contains("class=\"math"), html)
        XCTAssertTrue(html.contains("$5 and $10"), html)
    }

    func testSpaceAfterOpeningDollarIsNotMath() {
        XCTAssertFalse(render("a $ b$ c").contains("class=\"math"))
    }

    func testEscapedDollarIsLiteral() {
        let html = render("price \\$3 and \\$4")
        XCTAssertFalse(html.contains("class=\"math"), html)
        XCTAssertTrue(html.contains("$3 and $4"), html)
    }

    func testCodeIsNeverMath() {
        XCTAssertFalse(render("`$x$` and\n\n```\n$y$\n```\n").contains("class=\"math"))
    }

    func testMathTexIsHTMLEscaped() {
        let html = render("$a<b$")
        XCTAssertTrue(html.contains("<span class=\"math\">a&lt;b</span>"), html)
    }

    func testDisplayMathKeepsLineNumbersOfLaterHeadings() {
        let result = MarkdownRenderer.render("# A\n\n$$\nx\ny\n$$\n\n# B")
        XCTAssertEqual(result.headings.map(\.line), [1, 8])
        XCTAssertEqual(result.headings.map(\.text), ["A", "B"])
    }

    func testHeadingTextDropsMathPlaceholder() {
        XCTAssertEqual(MarkdownRenderer.render("# Energy $E=mc^2$ now").headings.first?.text, "Energy  now")
    }

    func testMathInsideHeading() {
        let html = render("# Energy $E=mc^2$")
        XCTAssertTrue(html.contains("<h1 id=\"energy\">Energy <span class=\"math\">E=mc^2</span></h1>"), html)
    }
}
