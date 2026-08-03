@testable import CrispChatBox
import CrispChatBoxFFI
import Testing

@Suite("Script error handling tests")
@MainActor struct ChatBoxHostModelScriptErrorTests {
  /// A script error during the loading phase is fatal — it usually means the
  /// bundled JS module didn't load — so the model should transition into
  /// `.error`.
  @Test func recordsScriptErrorDuringLoading() {
    let model = ChatBoxHostModel {
      $0.notifications = .noop
    }
    let (bus, publisher) = JSEventBus.inMemory()
    let client = CrispClient(evaluator: { _ in nil }, events: bus)

    model.onAppear(isPresented: false)
    model.onClientInitialized(client)

    #expect(model.state.isLoading)

    publisher.onScriptError(message: "boom")

    guard
      case let .error(failureModel) = model.state,
      case let .scriptError(payload) = failureModel.error
    else {
      Issue.record("Expected state == .error(.scriptError(...)); got \(model.state)")
      return
    }
    #expect(payload.message == "boom")
  }

  /// Once the chatbox is up, a script error is usually a one-off
  /// (e.g. an unsupported `.ogg` playback) and shouldn't tear down a working UI.
  @Test func ignoresScriptErrorAfterLoading() {
    let model = ChatBoxHostModel {
      $0.notifications = .noop
    }
    let (bus, publisher) = JSEventBus.inMemory()
    let client = CrispClient(evaluator: { _ in nil }, events: bus)

    model.onAppear(isPresented: false)
    model.onClientInitialized(client)

    // Drive into `.loaded` by firing `onInterfaceLifecycle` with `state: "ready"`.
    // `widgetIsReady` then kicks off async work via `getSessionIdentifier()`,
    // which will fail against our nil-returning evaluator stub — that's fine,
    // we only care that `state` synchronously transitioned to `.loaded`.
    publisher.onInterfaceLifecycle(.ready)
    #expect(model.state == .loaded)

    publisher.onScriptError(message: "ignored")

    #expect(model.state == .loaded)
  }

  /// Non-script errors (e.g. an event payload we couldn't decode) propagate
  /// regardless of phase.
  @Test func forwardsDecodingErrorWhileLoaded() {
    let model = ChatBoxHostModel()
    let (bus, publisher) = JSEventBus.inMemory()
    let client = CrispClient(evaluator: { _ in nil }, events: bus)
    model.onClientInitialized(client)

    publisher.onInterfaceLifecycle(.ready)
    #expect(model.state == .loaded)

    // Malformed body on a typed channel → the bus's onError sink fires →
    // model.onError(.eventDecodingFailed(...)) → state should flip to `.error`.
    publisher(channel: "onMessageSent", body: "invalid-json")

    guard
      case let .error(failureModel) = model.state,
      case .eventDecodingFailed = failureModel.error
    else {
      Issue.record("Expected state == .error(.eventDecodingFailed(...)); got \(model.state)")
      return
    }
  }
}
