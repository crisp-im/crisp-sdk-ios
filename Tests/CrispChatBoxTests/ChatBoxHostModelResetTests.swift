@testable import CrispChatBox
import CrispChatBoxFFI
import CrispDomain
import Foundation
import Testing
import TestMocks

@Suite("Reset tests")
@MainActor struct ChatBoxHostModelResetTests {
  /// Login flow: `setTokenID` + `session.reset()` + user data while the chat is closed. The
  /// reset has to be applied on boot, never in the loaded widget — its runtime reset would
  /// replace the user's token session the widget just joined with an empty one.
  @Test func appliesPendingResetOnBoot() async throws {
    let api = ChatBoxAPI()
    api.configureTokenId("user-token")
    api.resetSession()
    api.setEmail("alice@example.com", signature: nil)

    let model = ChatBoxHostModel(api: api) {
      $0.session = .inMemory(storage: SessionStorage())
    }
    let html = try model.loadBaseHTML()

    #expect(model.bootReset != nil)
    #expect(html.contains("token-id='user-token'"))

    let evaluator = RecordingJSEvaluator { js in
      js.contains("CrispClient.getSessionIdentifier()") ? "token-session" : nil
    }
    let (bus, publisher) = JSEventBus.inMemory()
    model.onClientInitialized(CrispClient(evaluator: evaluator.asEvaluator(), events: bus))
    publisher.onInterfaceLifecycle(.ready)

    try await evaluator.waitForCall { $0.contains("CrispClient.setUserEmail") }
    #expect(!evaluator.calls.contains { $0.contains("CrispClient.reset") })
    #expect(api.commands.pendingReset == nil)
    #expect(model.bootReset == nil)
  }

  /// The reset stays pending until a boot completes, so a retry after a failed boot (or a new
  /// chat after the model went away) still boots with cleared storage.
  @Test func keepsResetPendingUntilBootCompletes() throws {
    let api = ChatBoxAPI()
    api.resetSession()

    _ = try ChatBoxHostModel(api: api).loadBaseHTML()
    #expect(api.commands.pendingReset != nil)

    let model = ChatBoxHostModel(api: api)
    _ = try model.loadBaseHTML()
    #expect(model.bootReset != nil)
  }

  /// Logout followed by the app being killed before the chat was opened: the reset is persisted,
  /// so the next launch still boots with cleared storage instead of restoring the old session.
  @Test func appliesPersistedResetAfterRelaunch() async throws {
    let storage = SessionStorage()
    ChatBoxAPI(session: .inMemory(storage: storage)).resetSession()
    #expect(storage.isResetPending)

    let api = ChatBoxAPI(session: .inMemory(storage: storage))
    let model = ChatBoxHostModel(api: api) {
      $0.session = .inMemory(storage: storage)
    }
    let html = try model.loadBaseHTML()

    #expect(model.bootReset != nil)
    #expect(html.contains("if ('true' === 'true')"))

    let publisher = initializeClient(model: model, sessionId: "session-1")
    await waitForSessionLoadedEvent(api: api) {
      publisher.onInterfaceLifecycle(.ready)
    }

    #expect(api.commands.pendingReset == nil)
    #expect(!storage.isResetPending)
  }

  /// A boot that started before a newer reset doesn't complete it, so the marker survives too.
  @Test func keepsPersistedMarkerForNewerReset() throws {
    let storage = SessionStorage()
    let api = ChatBoxAPI(session: .inMemory(storage: storage))
    api.resetSession()
    let applied = try #require(api.commands.pendingReset)

    api.resetSession()
    api.commands.completeReset(applied)

    #expect(api.commands.pendingReset != nil)
    #expect(storage.isResetPending)
  }

  @Test func bootsWithoutResetWhenNoneIsPending() throws {
    let model = ChatBoxHostModel(api: ChatBoxAPI())
    _ = try model.loadBaseHTML()

    #expect(model.bootReset == nil)
  }

  /// A reset requested while the widget boots (e.g. login while the chat is loading) makes the
  /// joined session obsolete, so the widget reboots instead of reporting it as loaded.
  @Test func rebootsWhenResetArrivesDuringBoot() async throws {
    let storage = SessionStorage()
    let api = ChatBoxAPI()
    let model = ChatBoxHostModel(api: api) {
      $0.session = .inMemory(storage: storage)
    }
    var didReload = false
    model.onRetry = { didReload = true }

    _ = try model.loadBaseHTML()
    let publisher = initializeClient(model: model)
    api.resetSession()
    publisher.onInterfaceLifecycle(.ready)

    await waitUntil { didReload }
    #expect(didReload)
    #expect(storage.current == nil)
    _ = try model.loadBaseHTML()
    #expect(model.bootReset != nil)
  }

  /// An already loaded (e.g. embedded) chat deregisters the device from the session it leaves,
  /// then reboots to apply the reset.
  @Test func rebootsLoadedChatOnReset() async throws {
    let storage = SessionStorage(
      current: Session(
        websiteId: .mock,
        sessionId: "session-1",
        settings: .init(deviceToken: "device-0"),
      ),
    )
    let api = ChatBoxAPI()
    let model = ChatBoxHostModel(api: api) {
      $0.session = .inMemory(storage: storage)
    }
    var didReload = false
    model.onRetry = { didReload = true }

    let evaluator = RecordingJSEvaluator { js in
      js.contains("CrispClient.getSessionIdentifier()") ? "session-1" : nil
    }
    let (bus, publisher) = JSEventBus.inMemory()
    model.onClientInitialized(CrispClient(evaluator: evaluator.asEvaluator(), events: bus))
    await waitForSessionLoadedEvent(api: api) {
      publisher.onInterfaceLifecycle(.ready)
    }

    api.resetSession()

    try await evaluator.waitForCall { $0.contains("CrispClient.unregisterNotification") }
    await waitUntil { didReload }
    #expect(didReload)
    #expect(!evaluator.calls.contains { $0.contains("CrispClient.reset") })
    #expect(storage.current?.settings.deviceToken == "device-0")
  }

