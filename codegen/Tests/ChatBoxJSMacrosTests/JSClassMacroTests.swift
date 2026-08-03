#if canImport(ChatBoxJSMacros)
  import ChatBoxJSMacros
  import SwiftSyntaxMacros
  import SwiftSyntaxMacrosTestSupport
  import XCTest

  final class JSClassMacroTests: XCTestCase {
    let macros: [String: Macro.Type] = [
      "JSClass": JSClassMacro.self,
      "JSMethod": JSMethodMacro.self,
      "JSEvent": JSEventMacro.self,
      "CrispActionEvent": CrispActionEventMacro.self,
    ]

    func testBasicExpansion() {
      assertMacroExpansion(
        """
        @JSClass(jsModule: "./crisp-client.js")
        package struct ChatBoxFFI {
            func injectMessage(_ message: Msg) async throws
            func focusOnForeground() async throws
        }
        """,
        expandedSource: ##"""
        package struct ChatBoxFFI {
            @MainActor
            func injectMessage(_ message: Msg) async throws {
                let caller = JSCaller(
                  funcName: "\(Self._jsClassName).injectMessage",
                  evaluator: self.evaluator,
                )
                return try await caller(jsEncode(message))
            }
            @MainActor
            func focusOnForeground() async throws {
                let caller = JSCaller(
                  funcName: "\(Self._jsClassName).focusOnForeground",
                  evaluator: self.evaluator,
                )
                return try await caller()
            }

            private let evaluator: JSEvaluator

            let events: JSEventBus

            static let _jsClassName: String = "ChatBoxFFI"

            @MainActor
            package init(evaluator: @escaping JSEvaluator, events: JSEventBus) {
              self.evaluator = evaluator
              self.events = events
            }

            @MainActor
            package func onEventError(
              _ handler: @MainActor @escaping (String, JSEventError) -> Void,
            ) {
              self.events.onError(handler)
            }

            nonisolated static let generatedJS: String = #"""
            import {
              focusOnForeground,
              injectMessage,
            } from './crisp-client.js'

            window.ChatBoxFFI = {
              focusOnForeground,
              injectMessage,
            }
            """#
        }
        """##,
        macros: self.macros,
      )
    }

    func testEventExpansion() {
      assertMacroExpansion(
        """
        @JSClass(jsModule: "./crisp-client.js")
        package struct ChatBoxFFI {
            @JSEvent
            func onMessageSent(_ handler: @MainActor @escaping (Msg) -> Void)

            @JSEvent
            func onStartNewConversation(_ handler: @MainActor @escaping () -> Void)
        }
        """,
        expandedSource: ##"""
        package struct ChatBoxFFI {
            @MainActor
            func onMessageSent(_ handler: @MainActor @escaping (Msg) -> Void) {
                self.events.register("onMessageSent", JSEventHandler(handler))
            }
            @MainActor
            func onStartNewConversation(_ handler: @MainActor @escaping () -> Void) {
                self.events.register("onStartNewConversation", JSEventHandler(handler))
            }

            private let evaluator: JSEvaluator

            let events: JSEventBus

            static let _jsClassName: String = "ChatBoxFFI"

            @MainActor
            package init(evaluator: @escaping JSEvaluator, events: JSEventBus) {
              self.evaluator = evaluator
              self.events = events
            }

            @MainActor
            package func onEventError(
              _ handler: @MainActor @escaping (String, JSEventError) -> Void,
            ) {
              self.events.onError(handler)
            }

            nonisolated static let generatedJS: String = #"""
            import {
              onMessageSent,
              onStartNewConversation,
            } from './crisp-client.js'

            window.ChatBoxFFI = {

            }

            onMessageSent((payload) => sendEvent('onMessageSent', payload))
            onStartNewConversation((payload) => sendEvent('onStartNewConversation', payload))
            """#
        }
        """##,
        macros: self.macros,
      )
    }

    func testCrispActionEventExpansion() {
      assertMacroExpansion(
        """
        @JSClass(jsModule: "./crisp-client.js")
        package struct ChatBoxFFI {
            @CrispActionEvent("message:sent")
            func onMessageSent(_ handler: @MainActor @escaping (Msg) -> Void)

            @CrispActionEvent("message:received")
            func onMessageReceived(_ handler: @MainActor @escaping (Msg) -> Void)
        }
        """,
        expandedSource: ##"""
        package struct ChatBoxFFI {
            @MainActor
            func onMessageSent(_ handler: @MainActor @escaping (Msg) -> Void) {
                self.events.register("onMessageSent", JSEventHandler(handler))
            }
            @MainActor
            func onMessageReceived(_ handler: @MainActor @escaping (Msg) -> Void) {
                self.events.register("onMessageReceived", JSEventHandler(handler))
            }

            private let evaluator: JSEvaluator

            let events: JSEventBus

            static let _jsClassName: String = "ChatBoxFFI"

            @MainActor
            package init(evaluator: @escaping JSEvaluator, events: JSEventBus) {
              self.evaluator = evaluator
              self.events = events
            }

            @MainActor
            package func onEventError(
              _ handler: @MainActor @escaping (String, JSEventError) -> Void,
            ) {
              self.events.onError(handler)
            }

            nonisolated static let generatedJS: String = #"""
            import {
              on,
            } from './crisp-client.js'

            window.ChatBoxFFI = {

            }

            on("message:received", (payload) => sendEvent("onMessageReceived", payload))
            on("message:sent", (payload) => sendEvent("onMessageSent", payload))
            """#
        }
        """##,
        macros: self.macros,
      )
    }

    func testDiagnoseNonStruct() {
      assertMacroExpansion(
        """
        @JSClass(jsModule: "./m.js")
        class Foo {}
        """,
        expandedSource: """
        class Foo {}
        """,
        diagnostics: [
          .init(message: "@JSClass can only be applied to a struct", line: 1, column: 1),
        ],
        macros: self.macros,
      )
    }
  }
#endif
