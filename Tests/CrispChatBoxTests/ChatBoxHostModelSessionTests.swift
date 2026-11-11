@testable import CrispChatBox
import CrispChatBoxFFI
import CrispDomain
import Foundation
import Testing
import TestMocks

@Suite("Session tests")
@MainActor struct ChatBoxHostModelSessionTests {
  /// Loading a fresh session while a previous session still has a registered
  /// device token should carry that token over to the new session. It's
  /// front-queued so that a user-issued `setDeviceToken` for the new launch
  /// still wins, and `resetPrevious` is called.
  @Test func carriesDeviceTokenFromPreviousSession() async {
    let previousToken: DeviceToken = "device-0"
    let newToken: DeviceToken = "device-1"

    let storage = SessionStorage(
      previous: Session(
        websiteId: .mock,
        sessionId: "previous-session",
        settings: .init(deviceToken: previousToken),
      ),
    )

    let api = ChatBoxAPI()
    let model = ChatBoxHostModel(api: api) {
      $0.session = .inMemory(storage: storage)
    }

    let publisher = initializeClient(model: model, sessionId: "session-1")

    // The new launch's host registered a fresh token before the JS bridge came up.
    api.setDeviceToken(newToken)

    let commands = await waitForSessionLoadedEvent(api: api) {
      publisher.onInterfaceLifecycle(.ready)
    }

    #expect(commands.count == 2)
    guard
      case let .setDeviceToken(carriedToken) = commands.first,
      case let .setDeviceToken(setToken) = commands.last
    else {
      Issue.record("Expected [setDeviceToken, setDeviceToken]; got \(commands)")
      return
    }
    #expect(carriedToken == previousToken)
    #expect(setToken == newToken)

    #expect(storage.previous == nil)
    #expect(storage.current?.sessionId == "session-1")
  }

  /// If the persisted current session has a different `sessionId` than the one
  /// we just got from JS, it's stale — carry its registered token over to the
  /// new session, reset the saved session, then save a fresh entry keyed by the
  /// new `sessionId`.
  @Test func resetsStaleSession() async throws {
    let staleToken: DeviceToken = "device-0"
    let newToken: DeviceToken = "device-1"

    let storage = SessionStorage(
      current: Session(
        websiteId: .mock,
        sessionId: "stale-session",
        settings: .init(deviceToken: staleToken),
      ),
    )

    let api = ChatBoxAPI()
    let model = ChatBoxHostModel(api: api) {
      $0.session = .inMemory(storage: storage)
    }

    let evaluator = RecordingJSEvaluator { js in
      js.contains("CrispClient.getSessionIdentifier()") ? "session-1" : nil
    }
    let (bus, publisher) = JSEventBus.inMemory()
    model.onClientInitialized(CrispClient(evaluator: evaluator.asEvaluator(), events: bus))

    api.setDeviceToken(newToken)

    let commands = await waitForSessionLoadedEvent(api: api) {
      publisher.onInterfaceLifecycle(.ready)
    }

    #expect(commands.count == 2)
    guard
      case let .setDeviceToken(carriedToken) = commands.first,
      case let .setDeviceToken(setToken) = commands.last
    else {
      Issue.record("Expected [setDeviceToken, setDeviceToken]; got \(commands)")
      return
    }
    #expect(carriedToken == staleToken)
    #expect(setToken == newToken)

    // Wait until the setDeviceToken command has been dispatched through the JS
    // bridge. By then `flushCommandQueue` has also written the new token into storage.
    try await evaluator.waitForCall { $0.contains("CrispClient.registerNotification") }

    #expect(storage.current?.sessionId == "session-1")
    #expect(storage.current?.settings.deviceToken == newToken)
  }

