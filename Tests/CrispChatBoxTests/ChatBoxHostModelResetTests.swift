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
    let html = try #require(model.appear())

    #expect(html.clearsWebStorage)
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
  }

  /// The reset stays pending until a boot completes, so a retry after a failed boot (or a new
  /// chat after the model went away) still boots with cleared storage.
  @Test func keepsResetPendingUntilBootCompletes() throws {
    let api = ChatBoxAPI()
    api.resetSession()

    ChatBoxHostModel(api: api).appear()
    #expect(api.commands.pendingReset != nil)

    let html = try #require(ChatBoxHostModel(api: api).appear())
    #expect(html.clearsWebStorage)
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
    let html = try #require(model.appear())

    #expect(html.clearsWebStorage)

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
    let html = try #require(ChatBoxHostModel(api: ChatBoxAPI()).appear())

    #expect(!html.clearsWebStorage)
  }

  /// A reset requested while the widget boots (e.g. login while the chat is loading) makes the
  /// joined session obsolete, so the widget reboots instead of reporting it as loaded.
  @Test func rebootsWhenResetArrivesDuringBoot() async {
    let storage = SessionStorage()
    let api = ChatBoxAPI()
    let model = ChatBoxHostModel(api: api) {
      $0.session = .inMemory(storage: storage)
    }
    model.appear()
    var reloadedTemplate: String?
    model.onLoadTemplate = { reloadedTemplate = $0 }
    var states = [ChatBoxHostModel.State]()
    model.onStateChange = { states.append(model.state) }

    let publisher = initializeClient(model: model)
    api.resetSession()
    publisher.onInterfaceLifecycle(.ready)

    await waitUntil { reloadedTemplate != nil }
    #expect(storage.current == nil)
    #expect(reloadedTemplate?.clearsWebStorage == true)
    // The obsolete session is never revealed, not even briefly.
    #expect(!states.contains(.loaded))
  }

  /// Logout, then a login while the chat loads: the boot applying the logout joins a fresh
  /// anonymous session and reboots for the login straight away. The device was never registered
  /// with that session and the one holding it can't be reached, so nothing is deregistered.
  @Test func doesNotDeregisterFromSessionItNeverAdopted() async {
    let storage = SessionStorage(
      current: Session(
        websiteId: .mock,
        sessionId: "session-1",
        settings: .init(deviceToken: "device-0"),
      ),
    )
    let api = ChatBoxAPI()
    api.resetSession()
    let model = ChatBoxHostModel(api: api) {
      $0.session = .inMemory(storage: storage)
    }
    model.appear()
    var reloadedTemplate: String?
    model.onLoadTemplate = { reloadedTemplate = $0 }

    let evaluator = RecordingJSEvaluator { js in
      js.contains("CrispClient.getSessionIdentifier()") ? "anonymous-session" : nil
    }
    let (bus, publisher) = JSEventBus.inMemory()
    model.onClientInitialized(CrispClient(evaluator: evaluator.asEvaluator(), events: bus))

    api.configureTokenId("user-token")
    api.resetSession()
    publisher.onInterfaceLifecycle(.ready)

    await waitUntil { reloadedTemplate != nil }
    #expect(reloadedTemplate?.contains("token-id='user-token'") == true)
    #expect(!evaluator.calls.contains { $0.contains("CrispClient.unregisterNotification") })
  }

  /// A host that resets in its session-loaded callback reboots the widget right away. The load
  /// that ended this way must not go on to check for the push prompt on the page being replaced.
  @Test func stopsLoadWorkWhenItRebootsItself() async {
    let api = ChatBoxAPI()
    let model = ChatBoxHostModel(api: api) {
      $0.session = .inMemory(storage: SessionStorage())
    }
    var reloadedTemplate: String?
    model.onLoadTemplate = { reloadedTemplate = $0 }
    api.addCallback(.sessionLoaded(SessionIdHandler { _ in api.resetSession() }))

    let evaluator = RecordingJSEvaluator { js in
      js.contains("CrispClient.getSessionIdentifier()") ? "session-1" : nil
    }
    let (bus, publisher) = JSEventBus.inMemory()
    model.onClientInitialized(CrispClient(evaluator: evaluator.asEvaluator(), events: bus))
    publisher.onInterfaceLifecycle(.ready)

    await waitUntil { reloadedTemplate != nil }
    #expect(reloadedTemplate?.clearsWebStorage == true)

    // Nothing may happen now, which can't be awaited: give a wrong prompt check a chance to run.
    await waitUntil(timeout: NSEC_PER_MSEC * 200) {
      evaluator.calls.contains { $0.contains("CrispClient.getMessages") }
    }
    #expect(!evaluator.calls.contains { $0.contains("CrispClient.getMessages") })
  }

  /// The web client may report ready again while loaded. A reset that arrives before the new load
  /// has adopted the session again still deregisters the device from that session.
  @Test func keepsJoinedSessionAcrossRepeatedReady() async throws {
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

    let holdsSessionId = LockIsolated(false)
    let sessionIdGate = Gate()
    let evaluator = RecordingJSEvaluator { js in
      guard js.contains("CrispClient.getSessionIdentifier()") else { return nil }
      if holdsSessionId.value {
        await sessionIdGate.wait()
      }
      return "session-1"
    }
    let (bus, publisher) = JSEventBus.inMemory()
    model.onClientInitialized(CrispClient(evaluator: evaluator.asEvaluator(), events: bus))
    await waitForSessionLoadedEvent(api: api) {
      publisher.onInterfaceLifecycle(.ready)
    }

    holdsSessionId.setValue(true)
    publisher.onInterfaceLifecycle(.ready)
    api.resetSession()

    try await evaluator.waitForCall(
      matching: { $0.contains("CrispClient.unregisterNotification") },
      timeout: NSEC_PER_SEC * 2,
    )
    sessionIdGate.open()
  }

  /// A reset while a reload is still asking the web client for its session supersedes that load,
  /// so the session it reports must not be adopted or announced.
  @Test func doesNotAdoptSessionOfSupersededLoad() async {
    let storage = SessionStorage(current: Session(websiteId: .mock, sessionId: "session-1"))
    let api = ChatBoxAPI()
    let model = ChatBoxHostModel(api: api) {
      $0.session = .inMemory(storage: storage)
    }

    let holdsSessionId = LockIsolated(false)
    let sessionIdGate = Gate()
    let evaluator = RecordingJSEvaluator { js in
      guard js.contains("CrispClient.getSessionIdentifier()") else { return nil }
      guard holdsSessionId.value else { return "session-1" }
      await sessionIdGate.wait()
      return "session-2"
    }
    let (bus, publisher) = JSEventBus.inMemory()
    model.onClientInitialized(CrispClient(evaluator: evaluator.asEvaluator(), events: bus))
    await waitForSessionLoadedEvent(api: api) {
      publisher.onInterfaceLifecycle(.ready)
    }

    holdsSessionId.setValue(true)
    model.onWebContentProcessTerminated()
    publisher.onInterfaceLifecycle(.ready)
    await waitUntil {
      evaluator.calls.count { $0.contains("CrispClient.getSessionIdentifier()") } == 2
    }

    var announcedSessionIds = [SessionId]()
    api.addCallback(.sessionLoaded(SessionIdHandler { announcedSessionIds.append($0) }))
    api.resetSession()
    await waitUntil { model.state.isLoading }
    #expect(model.state.isLoading)

    sessionIdGate.open()

    // Nothing may happen now, which can't be awaited: give a wrong adoption a chance to show up.
    await waitUntil(timeout: NSEC_PER_MSEC * 200) { storage.current?.sessionId == "session-2" }
    #expect(storage.current?.sessionId == "session-1")
    #expect(announcedSessionIds.isEmpty)
  }

  /// A login while the reset reload is still deregistering the device (setTokenID + reset during
  /// the prelude) goes into the template that reload loads, so it boots straight into the new
  /// token's session instead of booting stale and rebooting.
  @Test func appliesChangesFromDuringPreludeToReloadedTemplate() async throws {
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
    var templates = [String]()
    model.onLoadTemplate = { templates.append($0) }

    let unregisterGate = Gate()
    let evaluator = RecordingJSEvaluator { js in
      if js.contains("CrispClient.unregisterNotification") {
        await unregisterGate.wait()
      }
      return js.contains("CrispClient.getSessionIdentifier()") ? "session-1" : nil
    }
    let (bus, publisher) = JSEventBus.inMemory()
    model.onClientInitialized(CrispClient(evaluator: evaluator.asEvaluator(), events: bus))
    await waitForSessionLoadedEvent(api: api) {
      publisher.onInterfaceLifecycle(.ready)
    }

    api.resetSession()
    try await evaluator.waitForCall(
      matching: { $0.contains("CrispClient.unregisterNotification") },
      timeout: NSEC_PER_SEC * 5,
    )
    api.configureTokenId("other-token")
    api.resetSession()
    #expect(templates.isEmpty)
    unregisterGate.open()

    await waitUntil { !templates.isEmpty }
    let template = try #require(templates.first)
    #expect(template.clearsWebStorage)
    #expect(template.contains("token-id='other-token'"))

    // A stale template would leave the second reset pending, which reboots right away.
    publisher.onInterfaceLifecycle(.ready)
    #expect(api.commands.pendingReset == nil)
    #expect(model.state == .loaded)
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
    model.onLoadTemplate = { _ in didReload = true }

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
    model.onLoadTemplate = { _ in didReload = true }

    let unregisterGate = Gate()
    let evaluator = RecordingJSEvaluator { js in
      if js.contains("CrispClient.unregisterNotification") {
        await unregisterGate.wait()
      }
      return js.contains("CrispClient.getSessionIdentifier()") ? "session-1" : nil
    }
    let (bus, publisher) = JSEventBus.inMemory()
    model.onClientInitialized(CrispClient(evaluator: evaluator.asEvaluator(), events: bus))
    await waitForSessionLoadedEvent(api: api) {
      publisher.onInterfaceLifecycle(.ready)
    }

    api.resetSession()

    try await evaluator.waitForCall(
      matching: { $0.contains("CrispClient.unregisterNotification") },
      timeout: NSEC_PER_SEC * 5,
    )
    await waitUntil {
      if case .error = model.state { return true }
      return false
    }
    guard case .error = model.state else {
      Issue.record("Expected error state; got \(model.state)")
      return
    }

    unregisterGate.open()

    // Nothing may happen now, which can't be awaited: give a wrong reload a chance to show up.
    await waitUntil(timeout: NSEC_PER_MSEC * 200) { didReload }
    #expect(!didReload)
    if case .error = model.state {} else {
      Issue.record("Expected error state; got \(model.state)")
    }
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
    model.onLoadTemplate = { _ in didReload = true }

    let unregisterGate = Gate()
    let evaluator = RecordingJSEvaluator { js in
      if js.contains("CrispClient.unregisterNotification") {
        await unregisterGate.wait()
      }
      return js.contains("CrispClient.getSessionIdentifier()") ? "session-1" : nil
    }
    let (bus, publisher) = JSEventBus.inMemory()
    model.onClientInitialized(CrispClient(evaluator: evaluator.asEvaluator(), events: bus))
    await waitForSessionLoadedEvent(api: api) {
      publisher.onInterfaceLifecycle(.ready)
    }

    api.resetSession()

    try await evaluator.waitForCall(
      matching: { $0.contains("CrispClient.unregisterNotification") },
      timeout: NSEC_PER_SEC * 5,
    )
    publisher.onScriptError(message: "boom")
    #expect(model.state.isLoading)

    unregisterGate.open()
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

    model.appear()
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

    let html = try #require(model.appear())

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
