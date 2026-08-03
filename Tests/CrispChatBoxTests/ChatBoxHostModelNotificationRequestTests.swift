@testable import CrispChatBox
import CrispChatBoxFFI
import CrispDomain
import Foundation
import Testing
import TestMocks

@Suite("Push notification request tests")
@MainActor struct ChatBoxHostModelNotificationRequestTests {
  /// A click on a picker that isn't our notification-permission prompt is a
  /// no-op: settings stay untouched and no permission request fires.
  @Test func ignoresUnrelatedFingerprint() async throws {
    let storage = SessionStorage(current: .mock)
    let recorder = NotificationsRecorder()

    let model = ChatBoxHostModel { env in
      env.session = .inMemory(storage: storage)
      env.notifications = .recording(into: recorder)
    }
    let publisher = initializeClient(model: model)

    publisher.onPickerClick(fingerprint: 9999, choice: "enable")

    try await self.wait()
    #expect(storage.current?.settings.pushNotificationsPermissionRequested == false)
    #expect(recorder.permissionRequestCount == 0)
  }

  /// "Enable Notifications" choice flips the persisted flag *and* asks the
  /// notifications client for permission.
  @Test func savesChoiceAndRequestsPermissionForEnableChoice() async throws {
    let storage = SessionStorage(current: .mock)
    let recorder = NotificationsRecorder()

    let model = ChatBoxHostModel { env in
      env.session = .inMemory(storage: storage)
      env.notifications = .recording(into: recorder)
    }
    let publisher = initializeClient(model: model)

    publisher.onPickerClick(
      fingerprint: .requestPushNotificationsPermissionMessageFingerprint,
      choice: "enable",
    )

    #expect(storage.current?.settings.pushNotificationsPermissionRequested == true)

    try await self.wait()

    #expect(recorder.permissionRequestCount == 1)
  }

  /// "No, thanks" choice flips the persisted flag (so we don't ask again) but
  /// must *not* fire a permission request.
  @Test func savesChoiceWithoutRequestingForSkipChoice() async throws {
    let storage = SessionStorage(current: .mock)
    let recorder = NotificationsRecorder()

    let model = ChatBoxHostModel { env in
      env.session = .inMemory(storage: storage)
      env.notifications = .recording(into: recorder)
    }
    let publisher = initializeClient(model: model)

    publisher.onPickerClick(
      fingerprint: .requestPushNotificationsPermissionMessageFingerprint,
      choice: "skip",
    )

    #expect(storage.current?.settings.pushNotificationsPermissionRequested == true)

    try await self.wait()

    #expect(recorder.permissionRequestCount == 0)
  }

  /// An unrecognised choice value (anything outside `enable`/`skip`) is logged
  /// and otherwise ignored — no flag flip, no permission request.
  @Test func doesNothingForUnknownChoiceValue() async throws {
    let storage = SessionStorage(current: .mock)
    let recorder = NotificationsRecorder()

    let model = ChatBoxHostModel { env in
      env.session = .inMemory(storage: storage)
      env.notifications = .recording(into: recorder)
    }
    let publisher = initializeClient(model: model, sessionId: "session-1")

    publisher.onPickerClick(
      fingerprint: .requestPushNotificationsPermissionMessageFingerprint,
      choice: "what-is-this",
    )

    try await self.wait()

    #expect(storage.current?.settings.pushNotificationsPermissionRequested == false)
    #expect(recorder.permissionRequestCount == 0)
  }

  /// Happy path: developer enabled the prompt, system permission is still
  /// `.notDetermined`, the session hasn't been asked yet, the conversation
  /// has a user-authored message, and the prompt is not already in the
  /// chat. The model should inject the prompt picker.
  @Test func injectsPromptWhenAllGatesPass() async throws {
    let context = await self.context(messages: [.userMessage()])

    await waitForSessionLoadedEvent(api: context.api) {
      context.publisher.onInterfaceLifecycle(.ready)
    }

    try await context.expectMessageInjected(true)
  }

  /// Developer turned the prompt off via
  /// `configureShouldPromptForNotificationsPermission(false)` — the model
  /// must not inject anything.
  @Test func skipsPromptWhenShouldPromptIsFalse() async throws {
    let context = await self.context(
      messages: [.userMessage()],
      shouldPrompt: false,
    )

    await waitForSessionLoadedEvent(api: context.api) {
      context.publisher.onInterfaceLifecycle(.ready)
    }

    try await context.expectMessageInjected(false)
  }

