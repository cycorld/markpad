import AppKit
import PDFKit
import SwiftUI
import WebKit

/// What the print commands need from the focused document window.
struct PrintSource: Equatable {
    let html: String
    let baseURL: URL?
    let title: String
    let fileName: String
}

private struct PrintSourceKey: FocusedValueKey {
    typealias Value = PrintSource
}

extension FocusedValues {
    var printSource: PrintSource? {
        get { self[PrintSourceKey.self] }
        set { self[PrintSourceKey.self] = newValue }
    }
}

/// Print / PDF export pipeline.
///
/// Stage 1: an offscreen, light-appearance `WKWebView` renders the document and WebKit paginates it into a PDF,
/// with the top/bottom margins widened to leave room for a header and footer.
/// Stage 2: `PrintPagesView` draws each PDF page full-bleed and paints the header/footer into those margins,
/// through a regular `NSPrintOperation` (print panel with preview, or straight to a PDF file).
@MainActor
final class PrintController: NSObject {
    static let shared = PrintController()

    /// `MARKPAD_DEBUG=1` traces the pipeline on stderr.
    private static let verbose = ProcessInfo.processInfo.environment["MARKPAD_DEBUG"] != nil

    static func trace(_ message: String) {
        guard verbose else { return }
        FileHandle.standardError.write(Data("[print] \(message)\n".utf8))
    }

    struct PageLayout {
        let paper: NSSize
        let top: CGFloat
        let bottom: CGFloat
        let left: CGFloat
        let right: CGFloat
    }

    private var window: NSWindow?
    private var webView: WKWebView?
    private var navigation: ShellNavigation?
    private var completion: PrintCompletion?

    func print(_ source: PrintSource, from host: NSWindow?) {
        paginate(source, host: host) { [weak self] pdf, layout in
            guard let self, let pdf else { return }
            let operation = self.pageOperation(pdf: pdf, layout: layout, source: source)
            operation.showsPrintPanel = true
            operation.printPanel.options = [.showsCopies, .showsPageRange, .showsPreview]
            if let host {
                operation.runModal(for: host, delegate: nil, didRun: nil, contextInfo: nil)
            } else {
                _ = operation.run()
            }
        }
    }

    func exportPDF(_ source: PrintSource, to url: URL, host: NSWindow?, completion: @escaping (Bool) -> Void) {
        paginate(source, host: host) { [weak self] pdf, layout in
            guard let self, let pdf else { completion(false); return }
            let operation = self.pageOperation(pdf: pdf, layout: layout, source: source)
            operation.printInfo.jobDisposition = .save
            operation.printInfo.dictionary()[NSPrintInfo.AttributeKey.jobSavingURL] = url
            operation.showsPrintPanel = false
            operation.showsProgressPanel = false
            let ok = operation.run()
            Self.trace("export to \(url.lastPathComponent) ok=\(ok)")
            completion(ok)
        }
    }

    // MARK: - Stage 1: WebKit pagination

    private func paginate(_ source: PrintSource, host: NSWindow?, completion: @escaping (PDFDocument?, PageLayout) -> Void) {
        let options = PrintOptions.current
        let info = (NSPrintInfo.shared.copy() as? NSPrintInfo) ?? NSPrintInfo()
        if options.headerEnabled { info.topMargin = max(info.topMargin, 64) }
        if options.footerEnabled { info.bottomMargin = max(info.bottomMargin, 64) }
        info.horizontalPagination = .fit
        info.verticalPagination = .automatic
        info.isHorizontallyCentered = false
        info.isVerticallyCentered = false
        let layout = PageLayout(paper: info.paperSize, top: info.topMargin, bottom: info.bottomMargin,
                                left: info.leftMargin, right: info.rightMargin)

        let scratch = FileManager.default.temporaryDirectory.appendingPathComponent("MarkPad-\(UUID().uuidString).pdf")
        info.jobDisposition = .save
        info.dictionary()[NSPrintInfo.AttributeKey.jobSavingURL] = scratch

        let web = makeWebView(size: info.imageablePageBounds.size)
        Self.trace("paper \(info.paperSize) margins t\(info.topMargin) b\(info.bottomMargin) l\(info.leftMargin) r\(info.rightMargin); loading shell")
        let finish: (Bool) -> Void = { [weak self] ok in
            Self.trace("webkit print operation finished ok=\(ok)")
            let pdf = ok ? PDFDocument(url: scratch) : nil
            Self.trace("pdf pages: \(pdf?.pageCount ?? -1)")
            try? FileManager.default.removeItem(at: scratch)
            self?.teardown()
            completion(pdf, layout)
        }
        navigation = ShellNavigation { [weak self] in
            guard let self else { return }
            Self.trace("shell loaded; injecting document (\(source.html.count) chars)")
            web.callAsyncJavaScript("await window.__set(html);", arguments: ["html": source.html], in: nil, in: .page) { result in
                if case .failure(let error) = result { Self.trace("__set failed: \(error)") }
                Self.trace("document settled; running webkit print operation")
                let operation = web.printOperation(with: info)
                operation.showsPrintPanel = false
                operation.showsProgressPanel = false
                operation.view?.frame = NSRect(origin: .zero, size: info.paperSize)
                let done = PrintCompletion(finish)
                self.completion = done
                operation.runModal(for: host ?? self.window ?? NSWindow(), delegate: done,
                                   didRun: #selector(PrintCompletion.printOperationDidRun(_:success:contextInfo:)),
                                   contextInfo: nil)
            }
        }
        web.navigationDelegate = navigation
        let base = LocalFileSchemeHandler.url(forDirectory: source.baseURL ?? URL(fileURLWithPath: "/"))
        web.loadHTMLString(PreviewView.shell, baseURL: base)
    }

