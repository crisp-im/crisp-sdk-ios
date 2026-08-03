import CrispChatBoxFFI
import CrispDomain
import CrispUtils
import Foundation

package enum ChatCallback {
  case chatClosed(VoidHandler)
  case chatOpened(VoidHandler)
  case messageReceived(MessageHandler)
  case messageSent(MessageHandler)
  case sessionLoaded(SessionIdHandler)
}

package final class CallbackRegistry: Sendable {
  private typealias HandlerList<T: CallbackHandler> = LockIsolated<[T]>

  private let chatClosed = HandlerList<VoidHandler>([])
  private let chatOpened = HandlerList<VoidHandler>([])
  private let messageReceived = HandlerList<MessageHandler>([])
  private let messageSent = HandlerList<MessageHandler>([])
  private let sessionLoaded = HandlerList<SessionIdHandler>([])

  package init() {}

  package func addCallback(_ callback: ChatCallback) {
    switch callback {
    case let .sessionLoaded(cb):
      self.sessionLoaded.withValue { $0.append(cb) }
    case let .messageReceived(cb):
      self.messageReceived.withValue { $0.append(cb) }
    case let .messageSent(cb):
      self.messageSent.withValue { $0.append(cb) }
    case let .chatOpened(cb):
      self.chatOpened.withValue { $0.append(cb) }
    case let .chatClosed(cb):
      self.chatClosed.withValue { $0.append(cb) }
    }
  }

  package func removeCallback(id: CallbackId) {
    self.chatClosed.withValue { $0.removeAll(where: { $0.id == id }) }
    self.chatOpened.withValue { $0.removeAll(where: { $0.id == id }) }
    self.messageReceived.withValue { $0.removeAll(where: { $0.id == id }) }
    self.messageSent.withValue { $0.removeAll(where: { $0.id == id }) }
    self.sessionLoaded.withValue { $0.removeAll(where: { $0.id == id }) }
  }

  @MainActor package func handleChatOpened() {
    self.chatOpened.value.forEach { $0() }
  }

  @MainActor package func handleChatClosed() {
    self.chatClosed.value.forEach { $0() }
  }

  @MainActor package func handleMessageReceived(_ message: Message) {
    self.messageReceived.value.forEach { $0(message: message) }
  }

  @MainActor package func handleMessageSent(_ message: Message) {
    self.messageSent.value.forEach { $0(message: message) }
  }

  @MainActor package func handleSessionLoaded(sessionId: SessionId) {
    self.sessionLoaded.value.forEach { $0(sessionId: sessionId) }
  }
}

package struct CallbackId: Hashable {
  private let uuid: UUID

  package init(uuid: UUID = .init()) {
    self.uuid = uuid
  }
}

package extension ChatCallback {
  var id: CallbackId {
    switch self {
    case let .chatClosed(handler):
      handler.id
    case let .chatOpened(handler):
      handler.id
    case let .messageReceived(handler):
      handler.id
    case let .messageSent(handler):
      handler.id
    case let .sessionLoaded(handler):
      handler.id
    }
  }
}

protocol CallbackHandler: Sendable {
  var id: CallbackId { get }
}

package struct SessionIdHandler: CallbackHandler {
  let id: CallbackId
  let handler: @MainActor (SessionId) -> Void

  package init(id: CallbackId = .init(), handler: @MainActor @escaping (SessionId) -> Void) {
    self.id = id
    self.handler = handler
  }

  @MainActor
  func callAsFunction(sessionId: SessionId) {
    self.handler(sessionId)
  }
}

package struct MessageHandler: CallbackHandler {
  let id: CallbackId
  let handler: @MainActor (Message) -> Void

  package init(
    id: CallbackId = .init(),
    handler: @MainActor @escaping (Message) -> Void,
  ) {
    self.id = id
    self.handler = handler
  }

  @MainActor
  func callAsFunction(message: Message) {
    self.handler(message)
  }
}

package struct VoidHandler: CallbackHandler {
  let id: CallbackId
  let handler: @MainActor () -> Void

  package init(id: CallbackId = .init(), handler: @MainActor @escaping () -> Void) {
    self.id = id
    self.handler = handler
  }

  @MainActor
  func callAsFunction() {
    self.handler()
  }
}
