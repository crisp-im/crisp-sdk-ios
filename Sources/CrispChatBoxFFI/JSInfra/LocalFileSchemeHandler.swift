import CrispLogging
import Foundation
import WebKit

package final class LocalFileSchemeHandler: NSObject, WKURLSchemeHandler {
  package static let scheme = "crisp-local"

  private let baseDir: URL

  package init(baseDir: URL) {
    self.baseDir = baseDir
  }

  package func webView(_: WKWebView, start urlSchemeTask: any WKURLSchemeTask) {
    guard let url = urlSchemeTask.request.url else {
      urlSchemeTask.didFailWithError(URLError(.badURL))
      return
    }

    // URL path is the file path relative to baseDir
    // e.g. crisp-local://file/crisp-client.css → path = "/crisp-client.css"
    let path = url.path.hasPrefix("/") ? String(url.path.dropFirst()) : url.path
    let fileURL = self.baseDir.appendingPathComponent(path)

    #if DEBUG
      log.debug("[LocalFileSchemeHandler] \(url) → \(fileURL.path)")
    #endif

    guard let data = try? Data(contentsOf: fileURL) else {
      log.warn("[LocalFileSchemeHandler] File not found: \(fileURL.path)")
      urlSchemeTask.didFailWithError(URLError(.fileDoesNotExist))
      return
    }

    let mimeType = switch fileURL.pathExtension {
    case "html": "text/html"
    case "js": "application/javascript"
    case "css": "text/css"
    case "json": "application/json"
    case "woff": "font/woff"
    case "woff2": "font/woff2"
    case "png": "image/png"
    case "svg": "image/svg+xml"
    case "jpg", "jpeg": "image/jpeg"
    default: "application/octet-stream"
    }

    guard let response = HTTPURLResponse(
      url: url,
      statusCode: 200,
      httpVersion: nil,
      headerFields: [
        "Content-Type": mimeType,
        "Access-Control-Allow-Origin": "*",
      ],
    ) else {
      urlSchemeTask.didFailWithError(URLError(.badURL))
      return
    }

    urlSchemeTask.didReceive(response)
    urlSchemeTask.didReceive(data)
    urlSchemeTask.didFinish()
  }

  package func webView(_: WKWebView, stop _: any WKURLSchemeTask) {}
}