    private func makeWebView(size: NSSize) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.setURLSchemeHandler(LocalFileSchemeHandler(), forURLScheme: LocalFileSchemeHandler.scheme)
        let web = WKWebView(frame: NSRect(origin: .zero, size: size), configuration: config)
        web.appearance = NSAppearance(named: .aqua)  // print in light colors whatever the system theme
        let offscreen = NSWindow(contentRect: web.frame, styleMask: [.borderless], backing: .buffered, defer: false)
        offscreen.isReleasedWhenClosed = false
        offscreen.contentView = web
        window = offscreen
        webView = web
        return web
    }

    private func teardown() {
        webView?.navigationDelegate = nil
        webView = nil
        window?.contentView = nil
        window = nil
        navigation = nil
        completion = nil
    }

    // MARK: - Stage 2: pages with header and footer

    private func pageOperation(pdf: PDFDocument, layout: PageLayout, source: PrintSource) -> NSPrintOperation {
        let info = (NSPrintInfo.shared.copy() as? NSPrintInfo) ?? NSPrintInfo()
        info.paperSize = layout.paper
        info.topMargin = 0
        info.bottomMargin = 0
        info.leftMargin = 0
        info.rightMargin = 0
        info.horizontalPagination = .clip
        info.verticalPagination = .clip
        info.isHorizontallyCentered = false
        info.isVerticallyCentered = false
        info.scalingFactor = 1

        let now = Date.now
        let context = PrintOptions.Context(
            title: source.title,
            file: source.fileName,
            date: now.formatted(date: .long, time: .omitted),
            time: now.formatted(date: .omitted, time: .shortened)
        )
        Self.trace("stage 2: \(pdf.pageCount) pages, paper \(info.paperSize)")
        let view = PrintPagesView(document: pdf, layout: layout, options: PrintOptions.current, context: context)
        let operation = NSPrintOperation(view: view, printInfo: info)
        operation.jobTitle = source.title
        Self.trace("stage 2: operation ready")
        return operation
    }
}

/// Fires once the page shell has loaded.
private final class ShellNavigation: NSObject, WKNavigationDelegate {
    private let onLoad: () -> Void

    init(onLoad: @escaping () -> Void) {
        self.onLoad = onLoad
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        onLoad()
    }
}

/// `runModal(for:delegate:didRun:contextInfo:)` callback target. AppKit calls it on the print operation's own
/// thread, so the handler is hopped back to the main thread before anything touches the web view or windows.
private final class PrintCompletion: NSObject {
    private let handler: @MainActor (Bool) -> Void

    init(_ handler: @escaping @MainActor (Bool) -> Void) {
        self.handler = handler
    }

    @objc func printOperationDidRun(_ operation: NSPrintOperation, success: Bool, contextInfo: UnsafeMutableRawPointer?) {
        DispatchQueue.main.async { [handler] in
            handler(success)
        }
    }
}

/// Draws the paginated PDF one page per printed page, plus header and footer text in the margins.
final class PrintPagesView: NSView {
    private let document: PDFDocument
    private let layout: PrintController.PageLayout
    private let options: PrintOptions
    private let context: PrintOptions.Context
    private let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 9),
        .foregroundColor: NSColor(white: 0.4, alpha: 1),
    ]

    private var pageCount: Int { max(1, document.pageCount) }

    init(document: PDFDocument, layout: PrintController.PageLayout, options: PrintOptions, context: PrintOptions.Context) {
        self.document = document
        self.layout = layout
        self.options = options
        self.context = context
        let paper = layout.paper
        super.init(frame: NSRect(x: 0, y: 0, width: paper.width, height: paper.height * CGFloat(max(1, document.pageCount))))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func knowsPageRange(_ range: NSRangePointer) -> Bool {
        range.pointee = NSRange(location: 1, length: pageCount)
        return true
    }

    override func rectForPage(_ page: Int) -> NSRect {
        NSRect(x: 0, y: CGFloat(pageCount - page) * layout.paper.height, width: layout.paper.width, height: layout.paper.height)
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let cg = NSGraphicsContext.current?.cgContext else { return }
        let page = NSPrintOperation.current?.currentPage ?? 1
        PrintController.trace("drawing page \(page) of \(pageCount) rect \(dirtyRect)")
        let rect = rectForPage(page)

        NSColor.white.setFill()
        rect.fill()
        if let pdfPage = document.page(at: page - 1) {
            cg.saveGState()
            cg.translateBy(x: rect.minX, y: rect.minY)
            pdfPage.draw(with: .mediaBox, to: cg)
            cg.restoreGState()
        }

        let contentWidth = rect.width - layout.left - layout.right
        if options.headerEnabled {
            let band = NSRect(x: rect.minX + layout.left, y: rect.maxY - layout.top, width: contentWidth, height: layout.top)
            drawBand(options.header, in: band, page: page)
        }
        if options.footerEnabled {
            let band = NSRect(x: rect.minX + layout.left, y: rect.minY, width: contentWidth, height: layout.bottom)
            drawBand(options.footer, in: band, page: page)
        }
    }

    private func drawBand(_ templates: [String], in band: NSRect, page: Int) {
        for (column, template) in templates.enumerated() {
            let text = options.expand(template, page: page, pages: pageCount, context: context)
            guard !text.isEmpty else { continue }
            let string = NSAttributedString(string: text, attributes: attributes)
            let size = string.size()
            let x: CGFloat = switch column {
            case 0: band.minX
            case 1: band.midX - size.width / 2
            default: band.maxX - size.width
            }
            string.draw(at: NSPoint(x: x, y: band.midY - size.height / 2))
        }
    }
}