  /// The carried-over token is stored with the new session right away, so a failed registration
  /// (e.g. while offline) doesn't lose it.
  @Test func keepsCarriedDeviceTokenWhenRegistrationFails() async throws {
    struct Offline: Error {}

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

    let evaluator = RecordingJSEvaluator { js in
      if js.contains("CrispClient.registerNotification") {
        throw Offline()
      }
      return js.contains("CrispClient.getSessionIdentifier()") ? "session-2" : nil
    }
    let (bus, publisher) = JSEventBus.inMemory()
    model.onClientInitialized(CrispClient(evaluator: evaluator.asEvaluator(), events: bus))
    await waitForSessionLoadedEvent(api: api) {
      publisher.onInterfaceLifecycle(.ready)
    }

    try await evaluator.waitForCall(
      matching: { $0.contains("CrispClient.registerNotification") },
      timeout: NSEC_PER_SEC * 5,
    )
    #expect(storage.current?.sessionId == "session-2")
    #expect(storage.current?.settings.deviceToken == "device-0")
  }

  /// First load with no persisted state: nothing to unset or reset, just save
  /// a fresh session keyed by the supplied `sessionId`. That freshly saved
  /// session must also be marked as handed off — otherwise the id would be
  /// re-injected on the next load. This guards the ordering of the save and the
  /// `modifySettings` flip in `widgetIsReady`.
  @Test func savesFreshSessionWhenNoneExists() async {
    let storage = SessionStorage()

    let api = ChatBoxAPI()
    let model = ChatBoxHostModel(api: api) {
      $0.session = .inMemory(storage: storage)
    }
    let publisher = initializeClient(model: model, sessionId: "session-1")

    let commands = await waitForSessionLoadedEvent(api: api) {
      publisher.onInterfaceLifecycle(.ready)
    }

    #expect(commands.isEmpty)
    #expect(storage.previous == nil)
    #expect(storage.current?.sessionId == "session-1")
    #expect(storage.current?.settings.injectedSessionHandedOff == true)
  }

  /// The injected session id is a one-time handoff: the first load of a persisted
  /// session forces its id into the widget so the web client resumes that
  /// conversation (e.g. after migrating from an older SDK version).
  @Test func injectsPersistedSessionIdOnFirstLoad() throws {
    let storage = SessionStorage(
      current: Session(websiteId: .mock, sessionId: "migrated-session"),
    )

    let model = ChatBoxHostModel(api: ChatBoxAPI()) {
      $0.session = .inMemory(storage: storage)
    }

    let html = try #require(model.appear())

    #expect(html.contains("session-id='migrated-session'"))
  }

  /// Once the handoff has completed the web client owns the session, so we stop
  /// injecting the id — otherwise re-forcing a now-stale id on a later load would
  /// resurrect a conversation the user has since reset.
  @Test func stopsInjectingSessionIdAfterHandoff() throws {
    let storage = SessionStorage(
      current: Session(
        websiteId: .mock,
        sessionId: "migrated-session",
        settings: .init(injectedSessionHandedOff: true),
      ),
    )

    let model = ChatBoxHostModel(api: ChatBoxAPI()) {
      $0.session = .inMemory(storage: storage)
    }

    let html = try #require(model.appear())

    #expect(html.contains("session-id=''"))
    #expect(!html.contains("migrated-session"))
  }

  /// Re-loading the same session that's already persisted is a no-op: no
  /// device token should be carried over and the saved session should be left
  /// alone (token included).
  @Test func doesNothingForSameSessionId() async {
    let token: DeviceToken = "device-0"

    let storage = SessionStorage(
      current: Session(
        websiteId: .mock,
        sessionId: "session-1",
        settings: .init(deviceToken: token, pushNotificationsPermissionRequested: true),
      ),
    )

    let api = ChatBoxAPI()
    let model = ChatBoxHostModel(api: api) {
      $0.session = .inMemory(storage: storage)
    }
    let publisher = initializeClient(model: model, sessionId: "session-1")

    let commands = await waitForSessionLoadedEvent(api: api) {
      publisher.onInterfaceLifecycle(.ready)
    }

    #expect(commands.isEmpty)
    #expect(storage.current?.sessionId == "session-1")
    #expect(storage.current?.settings.deviceToken == token)
    #expect(storage.current?.settings.pushNotificationsPermissionRequested == true)
  }

