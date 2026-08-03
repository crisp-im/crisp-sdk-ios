import CrispDomain
import Foundation
import WebKit

@MainActor package struct JSEventBus {
  package var register: (_ channel: String, _ handler: JSEventHandler) -> Void
  package var onError: (@escaping (String, JSEventError) -> Void) -> Void

  package init(
    register: @escaping (_: String, _: JSEventHandler) -> Void,
    onError: @escaping (@escaping (String, JSEventError) -> Void
    ) -> Void,
  ) {
    self.register = register
    self.onError = onError
  }
}

package extension JSEventBus {
  static func live(controller: WKUserContentController) -> JSEventBus {
    var onError: ((String, JSEventError) -> Void)?

    return JSEventBus(
      register: { channel, handler in
        let messageHandler = ScriptMessageHandler(handler: handler) { error in
          onError?(channel, error)
        }
        controller.add(messageHandler, name: channel)
      },
      onError: { onError = $0 },
    )
  }
}

/// Type-erased event handler. Wraps a typed `(T) -> Void` (or `() -> Void`)
/// closure plus the JSON-decoding step needed to feed it from the raw
/// `WKScriptMessage.body`. Decode failures are surfaced via `throws`; the
/// `JSEventBus` factory routes them to the registered error sink.
@MainActor package struct JSEventHandler {
  private let inner: (Any) throws(JSEventError) -> Void

  package init<T: Decodable>(_ callback: @escaping (T) -> Void) {
    self.inner = { body throws(JSEventError) in
      guard
        let bodyString = body as? String,
        let bodyData = bodyString.data(using: .utf8)
      else {
        throw .badSerialization
      }

      let decoder = JSONDecoder()
      decoder.userInfo[
        ConversationMessageDecodingContext.userInfoKey,
      ] = ConversationMessageDecodingContext()

      do {
        let decodedData = try decoder.decode(T.self, from: bodyData)
        callback(decodedData)
      } catch let error as DecodingError {
        throw .decodingError(
          "JS message body could not be decoded from \"\(bodyString)\": \(error)",
        )
      } catch {
        throw .decodingError("\(error)")
      }
    }
  }

  package init(_ closure: @escaping () -> Void) {
    self.inner = { _ in closure() }
  }

  package func handle(event: Any) throws(JSEventError) {
    try self.inner(event)
  }
}

final class ScriptMessageHandler: NSObject, WKScriptMessageHandler {
  let handler: JSEventHandler
  let onError: (JSEventError) -> Void

  init(
    handler: JSEventHandler,
    onError: @escaping (JSEventError) -> Void,
  ) {
    self.handler = handler
    self.onError = onError
    super.init()
  }

  func userContentController(
    _: WKUserContentController,
    didReceive message: WKScriptMessage,
  ) {
    do {
      try self.handler.handle(event: message.body)
    } catch {
      self.onError(error)
    }
  }
}
