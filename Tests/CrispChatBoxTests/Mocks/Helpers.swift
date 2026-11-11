@testable import CrispChatBox
import CrispChatBoxFFI
import CrispDomain
import Foundation
import TestMocks

extension WebsiteId {
  static let mock: Self = "website-id"
}

extension SessionId {
  static let mock: Self = "session-id"
}

extension Session {
  static let mock: Self = .init(websiteId: .mock, sessionId: .mock)
}

extension DeviceToken: ExpressibleByStringLiteral {
  // swiftlint:disable:next no_public_outside_crisp
  public init(stringLiteral value: String) {
    self.init(Data(value.utf8))
  }
}

extension String {
  /// Whether a generated chatbox template clears the web client's storage before it boots.
  var clearsWebStorage: Bool {
    self.contains("if ('true' === 'true')")
  }
}

extension ChatBoxAPI {
  convenience init() {
    self.init(session: .noop)
  }
}

extension ChatBoxHostModel {
  convenience init(
    websiteId: WebsiteId = .mock,
    api: ChatBoxAPI = .init(),
    widgetReadyTimeout: UInt64 = NSEC_PER_SEC * 5,
    env: (inout Environment) -> Void = { _ in },
  ) {
    var environment = Environment.live
    environment.notifications = .noop
    env(&environment)
    self.init(websiteId: .mock, api: api, env: environment, widgetReadyTimeout: widgetReadyTimeout)
  }

  /// Lets the model appear the way the view does, which starts the first boot, and returns the
  /// template that boot loads.
  @discardableResult
  func appear() -> String? {
    let onLoadTemplate = self.onLoadTemplate
    var template: String?
    self.onLoadTemplate = {
      template = $0
      onLoadTemplate?($0)
    }
    self.onAppear(isPresented: false)
    self.onLoadTemplate = onLoadTemplate
    return template
  }
}

@MainActor @discardableResult
func initializeClient(model: ChatBoxHostModel, sessionId: SessionId = .mock) -> JSEventPublisher {
  let (bus, publisher) = JSEventBus.inMemory()
  let evaluator: JSEvaluator = { js in
    if js.contains("CrispClient.getSessionIdentifier()") {
      return sessionId.rawValue
    }
    if js.contains("CrispClient.isSessionOngoing()") {
      return false
    }
    return nil
  }

  model.onClientInitialized(CrispClient(evaluator: evaluator, events: bus))

  return publisher
}

/// Holds async work until the test opens it, to order events without relying on timing.
@MainActor
final class Gate {
  private var isOpen = false
  private var waiters = [CheckedContinuation<Void, Never>]()

  func wait() async {
    guard !self.isOpen else { return }
    await withCheckedContinuation { self.waiters.append($0) }
  }

  func open() {
    self.isOpen = true
    self.waiters.forEach { $0.resume() }
    self.waiters.removeAll()
  }
}

/// Polls `condition` on the main actor until it holds or the timeout elapses.
@MainActor
func waitUntil(
  timeout: UInt64 = NSEC_PER_SEC * 5,
  pollInterval: UInt64 = NSEC_PER_MSEC * 10,
  _ condition: () -> Bool,
) async {
  var waited: UInt64 = 0
  while !condition(), waited < timeout {
    try? await Task.sleep(nanoseconds: pollInterval)
    waited += pollInterval
  }
}

@MainActor @discardableResult
func waitForSessionLoadedEvent(api: ChatBoxAPI, body: () -> Void) async -> [Command] {
  var commands = [Command]()
  let callbackId = CallbackId()
  await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
    api.addCallback(.sessionLoaded(SessionIdHandler(id: callbackId) { _ in
      // One-shot: a later session load (e.g. after a reboot) must not resume this wait again.
      api.removeCallback(callbackId)
      commands = api.commands.commands
      cont.resume()
    }))
    body()
  }
  return commands
}
