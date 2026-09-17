import UniformTypeIdentifiers
import WebKit

/// Serves `markpad:///absolute/path` from disk so the preview can show images relative to the document.
final class LocalFileSchemeHandler: NSObject, WKURLSchemeHandler {
    static let scheme = "markpad"

    /// Maps a `markpad://` link back to a `file://` URL; other URLs pass through untouched.
    static func externalURL(for url: URL) -> URL {
        url.scheme == scheme ? URL(fileURLWithPath: url.path) : url
    }

    func webView(_ webView: WKWebView, start task: WKURLSchemeTask) {
        guard let url = task.request.url else { return }
        let path = url.path
        guard let data = FileManager.default.contents(atPath: path) else {
            task.didFailWithError(URLError(.fileDoesNotExist))
            return
        }
        let ext = (path as NSString).pathExtension
        let mime = UTType(filenameExtension: ext)?.preferredMIMEType ?? "application/octet-stream"
        task.didReceive(URLResponse(url: url, mimeType: mime, expectedContentLength: data.count, textEncodingName: nil))
        task.didReceive(data)
        task.didFinish()
    }

    func webView(_ webView: WKWebView, stop task: WKURLSchemeTask) {}
}
