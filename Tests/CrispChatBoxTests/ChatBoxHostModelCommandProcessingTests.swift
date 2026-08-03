@testable import CrispChatBox
import CrispChatBoxFFI
import CrispDomain
import Testing
import TestMocks

@Suite("Command processing tests")
@MainActor struct ChatBoxHostModelCommandProcessingTests {
  /// Commands enqueued *after* the initial `flushCommandQueue` (i.e. after
  /// `widgetIsReady` has drained and dispatched the queued batch) should also
  /// flow through to the JS bridge via the `setOnAppendHandler` continuation.
  @Test func continuouslyProcessesCommands() async throws {
    let api = ChatBoxAPI()
    let model = ChatBoxHostModel(api: api)

    let evaluator = RecordingJSEvaluator { js in
      js.contains("CrispClient.getSessionIdentifier()")
        ? "session-1"
        : nil
    }
    let (bus, publisher) = JSEventBus.inMemory()
    let client = CrispClient(evaluator: evaluator.asEvaluator(), events: bus)
    model.onClientInitialized(client)

    await waitForSessionLoadedEvent(api: api) {
      publisher.onInterfaceLifecycle(.ready)
    }

    #expect(api.commands.commands.isEmpty)

    api.setNickname("Alice")

    try await evaluator.waitForCall { $0.contains("CrispClient.setUserNickname") }
  }
}