  /// The user has already authorized (or denied) push at the OS level. We
  /// observe `notifications.notificationPermission()` for that and gate out.
  @Test func skipsPromptWhenPermissionIsAuthorized() async throws {
    let context = await self.context(
      messages: [.userMessage()],
      permission: .authorized,
    )

    await waitForSessionLoadedEvent(api: context.api) {
      context.publisher.onInterfaceLifecycle(.ready)
    }

    try await context.expectMessageInjected(false)
  }

  /// The user already responded to our prompt on a previous run (the
  /// `pushNotificationsPermissionRequested` flag is persisted in the
  /// session). Don't ask twice.
  @Test func skipsPromptWhenAlreadyAskedForPermission() async throws {
    let context = await self.context(
      messages: [.userMessage()],
      pushNotificationsPermissionRequested: true,
    )

    await waitForSessionLoadedEvent(api: context.api) {
      context.publisher.onInterfaceLifecycle(.ready)
    }

    try await context.expectMessageInjected(false)
  }

  /// Don't bother the user with a notifications prompt before they've sent
  /// even one message — there's nothing to be notified *about* yet.
  @Test func skipsPromptWhenNoUserMessageExists() async throws {
    let context = await self.context(messages: [])

    await waitForSessionLoadedEvent(api: context.api) {
      context.publisher.onInterfaceLifecycle(.ready)
    }

    try await context.expectMessageInjected(false)
  }

  /// `promptForNotificationPermissionIfNeeded` is invoked at widget-ready
  /// time AND on each `messageSent` event. If a previous pass already
  /// inserted the prompt picker into the conversation, subsequent passes
  /// should leave it alone.
  @Test func skipsPromptWhenAlreadyInjected() async throws {
    let context = await self.context(
      messages: [.userMessage(), .promptMessage()],
    )

    await waitForSessionLoadedEvent(api: context.api) {
      context.publisher.onInterfaceLifecycle(.ready)
    }

    try await context.expectMessageInjected(false)
  }

  /// Widget-ready with an empty conversation skips the prompt — there's no
  /// user message yet. As soon as the visitor posts their first message the
  /// `messageSent` event re-runs the prompt path, finds a user message in
  /// the (now non-empty) conversation, and injects the picker.
  @Test func injectsPromptAfterUserSendsTheirFirstMessage() async throws {
    let context = await self.context(messages: [])

    await waitForSessionLoadedEvent(api: context.api) {
      context.publisher.onInterfaceLifecycle(.ready)
    }

    try await context.expectMessageInjected(false)

    try context.simulateUserSentMessage()

    try await context.expectMessageInjected(true)
  }

  /// Without an identity prompt in the conversation the notifications prompt
  /// renders standalone — it carries the "Just in case you leave or we reply
  /// later" lead-in to give the picker context.
  @Test func injectsStandalonePromptWhenIdentityPromptIsAbsent() async throws {
    let context = await self.context(messages: [.userMessage()])

    await waitForSessionLoadedEvent(api: context.api) {
      context.publisher.onInterfaceLifecycle(.ready)
    }

    let call = try await context.evaluator.waitForCall {
      $0.contains("CrispClient.injectMessage")
    }
    #expect(call.contains("Just in case you leave"))
  }

  /// When an identity prompt is already in the conversation the notifications
  /// prompt is rendered as a follow-up — drop the standalone lead-in, keep
  /// just the short body.
  @Test func injectsCompactPromptWhenIdentityPromptIsPresent() async throws {
    let context = await self.context(
      messages: [.userMessage(), .identityPromptMessage()],
    )

    await waitForSessionLoadedEvent(api: context.api) {
      context.publisher.onInterfaceLifecycle(.ready)
    }

    let call = try await context.evaluator.waitForCall {
      $0.contains("CrispClient.injectMessage")
    }
    #expect(!call.contains("Just in case you leave"))
    #expect(call.contains("We can send you a notification when we reply"))
  }
}

