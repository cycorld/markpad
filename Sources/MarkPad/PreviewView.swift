import SwiftUI
import WebKit

/// Renders HTML in a WKWebView. The page shell loads once; body updates go through JS so scroll position survives.
struct PreviewView: NSViewRepresentable {
    let html: String
    let baseURL: URL?

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
    }

    /// `markpad:///abs/dir/` so relative images resolve through `LocalFileSchemeHandler`.
    private var pageBaseURL: URL? {
        guard let dir = baseURL else { return nil }
        var parts = URLComponents()
        parts.scheme = LocalFileSchemeHandler.scheme
        parts.host = ""
        parts.path = dir.path.hasSuffix("/") ? dir.path : dir.path + "/"
        return parts.url
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        private var shellLoaded = false
        private var currentBase: URL?
        private var lastHTML: String?
        private var pending: String?

        func loadShell(baseURL: URL?, in web: WKWebView) {
            shellLoaded = false
            currentBase = baseURL
            pending = lastHTML
            web.loadHTMLString(PreviewTemplate.page, baseURL: baseURL)
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
