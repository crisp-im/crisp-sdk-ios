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

extension ChatBoxHostModel {
  convenience init(
    websiteId: WebsiteId = .mock,
    api: ChatBoxAPI = .init(),
    widgetReadyTimeout: UInt64 = NSEC_PER_SEC * 5,
    env: (inout Environment) -> Void = { _ in },
  ) {
    var environment = Environment.live
    env(&environment)
    self.init(websiteId: .mock, api: api, env: environment, widgetReadyTimeout: widgetReadyTimeout)
  }
}

@MainActor @discardableResult
func initializeClient(model: ChatBoxHostModel, sessionId: SessionId = .mock) -> JSEventPublisher {
  let (bus, publisher) = JSEventBus.inMemory()
  let evaluator: JSEvaluator = { js in
    js.contains("CrispClient.getSessionIdentifier()")
      ? sessionId.rawValue
      : nil
  }

  model.onClientInitialized(CrispClient(evaluator: evaluator, events: bus))

  return publisher
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
  await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
    api.addCallback(.sessionLoaded(SessionIdHandler { _ in
      commands = api.commands.commands
      cont.resume()
    }))
    body()
  }
  return commands
}