private extension ChatBoxHostModelNotificationRequestTests {
  func wait() async throws {
    try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 100)
  }

  /// Holds everything we need to drive (and inspect) a notification-prompt-message-injection
  /// scenario. Strong-references the model so the bus's `[weak self]`
  /// handlers stay live for the duration of the test — otherwise the
  /// `lifecycle.ready` event hits a deallocated model and `sessionLoaded`
  /// never fires.
  @MainActor final class PromptContext {
    let model: ChatBoxHostModel
    let api: ChatBoxAPI
    let evaluator: RecordingJSEvaluator
    let publisher: JSEventPublisher
    let messageBuffer: MessageBuffer

    init(
      model: ChatBoxHostModel,
      api: ChatBoxAPI,
      evaluator: RecordingJSEvaluator,
      publisher: JSEventPublisher,
      messageBuffer: MessageBuffer,
    ) {
      self.model = model
      self.api = api
      self.evaluator = evaluator
      self.publisher = publisher
      self.messageBuffer = messageBuffer
    }

    /// Simulates the visitor sending their first text message: appends it to
    /// the in-memory buffer that `getMessages()` reads from, then publishes
    /// the matching `onMessageSent` event so the model's `messageSent`
    /// handler re-runs the prompt path.
    func simulateUserSentMessage(text: String = "hi") throws {
      let timestamp = Date(timeIntervalSinceReferenceDate: 0)
      self.messageBuffer.append(
        LocalMessage(
          content: .text(text),
          origin: .chat,
          timestamp: timestamp,
          from: .user,
        ),
      )

      let event = Message(
        content: .text(text),
        origin: .chat,
        timestamp: timestamp,
        fingerprint: 1,
        from: .user,
      )
      let data = try JSONEncoder().encode(event)

      guard let body = String(data: data, encoding: .utf8) else {
        fatalError("Failed to build JSON string")
      }

      self.publisher(channel: "onMessageSent", body: body)
    }

    /// Lets any pending prompt-inject Task complete, then asserts that the
    /// `CrispClient.injectMessage` JS call was/was not recorded.
    func expectMessageInjected(
      _ messageShouldBeInjected: Bool,
      settle: UInt64 = NSEC_PER_MSEC * 100,
      sourceLocation: SourceLocation = #_sourceLocation,
    ) async throws {
      try await Task.sleep(nanoseconds: settle)

      let messageWasInjected = self.evaluator.calls.contains {
        $0.contains("CrispClient.injectMessage")
      }

      #expect(
        messageWasInjected == messageShouldBeInjected,
        "Expected CrispClient.injectMessage() \(messageShouldBeInjected ? "" : "not ")to be called",
        sourceLocation: sourceLocation,
      )
    }
  }

  func context(
    messages: [LocalMessage],
    shouldPrompt: Bool = true,
    permission: NotificationPermission? = nil,
    pushNotificationsPermissionRequested: Bool = false,
  ) async -> PromptContext {
    let api = ChatBoxAPI()
    api.configureShouldPromptForNotificationsPermission(shouldPrompt)

    let storage = SessionStorage(
      current: Session(
        websiteId: .mock,
        sessionId: .mock,
        settings: .init(
          deviceToken: nil,
          pushNotificationsPermissionRequested: pushNotificationsPermissionRequested,
        ),
      ),
    )

    let recorder = NotificationsRecorder()
    let model = ChatBoxHostModel(api: api) { env in
      env.session = .inMemory(storage: storage)
      env.notifications = .recording(into: recorder)
    }

    let messageBuffer = MessageBuffer(messages)
    let evaluator = RecordingJSEvaluator { @MainActor js in
      if js.contains("CrispClient.getSessionIdentifier()") {
        return SessionId.mock.rawValue
      }
      if js.contains("CrispClient.getMessages()") {
        return messageBuffer.encodedJSON()
      }
      return nil
    }
    let (bus, publisher) = JSEventBus.inMemory()
    let client = CrispClient(evaluator: evaluator.asEvaluator(), events: bus)
    model.onClientInitialized(client)

    if let permission {
      model.onAppear(isPresented: false)
      // Yield so the permission-subscription Task suspends at its first
      // `for await`, then push the value and yield again so it lands on
      // the model before the lifecycle event fires.
      await Task.yield()
      recorder.setPermission(permission)
      await Task.yield()
    }

    return PromptContext(
      model: model,
      api: api,
      evaluator: evaluator,
      publisher: publisher,
      messageBuffer: messageBuffer,
    )
  }
}

/// Mutable wrapper around `[LocalMessage]` so the `getMessages()` evaluator
/// stub returns whatever the conversation looks like *now* — letting tests
/// simulate the user posting a message between two `getMessages` calls.
@MainActor final class MessageBuffer {
  private(set) var messages: [LocalMessage]

  init(_ messages: [LocalMessage]) {
    self.messages = messages
  }

  func append(_ message: LocalMessage) {
    self.messages.append(message)
  }

  func encodedJSON() -> String {
    guard let data = (try? JSONEncoder().encode(self.messages)) else {
      fatalError("Could not encode messages")
    }
    guard let string = String(data: data, encoding: .utf8) else {
      fatalError("Could not build JSON string")
    }
    return string
  }
}
