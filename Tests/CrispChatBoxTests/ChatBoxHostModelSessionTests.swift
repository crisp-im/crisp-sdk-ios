@testable import CrispChatBox
import CrispChatBoxFFI
import CrispDomain
import Foundation
import Testing
import TestMocks

@Suite("Session tests")
@MainActor struct ChatBoxHostModelSessionTests {
  /// Loading a fresh session while a previous session still has a registered
  /// device token should front-queue an `unsetDeviceToken` for the *old* token
  /// (so it doesn't clobber any user-issued `setDeviceToken` for the new launch)
  /// and then call `resetPrevious`.
  @Test func resetsPreviousSession() async {
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
      case let .unsetDeviceToken(unsetToken) = commands.first,
      case let .setDeviceToken(setToken) = commands.last
    else {
      Issue.record("Expected [unsetDeviceToken, setDeviceToken]; got \(commands)")
      return
    }
    #expect(unsetToken == previousToken)
    #expect(setToken == newToken)

    #expect(storage.previous == nil)
    #expect(storage.current?.sessionId == "session-1")
  }

  /// If the persisted current session has a different `sessionId` than the one
  /// we just got from JS, it's stale — front-queue an `unsetDeviceToken` for
  /// its registered token, reset the saved session, then save a fresh entry
  /// keyed by the new `sessionId`.
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
      case let .unsetDeviceToken(unsetToken) = commands.first,
      case let .setDeviceToken(setToken) = commands.last
    else {
      Issue.record("Expected [unsetDeviceToken, setDeviceToken]; got \(commands)")
      return
    }
    #expect(unsetToken == staleToken)
    #expect(setToken == newToken)

    // Wait until the setDeviceToken command has been dispatched through the JS
    // bridge. By then `flushCommandQueue` has also written the new token into storage.
    try await evaluator.waitForCall { $0.contains("CrispClient.registerNotification") }

    #expect(storage.current?.sessionId == "session-1")
    #expect(storage.current?.settings.deviceToken == newToken)
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

    let html = try model.loadBaseHTML()

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

    let html = try model.loadBaseHTML()

    #expect(html.contains("session-id=''"))
    #expect(!html.contains("migrated-session"))
  }

  /// Re-loading the same session that's already persisted is a no-op: no
  /// `unsetDeviceToken` should be enqueued and the saved session should be left
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
}