  /// If deregistering hangs until the widget timeout fires, the reload must not go ahead
  /// behind the error screen once the call returns.
  @Test func doesNotReloadAfterTimeoutDuringResetPrelude() async throws {
    let storage = SessionStorage(
      current: Session(
        websiteId: .mock,
        sessionId: "session-1",
        settings: .init(deviceToken: "device-0"),
      ),
    )
    let api = ChatBoxAPI()
    let model = ChatBoxHostModel(api: api, widgetReadyTimeout: NSEC_PER_MSEC * 50) {
      $0.session = .inMemory(storage: storage)
    }
    var didReload = false
    model.onRetry = { didReload = true }

    let evaluator = RecordingJSEvaluator { js in
      if js.contains("CrispClient.unregisterNotification") {
        try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 200)
      }
      return js.contains("CrispClient.getSessionIdentifier()") ? "session-1" : nil
    }
    let (bus, publisher) = JSEventBus.inMemory()
    model.onClientInitialized(CrispClient(evaluator: evaluator.asEvaluator(), events: bus))
    await waitForSessionLoadedEvent(api: api) {
      publisher.onInterfaceLifecycle(.ready)
    }

    api.resetSession()

    try await evaluator.waitForCall { $0.contains("CrispClient.unregisterNotification") }
    try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 400)

    guard case .error = model.state else {
      Issue.record("Expected error state; got \(model.state)")
      return
    }
    #expect(!didReload)
  }

  /// The old web view is still live while the reset prelude runs. A script error from it must not
  /// stop the reload that replaces it.
  @Test func ignoresScriptErrorsDuringResetPrelude() async throws {
    let storage = SessionStorage(
      current: Session(
        websiteId: .mock,
        sessionId: "session-1",
        settings: .init(deviceToken: "device-0"),
      ),
    )
    let api = ChatBoxAPI()
    let model = ChatBoxHostModel(api: api) {
      $0.session = .inMemory(storage: storage)
    }
    var didReload = false
    model.onRetry = { didReload = true }

    let evaluator = RecordingJSEvaluator { js in
      if js.contains("CrispClient.unregisterNotification") {
        try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 100)
      }
      return js.contains("CrispClient.getSessionIdentifier()") ? "session-1" : nil
    }
    let (bus, publisher) = JSEventBus.inMemory()
    model.onClientInitialized(CrispClient(evaluator: evaluator.asEvaluator(), events: bus))
    await waitForSessionLoadedEvent(api: api) {
      publisher.onInterfaceLifecycle(.ready)
    }

    api.resetSession()

    try await evaluator.waitForCall { $0.contains("CrispClient.unregisterNotification") }
    publisher.onScriptError(message: "boom")

    await waitUntil { didReload }
    #expect(didReload)
    #expect(model.state.isLoading)
  }

  /// Completing a boot reset discards the stored native session with its settings, and the
  /// device token is carried over to the new session.
  @Test func replacesStoredSessionOnBootReset() async {
    let storage = SessionStorage(
      current: Session(
        websiteId: .mock,
        sessionId: "session-1",
        settings: .init(
          deviceToken: "device-0",
          pushNotificationsPermissionRequested: true,
          injectedSessionHandedOff: true,
        ),
      ),
    )
    let api = ChatBoxAPI()
    api.resetSession()
    let model = ChatBoxHostModel(api: api) {
      $0.session = .inMemory(storage: storage)
    }

    _ = try? model.loadBaseHTML()
    let publisher = initializeClient(model: model, sessionId: "session-1")
    let commands = await waitForSessionLoadedEvent(api: api) {
      publisher.onInterfaceLifecycle(.ready)
    }

    guard case let .setDeviceToken(token) = commands.first else {
      Issue.record("Expected [setDeviceToken]; got \(commands)")
      return
    }
    #expect(token == "device-0")
    #expect(storage.previous == nil)
    #expect(storage.current?.sessionId == "session-1")
    #expect(storage.current?.settings.pushNotificationsPermissionRequested == false)
  }

  /// The reset discards the session, so a not-yet-handed-off session id must not be injected.
  @Test func doesNotInjectPersistedSessionIdWhenResetting() throws {
    let storage = SessionStorage(
      current: Session(websiteId: .mock, sessionId: "migrated-session"),
    )

    let api = ChatBoxAPI()
    api.resetSession()

    let model = ChatBoxHostModel(api: api) {
      $0.session = .inMemory(storage: storage)
    }

    let html = try model.loadBaseHTML()

    #expect(html.contains("session-id=''"))
  }

  /// Device registration belongs to the app install, so a reset must not drop it.
  @Test func resetKeepsPendingDeviceToken() {
    let api = ChatBoxAPI()
    api.setDeviceToken("device-0")
    api.setNickname("Alice")
    api.resetSession()

    let commands = api.commands.commands
    #expect(commands.count == 1)
    guard case .setDeviceToken = commands.first else {
      Issue.record("Expected [setDeviceToken]; got \(commands)")
      return
    }
  }
}
