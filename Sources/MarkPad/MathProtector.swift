/// Lifts `$…$` and `$$…$$` spans out of markdown before parsing so emphasis and escapes don't mangle TeX,
/// then splices them back into the rendered HTML as `<span class="math">` for KaTeX.
///
/// Rules (Pandoc/Obsidian style): an opening `$` must be followed by a non-space, a closing `$` must be
/// preceded by a non-space and not followed by a digit, inline math can't cross a blank line,
/// `\$` is a literal dollar, and nothing inside fenced code or inline code is touched.
enum MathProtector {
    struct Span {
        let tex: String
        let display: Bool
    }

    /// Wraps the index of a lifted span in the intermediate markdown/HTML.
    static let marker: Character = "\u{FFFC}"

    static func extract(_ text: String) -> (markdown: String, spans: [Span]) {
        let chars = Array(text)
        var out = ""
        var spans: [Span] = []
        var i = 0
        var fence: (char: Character, length: Int)?
        var lineStart = true

        while i < chars.count {
            if lineStart, let (char, length, end) = fenceLine(chars, at: i) {
                if let open = fence {
                    if char == open.char, length >= open.length { fence = nil }
                } else {
                    fence = (char, length)
                }
                out.append(contentsOf: chars[i..<end])
                i = end
                continue
            }
            if fence != nil {
                let end = lineEnd(chars, from: i)
                out.append(contentsOf: chars[i..<end])
                i = end
                lineStart = true
                continue
            }

            let c = chars[i]
            lineStart = false

            if c == "\\", i + 1 < chars.count, chars[i + 1] == "$" {
                out.append("\\$")
                i += 2
                continue
            }
            if c == "`" {
                let run = runLength(chars, of: "`", at: i)
                if let close = closingRun(chars, of: "`", length: run, from: i + run) {
                    out.append(contentsOf: chars[i..<(close + run)])
                    i = close + run
                    continue
                }
            }
            if c == "$" {
                if i + 1 < chars.count, chars[i + 1] == "$" {
                    if let close = closingDollars(chars, from: i + 2) {
                        spans.append(Span(tex: String(chars[(i + 2)..<close]), display: true))
                        out.append(placeholder(spans.count - 1))
                        i = close + 2
                        continue
                    }
                } else if let close = closingInlineDollar(chars, from: i + 1) {
                    spans.append(Span(tex: String(chars[(i + 1)..<close]), display: false))
                    out.append(placeholder(spans.count - 1))
                    i = close + 1
                    continue
                }
            }

            out.append(c)
            lineStart = c == "\n"
            i += 1
        }
        return (out, spans)
    }

    static func restore(_ html: String, spans: [Span]) -> String {
        guard !spans.isEmpty else { return html }
        var result = ""
        var rest = Substring(html)
        while let open = rest.firstIndex(of: marker) {
            result += rest[..<open]
            let afterOpen = rest.index(after: open)
            guard let close = rest[afterOpen...].firstIndex(of: marker),
                  let index = Int(rest[afterOpen..<close]), spans.indices.contains(index)
            else {
                result.append(marker)
                rest = rest[afterOpen...]
                continue
            }
            let span = spans[index]
            let cls = span.display ? "math math-display" : "math"
            result += "<span class=\"\(cls)\">\(HTMLRenderer.escape(span.tex))</span>"
            rest = rest[rest.index(after: close)...]
        }
        return result + rest
    }

    // MARK: - Scanning helpers

    private static func placeholder(_ index: Int) -> String {
        "\(marker)\(index)\(marker)"
    }

    private static func lineEnd(_ chars: [Character], from i: Int) -> Int {
        var j = i
        while j < chars.count, chars[j] != "\n" { j += 1 }
        return min(j + 1, chars.count)
    }

    /// A line that is (up to 3 spaces +) three or more backticks or tildes.
    private static func fenceLine(_ chars: [Character], at i: Int) -> (Character, Int, Int)? {
        var j = i
        var indent = 0
        while j < chars.count, chars[j] == " ", indent < 3 { j += 1; indent += 1 }
        guard j < chars.count, chars[j] == "`" || chars[j] == "~" else { return nil }
        let char = chars[j]
        let length = runLength(chars, of: char, at: j)
        guard length >= 3 else { return nil }
        return (char, length, lineEnd(chars, from: j))
    }

    private static func runLength(_ chars: [Character], of c: Character, at i: Int) -> Int {
        var j = i
        while j < chars.count, chars[j] == c { j += 1 }
        return j - i
    }

    private static func closingRun(_ chars: [Character], of c: Character, length: Int, from start: Int) -> Int? {
        var j = start
        while j < chars.count {
            if chars[j] == c {
                let run = runLength(chars, of: c, at: j)
                if run == length { return j }
                j += run
            } else {
                j += 1
            }
        }
        return nil
    }

    private static func closingDollars(_ chars: [Character], from start: Int) -> Int? {
        var j = start
        while j + 1 < chars.count {
            if chars[j] == "\\" { j += 2; continue }
            if chars[j] == "$", chars[j + 1] == "$" { return j }
            j += 1
        }
        return nil
    }

    private static func closingInlineDollar(_ chars: [Character], from start: Int) -> Int? {
        guard start < chars.count, !chars[start].isWhitespace, chars[start] != "$" else { return nil }
        var j = start
        while j < chars.count {
            let c = chars[j]
            if c == "\\" { j += 2; continue }
            if c == "\n", j + 1 < chars.count, chars[j + 1] == "\n" { return nil }
            if c == "$" {
                let nextIsDigit = j + 1 < chars.count && chars[j + 1].isNumber
                if !chars[j - 1].isWhitespace, !nextIsDigit { return j }
                return nil
            }
            j += 1
        }
        return nil
    }
}
