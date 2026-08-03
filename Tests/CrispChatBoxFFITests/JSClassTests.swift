@testable import CrispChatBoxFFI
import CrispDomain
import Testing
import WebKit

@MainActor @Suite(.serialized)
struct JSBridgeTests {
  @Test func functionCallReturnsString() async throws {
    let (webView, evaluator) = try await makeWebView {
      """
      window.ChatBoxFFI = {
        sayHello: (name) => `Hello ${name}`,
      };
      """
    }

    let sayHello = JSCaller(funcName: "ChatBoxFFI.sayHello", evaluator: evaluator)
    let result: String = try await sayHello(jsEncode("World"))

    #expect(result == "Hello World")
    _ = webView
  }

  @Test func functionCallReturnsSessionId() async throws {
    let (webView, evaluator) = try await makeWebView {
      """
      window.ChatBoxFFI = {
        getSessionIdentifier: () => "Session 123",
      };
      """
    }

    let getSessionIdentifier = JSCaller(
      funcName: "ChatBoxFFI.getSessionIdentifier",
      evaluator: evaluator,
    )
    let result: SessionId = try await getSessionIdentifier()

    #expect(result == "Session 123")
    _ = webView
  }

  @Test func functionCallReturnsStruct() async throws {
    struct MyStruct: Equatable, Decodable {
      var a: String
      var b: Int
    }

    let (webView, evaluator) = try await makeWebView {
      """
      window.ChatBoxFFI = {
        makeStruct: () => ({a: "Hello", b: 42}),
      };
      """
    }

    let makeStruct = JSCaller(funcName: "ChatBoxFFI.makeStruct", evaluator: evaluator)
    let result: MyStruct = try await makeStruct()

    #expect(result == MyStruct(a: "Hello", b: 42))
    _ = webView
  }

  @Test func functionCallReturnsStringAsync() async throws {
    let (webView, evaluator) = try await makeWebView {
      """
      window.ChatBoxFFI = {
        sayHelloAsync: async (name) => {
          await new Promise(resolve => setTimeout(resolve, 10))
          return `Hello ${name}`
        },
      };
      """
    }

    let sayHello = JSCaller(funcName: "ChatBoxFFI.sayHelloAsync", evaluator: evaluator)
    let result: String = try await sayHello(jsEncode("World"))

    #expect(result == "Hello World")
    _ = webView
  }

  @Test func asyncFunctionRejection() async throws {
    let (webView, evaluator) = try await makeWebView {
      """
      window.ChatBoxFFI = {
        boom: async () => { throw new Error("kaboom") },
      };
      """
    }

    let boom = JSCaller(funcName: "ChatBoxFFI.boom", evaluator: evaluator)

    await #expect(throws: (any Error).self) {
      let _: String = try await boom()
    }
    _ = webView
  }

  @Test func asyncFunctionReturningVoid() async throws {
    let (webView, evaluator) = try await makeWebView {
      """
      window.ChatBoxFFI = {
        sideEffect: async () => {
          await new Promise(r => setTimeout(r, 100))
          window.__sideEffectRan = true
        },
      };
      """
    }

    let sideEffect = JSCaller(funcName: "ChatBoxFFI.sideEffect", evaluator: evaluator)
    let _: Void = try await sideEffect()

    // Verify the side effect actually happened (i.e. we really awaited).
    let ran: Bool = try await {
      let raw = try await evaluator("return window.__sideEffectRan === true")
      return (raw as? Bool) ?? false
    }()
    #expect(ran)
    _ = webView
  }
}

private extension JSBridgeTests {
  private func makeWebView(js: () -> String) async throws -> (WKWebView, JSEvaluator) {
    let html = """
      <html>
      <body>
      <script type="module">
        \(js())
      </script>
      </body>
      </html>
    """

    let contentController = WKUserContentController()

    let configuration = WKWebViewConfiguration()
    configuration.userContentController = contentController

    let webView = WKWebView(frame: .zero, configuration: configuration)

    try await confirmation("Page loaded") { confirm in
      webView.loadHTMLString(html, baseURL: nil)

      try await withCheckedThrowingContinuation { continuation in
        contentController.addDOMReadyHandler {
          continuation.resume()
          confirm()
        }
      }
    }

    return (webView, webView.crisp_makeJSEvaluator())
  }
}

extension WKUserContentController {
  func addDOMReadyHandler(_ handler: @escaping () -> Void) {
    let script = """
    function waitForChatBoxFFI() {
      if (window.ChatBoxFFI !== undefined) {
        window.webkit.messageHandlers.domReady.postMessage({});
        return;
      }

      const interval = setInterval(() => {
        if (window.ChatBoxFFI !== undefined) {
          clearInterval(interval);
          window.webkit.messageHandlers.domReady.postMessage({});
        }
      }, 50);
    }

    if (document.readyState === 'complete') {
      waitForChatBoxFFI();
    } else {
      window.addEventListener('load', function() {
        waitForChatBoxFFI();
      });
    }
    """

    let scriptMessageHandler = ScriptMessageHandler(
      handler: .init(handler),
      onError: { Issue.record($0) },
    )

    self.add(scriptMessageHandler, name: "domReady")
    self.addUserScript(
      WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true),
    )
  }
}
