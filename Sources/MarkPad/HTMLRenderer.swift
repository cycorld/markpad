/*
 Derived from swift-markdown's HTMLFormatter
 (https://github.com/swiftlang/swift-markdown, Sources/Markdown/Walker/Walkers/HTMLFormatter.swift)

 Copyright (c) 2023 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception
 See https://swift.org/LICENSE.txt for license information

 Changes for MarkPad: HTML-escapes text, code and attribute values (the original writes them raw),
 renders inline markup inside headings and adds GitHub-style heading ids, and drops the
 aside/inline-attribute options.
*/

import Foundation
import Markdown

/// A heading found while rendering; feeds the `[TOC]` block and the outline sidebar.
struct HeadingInfo: Identifiable, Equatable {
    /// Unique anchor id (GitHub-style slug, `-1`, `-2`… appended on collisions).
    let id: String
    let level: Int
    let text: String
    /// 1-based source line, 0 when unknown.
    let line: Int
}

/// Markdown AST → HTML with proper escaping.
struct HTMLRenderer: MarkupWalker {
    private(set) var result = ""
    private(set) var headings: [HeadingInfo] = []

    private var usedIds: [String: Int] = [:]
    private var inTableHead = false
    private var tableColumnAlignments: [Table.ColumnAlignment?]?
    private var currentTableColumn = 0

    static func render(_ markdown: String) -> (html: String, headings: [HeadingInfo]) {
        var renderer = HTMLRenderer()
        renderer.visit(Document(parsing: markdown))
        return (renderer.result, renderer.headings)
    }

    static func escape(_ text: String) -> String {
        var out = ""
        out.reserveCapacity(text.utf8.count)
        for ch in text {
            switch ch {
            case "&": out += "&amp;"
            case "<": out += "&lt;"
            case ">": out += "&gt;"
            case "\"": out += "&quot;"
            default: out.append(ch)
            }
        }
        return out
    }

    /// Plain text with lifted math placeholders removed.
    static func stripPlaceholders(_ text: String) -> String {
        var out = ""
        var inPlaceholder = false
        for ch in text {
            if ch == MathProtector.marker {
                inPlaceholder.toggle()
            } else if !inPlaceholder {
                out.append(ch)
            }
        }
        return out
    }

    /// GitHub-style anchor id.
    private static func slug(_ text: String) -> String {
        var out = ""
        for ch in stripPlaceholders(text).lowercased() {
            if ch.isLetter || ch.isNumber || ch == "_" {
                out.append(ch)
            } else if ch == " " || ch == "-" {
                out.append("-")
            }
        }
        return out.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }

    private mutating func uniqueId(for text: String) -> String {
        let base = Self.slug(text)
        let seen = usedIds[base, default: 0]
        usedIds[base] = seen + 1
        return seen == 0 ? base : "\(base)-\(seen)"
    }

    mutating func defaultVisit(_ markup: Markup) {
        descendInto(markup)
    }

    // MARK: Block elements

    mutating func visitBlockQuote(_ blockQuote: BlockQuote) {
        result += "<blockquote>\n"
        descendInto(blockQuote)
        result += "</blockquote>\n"
    }

    mutating func visitCodeBlock(_ codeBlock: CodeBlock) {
        let language = codeBlock.language.map { " class=\"language-\(Self.escape($0))\"" } ?? ""
        result += "<pre><code\(language)>\(Self.escape(codeBlock.code))</code></pre>\n"
    }

    mutating func visitHeading(_ heading: Heading) {
        let id = uniqueId(for: heading.plainText)
        headings.append(HeadingInfo(
            id: id,
            level: heading.level,
            text: Self.stripPlaceholders(heading.plainText).trimmingCharacters(in: .whitespaces),
            line: heading.range?.lowerBound.line ?? 0
        ))
        result += "<h\(heading.level) id=\"\(id)\">"
        descendInto(heading)
        result += "</h\(heading.level)>\n"
    }

    mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) {
        result += "<hr />\n"
    }

    mutating func visitHTMLBlock(_ html: HTMLBlock) {
        result += html.rawHTML
    }

    mutating func visitListItem(_ listItem: ListItem) {
        result += "<li>"
        if let checkbox = listItem.checkbox {
            result += "<input type=\"checkbox\" disabled=\"\""
            if checkbox == .checked {
                result += " checked=\"\""
            }
            result += " /> "
        }
        descendInto(listItem)
        result += "</li>\n"
    }

    mutating func visitOrderedList(_ orderedList: OrderedList) {
        let start = orderedList.startIndex != 1 ? " start=\"\(orderedList.startIndex)\"" : ""
        result += "<ol\(start)>\n"
        descendInto(orderedList)
        result += "</ol>\n"
    }

    mutating func visitUnorderedList(_ unorderedList: UnorderedList) {
        result += "<ul>\n"
        descendInto(unorderedList)
        result += "</ul>\n"
    }

    mutating func visitParagraph(_ paragraph: Paragraph) {
        result += "<p>"
        descendInto(paragraph)
        result += "</p>\n"
    }

    mutating func visitTable(_ table: Table) {
        result += "<table>\n"
        tableColumnAlignments = table.columnAlignments
        descendInto(table)
        tableColumnAlignments = nil
        result += "</table>\n"
    }

    mutating func visitTableHead(_ tableHead: Table.Head) {
        result += "<thead>\n<tr>\n"
        inTableHead = true
        currentTableColumn = 0
        descendInto(tableHead)
        inTableHead = false
        result += "</tr>\n</thead>\n"
    }

    mutating func visitTableBody(_ tableBody: Table.Body) {
        guard !tableBody.isEmpty else { return }
        result += "<tbody>\n"
        descendInto(tableBody)
        result += "</tbody>\n"
    }

    mutating func visitTableRow(_ tableRow: Table.Row) {
        result += "<tr>\n"
        currentTableColumn = 0
        descendInto(tableRow)
        result += "</tr>\n"
    }

    mutating func visitTableCell(_ tableCell: Table.Cell) {
        guard let alignments = tableColumnAlignments, currentTableColumn < alignments.count else { return }
        guard tableCell.colspan > 0, tableCell.rowspan > 0 else { return }
        let element = inTableHead ? "th" : "td"
        result += "<\(element)"
        if let alignment = alignments[currentTableColumn] {
            result += " align=\"\(alignment)\""
        }
        currentTableColumn += 1
        if tableCell.rowspan > 1 {
            result += " rowspan=\"\(tableCell.rowspan)\""
        }
        if tableCell.colspan > 1 {
            result += " colspan=\"\(tableCell.colspan)\""
        }
        result += ">"
        descendInto(tableCell)
        result += "</\(element)>\n"
    }

    // MARK: Inline elements

    private mutating func printInline(tag: String, _ content: Markup) {
        result += "<\(tag)>"
        descendInto(content)
        result += "</\(tag)>"
    }

    mutating func visitInlineCode(_ inlineCode: InlineCode) {
        result += "<code>\(Self.escape(inlineCode.code))</code>"
    }

    mutating func visitEmphasis(_ emphasis: Emphasis) {
        printInline(tag: "em", emphasis)
    }

    mutating func visitStrong(_ strong: Strong) {
        printInline(tag: "strong", strong)
    }

    mutating func visitStrikethrough(_ strikethrough: Strikethrough) {
        printInline(tag: "del", strikethrough)
    }

    mutating func visitImage(_ image: Image) {
        result += "<img"
        if let source = image.source, !source.isEmpty {
            result += " src=\"\(Self.escape(source))\""
        }
        result += " alt=\"\(Self.escape(image.plainText))\""
        if let title = image.title, !title.isEmpty {
            result += " title=\"\(Self.escape(title))\""
        }
        result += " />"
    }

    mutating func visitInlineHTML(_ inlineHTML: InlineHTML) {
        result += inlineHTML.rawHTML
    }

    mutating func visitLineBreak(_ lineBreak: LineBreak) {
        result += "<br />\n"
    }

    mutating func visitSoftBreak(_ softBreak: SoftBreak) {
        result += "\n"
    }

    mutating func visitLink(_ link: Link) {
        result += "<a"
        if let destination = link.destination {
            result += " href=\"\(Self.escape(destination))\""
        }
        if let title = link.title, !title.isEmpty {
            result += " title=\"\(Self.escape(title))\""
        }
        result += ">"
        descendInto(link)
        result += "</a>"
    }

    mutating func visitText(_ text: Text) {
        result += Self.escape(text.string)
    }

    mutating func visitSymbolLink(_ symbolLink: SymbolLink) {
        if let destination = symbolLink.destination {
            result += "<code>\(Self.escape(destination))</code>"
        }
    }
}
