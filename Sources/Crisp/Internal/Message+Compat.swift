internal import CrispChatBoxFFI
internal import CrispDomain
import Foundation

extension Message {
  init?(_ message: CrispChatBoxFFI.Message) {
    // Unsupported content type like an event or a note.
    guard let content = Message.Content(message.content) else {
      return nil
    }

    self.isMe = message.from == .user
    self.content = content
    self.origin = .init(message.origin)
    self.timestamp = message.timestamp
    self.fingerprint = message.fingerprint.rawValue
    self.from = .init(message.from)
    self.user = message.user.map(Message.User.init)
  }
}

extension Message.Origin {
  init(_ channel: Origin) {
    switch channel {
    case .local:
      self = .local
    case .update:
      self = .update
    default:
      self = .network
    }
  }
}

extension Message.Sender {
  init(_ sender: MessageSender) {
    switch sender {
    case .user:
      self = .user
    case .operator:
      self = .operator
    }
  }
}

extension Message.User {
  init(_ participant: CrispChatBoxFFI.Participant) {
    self.nickname = participant.nickname
    self.userId = participant.userId
    self.avatar = participant.avatar
  }
}
