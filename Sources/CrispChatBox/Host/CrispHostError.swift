import CrispChatBoxFFI
import Foundation

enum CrispHostError: Equatable {
  case client(CrispClientError)

  /// A JS-side event payload could not be decoded into its expected typed
  /// model. Includes the event channel and the underlying decoding error so
  /// the host can log / report it.
  case eventDecodingFailed(channel: String, underlying: JSEventError)

  /// An uncaught JS error or unhandled promise rejection fired in the
  /// IndexHTML script before (or after) module initialization. Surfaces
  /// module-load failures (missing imports, syntax errors) immediately
  /// instead of waiting for the DOM-ready timeout.
  case scriptError(CrispClient.ScriptErrorEvent)

  /// The JS widget never fired its `interfaceLifecycle(.ready)` event within
  /// the allotted window. Usually means the bundled `crisp-client.js` failed
  /// to evaluate without surfacing an uncaught error (e.g. an `async`
  /// startup path that hung).
  case widgetTimeout

  case webViewNotInstalled
}

extension CrispHostError: LocalizedError {
  var errorDescription: String? {
    self.localizedDescription
  }

  var localizedDescription: String {
    switch self {
    case let .client(error):
      return error.localizedDescription
    case let .eventDecodingFailed(channel, underlying):
      return "Failed to decode payload for event '\(channel)': \(underlying)"
    case let .scriptError(payload):
      var parts: [String] = []
      if let file = payload.filename { parts.append(file) }
      if let line = payload.line { parts.append(String(line)) }
      if let col = payload.col { parts.append(String(col)) }
      let location = parts.joined(separator: ":")
      let suffix = location.isEmpty ? "" : " [\(location)]"
      return "JS \(payload.source.rawValue) — \(payload.message)\(suffix)"
    case .widgetTimeout:
      return "Crisp widget did not become ready in time."
    case .webViewNotInstalled:
      return "The WebView was not installed in time."
    }
  }
}