  /// The public `Session.identifier` reads the API, so the loaded session is exposed there before
  /// the host is told about it, and no longer once the host resets.
  @Test func exposesLoadedSessionUntilReset() async {
    let api = ChatBoxAPI()
    let model = ChatBoxHostModel(api: api) {
      $0.session = .inMemory(storage: SessionStorage())
    }
    #expect(api.sessionId == nil)

    var exposedInCallback: SessionId?
    api.addCallback(.sessionLoaded(SessionIdHandler { _ in exposedInCallback = api.sessionId }))

    let publisher = initializeClient(model: model, sessionId: "session-1")
    await waitForSessionLoadedEvent(api: api) {
      publisher.onInterfaceLifecycle(.ready)
    }

    #expect(exposedInCallback == "session-1")
    #expect(api.sessionId == "session-1")

    api.resetSession()
    #expect(api.sessionId == nil)
  }

  /// `Session.isOngoing` reads the API as well. The web client is asked whether the session is
  /// ongoing before the host is told the session has loaded, and a reset clears the answer.
  @Test func exposesWhetherSessionIsOngoing() async {
    let api = ChatBoxAPI()
    let model = ChatBoxHostModel(api: api) {
      $0.session = .inMemory(storage: SessionStorage())
    }
    #expect(!api.isSessionOngoing)

    var ongoingInCallback: Bool?
    api
      .addCallback(.sessionLoaded(SessionIdHandler { _ in
        ongoingInCallback = api.isSessionOngoing
      }))

    let evaluator: JSEvaluator = { js in
      if js.contains("CrispClient.getSessionIdentifier()") {
        return "session-1"
      }
      if js.contains("CrispClient.isSessionOngoing()") {
        return true
      }
      return nil
    }
    let (bus, publisher) = JSEventBus.inMemory()
    model.onClientInitialized(CrispClient(evaluator: evaluator, events: bus))
    await waitForSessionLoadedEvent(api: api) {
      publisher.onInterfaceLifecycle(.ready)
    }

    #expect(ongoingInCallback == true)
    #expect(api.isSessionOngoing)

    api.resetSession()
    #expect(!api.isSessionOngoing)
  }

  /// A session becomes ongoing with its first message, in either direction.
  @Test(arguments: ["onMessageSent", "onMessageReceived"])
  func marksSessionOngoingOnFirstMessage(channel: String) async throws {
    let api = ChatBoxAPI()
    let model = ChatBoxHostModel(api: api) {
      $0.session = .inMemory(storage: SessionStorage())
    }
    let publisher = initializeClient(model: model)
    await waitForSessionLoadedEvent(api: api) {
      publisher.onInterfaceLifecycle(.ready)
    }
    #expect(!api.isSessionOngoing)

    try publisher(channel: channel, body: messageBody())
    #expect(api.isSessionOngoing)
  }

  /// A message that arrives while the web client is still asked whether the session is ongoing
  /// answers that already. The web client's older answer doesn't take it back.
  @Test func keepsMessageMarkWhileQueryingWhetherSessionIsOngoing() async throws {
    let api = ChatBoxAPI()
    let model = ChatBoxHostModel(api: api) {
      $0.session = .inMemory(storage: SessionStorage())
    }
    let ongoingGate = Gate()
    let evaluator = RecordingJSEvaluator { js in
      if js.contains("CrispClient.getSessionIdentifier()") {
        return "session-1"
      }
      if js.contains("CrispClient.isSessionOngoing()") {
        await ongoingGate.wait()
        return false
      }
      return nil
    }
    let (bus, publisher) = JSEventBus.inMemory()
    model.onClientInitialized(CrispClient(evaluator: evaluator.asEvaluator(), events: bus))
    publisher.onInterfaceLifecycle(.ready)
    try await evaluator.waitForCall { $0.contains("CrispClient.isSessionOngoing()") }

    try publisher(channel: "onMessageReceived", body: messageBody())
    await waitForSessionLoadedEvent(api: api) {
      ongoingGate.open()
    }
    #expect(api.isSessionOngoing)
  }

