import CrispChatBoxFFI
import CrispDomain
import CrispLogging
import CrispUtils
import Foundation

@dynamicMemberLookup
package final class ChatBoxAPI: Sendable {
  package struct State {
    package fileprivate(set) var websiteId: WebsiteId?
    package fileprivate(set) var tokenId: TokenId?
    package fileprivate(set) var shouldPromptForPermission = true
    package fileprivate(set) var defaultLogHandlerAdded = false

    package var sessionId: SessionId?
    package var visitorData: VisitorData?
    package var isSessionOngoing = false
  }

  private let state = LockIsolated(State())

  let callbacks = CallbackRegistry()
  let commands = CommandQueue()

  package init() {}

  package subscript<T: Sendable>(dynamicMember keyPath: KeyPath<State, T>) -> T {
    self.state[dynamicMember: keyPath]
  }
}

package extension ChatBoxAPI {
  func configureWebsiteId(_ id: WebsiteId) {
    self.state.withValue {
      $0.websiteId = id

      if !$0.defaultLogHandlerAdded {
        $0.defaultLogHandlerAdded = true
        CrispLogging.log.addLogHandler(ErrorConsoleLogger())
      }
    }
  }

  func configureTokenId(_ id: TokenId?) {
    self.state.withValue { $0.tokenId = id }
  }

  func configureShouldPromptForNotificationsPermission(_ flag: Bool) {
    self.state.withValue {
      $0.shouldPromptForPermission = flag
    }
  }

  func addCallback(_ callback: ChatCallback) {
    self.callbacks.addCallback(callback)
  }

  func removeCallback(_ id: CallbackId) {
    self.callbacks.removeCallback(id: id)
  }
}

package extension ChatBoxAPI {
  func resetSession() {
    self.commands.resetAndEnqueue(.reset)
  }

  func setSessionData(_ data: [String: any Encodable & Sendable]) {
    self.commands.enqueue(.setSessionData(data))
  }

  func setSegments(_ segments: [String], overwrite: Bool) {
    self.commands.enqueue(.setSegments(segments: segments, overwrite: overwrite))
  }

  func pushEvents(_ events: [CrispChatBoxFFI.SessionEvent]) {
    self.commands.enqueue(.pushEvents(events))
  }

  func runBotScenario(id: BotScenarioId) {
    self.commands.enqueue(.runBotScenario(id))
  }

  func setNickname(_ nickname: String) {
    self.commands.enqueue(.setNickname(nickname))
  }

  func setEmail(_ email: String, signature: String?) {
    self.commands.enqueue(.setEmail(address: email, signature: signature))
  }

  func setPhone(_ phone: String) {
    self.commands.enqueue(.setPhone(phone))
  }

  func setAvatar(_ url: URL) {
    self.commands.enqueue(.setAvatar(url))
  }

  func setCompany(_ company: CrispChatBoxFFI.Company) {
    self.commands.enqueue(.setCompany(company))
  }

  func setDeviceToken(_ token: DeviceToken) {
    self.commands.enqueue(.setDeviceToken(token))
  }

  func unsetDeviceToken(_ token: DeviceToken) {
    self.commands.enqueue(.unsetDeviceToken(token))
  }

  func showMessage(fingerprint: MessageFingerprint?, content: ConversationMessageContent) {
    self.commands.enqueue(
      .showMessage(fingerprint: fingerprint, content: content),
    )
  }

  func open(_ intent: OpenIntent) {
    self.commands.enqueue(.open(intent))
  }
}

private struct ErrorConsoleLogger: LogHandler {
  func log(
    level _: CrispLogging.LogLevel,
    message _: String,
    timestamp _: Date,
    file _: StaticString,
    function _: StaticString,
    line _: UInt,
  ) {}

  func logError(
    _ error: any Error,
    timestamp _: Date,
    file _: StaticString,
    function _: StaticString,
    line _: UInt,
  ) {
    // swiftlint:disable:next no_direct_standard_out_logs
    print("[Crisp] Error: \(error)")
  }
}
