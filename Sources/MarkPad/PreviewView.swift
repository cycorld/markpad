import SwiftUI
import WebKit

/// Renders HTML in a WKWebView. The page shell loads once; body updates go through JS so scroll position survives.
struct PreviewView: NSViewRepresentable {
    let html: String
    let baseURL: URL?
    var jump: JumpRequest? = nil

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.setURLSchemeHandler(LocalFileSchemeHandler(), forURLScheme: LocalFileSchemeHandler.scheme)
        let web = WKWebView(frame: .zero, configuration: config)
        web.navigationDelegate = context.coordinator
        web.underPageBackgroundColor = .textBackgroundColor
        context.coordinator.loadShell(baseURL: pageBaseURL, in: web)
        return web
    }

    func updateNSView(_ web: WKWebView, context: Context) {
        context.coordinator.update(html: html, baseURL: pageBaseURL, in: web)
        if let jump { context.coordinator.jump(to: jump, in: web) }
    }

    /// `markpad:///abs/dir/` so relative images resolve through `LocalFileSchemeHandler`. Untitled documents
    /// get the filesystem root, which keeps the page on the same origin as the bundled KaTeX/Mermaid assets.
    private var pageBaseURL: URL? {
        LocalFileSchemeHandler.url(forDirectory: baseURL ?? URL(fileURLWithPath: "/"))
    }

    /// Page shell with the bundled vendor directory baked in.
    static let shell: String = {
        let resources = Bundle.main.resourceURL ?? Bundle.main.bundleURL
        let vendor = LocalFileSchemeHandler.url(forDirectory: resources.appendingPathComponent("vendor"))
        return PreviewTemplate.page(vendorURL: vendor?.absoluteString ?? "")
    }()

    final class Coordinator: NSObject, WKNavigationDelegate {
        private var shellLoaded = false
        private var currentBase: URL?
        private var lastHTML: String?
        private var pending: String?
        private var lastJump: UUID?

        func jump(to request: JumpRequest, in web: WKWebView) {
            guard request.token != lastJump, shellLoaded else { return }
            lastJump = request.token
            guard let data = try? JSONEncoder().encode(request.heading.id),
                  let json = String(data: data, encoding: .utf8)
            else { return }
            web.evaluateJavaScript("window.__jump(\(json))")
        }

        func loadShell(baseURL: URL?, in web: WKWebView) {
            shellLoaded = false
            currentBase = baseURL
            pending = lastHTML
            web.loadHTMLString(PreviewView.shell, baseURL: baseURL)
        }

        func update(html: String, baseURL: URL?, in web: WKWebView) {
            if baseURL != currentBase {
                lastHTML = html
                loadShell(baseURL: baseURL, in: web)
                return
            }
            guard html != lastHTML else { return }
            lastHTML = html
            if shellLoaded { push(html, to: web) } else { pending = html }
        }

        private func push(_ html: String, to web: WKWebView) {
            guard let data = try? JSONEncoder().encode(html),
                  let json = String(data: data, encoding: .utf8)
            else { return }
            web.evaluateJavaScript("window.__set(\(json))")
        }

        // MARK: WKNavigationDelegate

        func webView(_ web: WKWebView, didFinish navigation: WKNavigation!) {
            shellLoaded = true
            if let html = pending {
                pending = nil
                push(html, to: web)
            }
        }

        func webView(
            _ web: WKWebView,
            decidePolicyFor action: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard action.navigationType == .linkActivated, let url = action.request.url else {
                decisionHandler(.allow)
                return
            }
            // In-page anchors stay inside the preview; everything else opens externally.
            let target = url.absoluteString.split(separator: "#", maxSplits: 1)[0]
            let current = (web.url?.absoluteString ?? "").split(separator: "#", maxSplits: 1)[0]
            if url.fragment != nil, target == current {
                decisionHandler(.allow)
            } else {
                NSWorkspace.shared.open(LocalFileSchemeHandler.externalURL(for: url))
                decisionHandler(.cancel)
            }
        }
    }
}