  /// If the web client can't tell whether the session is ongoing, what we know about it stands.
  @Test func keepsSessionOngoingWhenQueryFails() async {
    struct Failure: Error {}

    let api = ChatBoxAPI()
    let model = ChatBoxHostModel(api: api) {
      $0.session = .inMemory(storage: SessionStorage())
    }
    let queryFails = LockIsolated(false)
    let evaluator = RecordingJSEvaluator { js in
      if js.contains("CrispClient.getSessionIdentifier()") {
        return "session-1"
      }
      if js.contains("CrispClient.isSessionOngoing()") {
        if queryFails.value {
          throw Failure()
        }
        return true
      }
      return nil
    }
    let (bus, publisher) = JSEventBus.inMemory()
    model.onClientInitialized(CrispClient(evaluator: evaluator.asEvaluator(), events: bus))
    await waitForSessionLoadedEvent(api: api) {
      publisher.onInterfaceLifecycle(.ready)
    }
    #expect(api.isSessionOngoing)

    // The web client reports ready again on the same page, and this time can't answer.
    queryFails.setValue(true)
    await waitForSessionLoadedEvent(api: api) {
      publisher.onInterfaceLifecycle(.ready)
    }
    #expect(api.isSessionOngoing)
  }

  /// A load that joins another session than the one we knew starts from the web client's answer:
  /// the previous session's messages don't make the new one ongoing.
  @Test func dropsOngoingFlagWhenJoiningAnotherSession() async {
    let api = ChatBoxAPI()
    let model = ChatBoxHostModel(api: api) {
      $0.session = .inMemory(storage: SessionStorage())
    }
    let joinedSessionId = LockIsolated("session-1")
    let joinedSessionIsOngoing = LockIsolated(true)
    let evaluator: JSEvaluator = { js in
      if js.contains("CrispClient.getSessionIdentifier()") {
        return joinedSessionId.value
      }
      if js.contains("CrispClient.isSessionOngoing()") {
        return joinedSessionIsOngoing.value
      }
      return nil
    }
    let (bus, publisher) = JSEventBus.inMemory()
    model.onClientInitialized(CrispClient(evaluator: evaluator, events: bus))
    await waitForSessionLoadedEvent(api: api) {
      publisher.onInterfaceLifecycle(.ready)
    }
    #expect(api.isSessionOngoing)

    // The reloaded web client comes up with a fresh session.
    joinedSessionId.setValue("session-2")
    joinedSessionIsOngoing.setValue(false)
    model.onWebContentProcessTerminated()
    await waitForSessionLoadedEvent(api: api) {
      publisher.onInterfaceLifecycle(.ready)
    }
    #expect(api.sessionId == "session-2")
    #expect(!api.isSessionOngoing)
  }

  /// After a reset, a message from the page we're leaving doesn't make the next session ongoing.
  @Test func doesNotMarkSessionOngoingAfterReset() async throws {
    let api = ChatBoxAPI()
    let model = ChatBoxHostModel(api: api) {
      $0.session = .inMemory(storage: SessionStorage())
    }
    let publisher = initializeClient(model: model)
    await waitForSessionLoadedEvent(api: api) {
      publisher.onInterfaceLifecycle(.ready)
    }

    api.resetSession()
    try publisher(channel: "onMessageReceived", body: messageBody())
    #expect(!api.isSessionOngoing)
  }
}

/// The JSON the web client sends with a message event.
private func messageBody() throws -> String {
  let message = Message(
    content: .text("hi"),
    origin: .chat,
    timestamp: Date(timeIntervalSinceReferenceDate: 0),
    fingerprint: 1,
    from: .operator,
  )
  return try String(decoding: JSONEncoder().encode(message), as: UTF8.self)
}
