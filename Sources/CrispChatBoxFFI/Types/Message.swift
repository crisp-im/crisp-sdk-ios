import CrispDomain
import CrispUtils
import Foundation

@dynamicMemberLookup
package struct Message {
  private var generic: GenericMessage
  package var fingerprint: MessageFingerprint
  package var sessionId: SessionId?

  package init(
    generic: GenericMessage,
    fingerprint: MessageFingerprint,
    sessionId: SessionId? = nil,
  ) {
    self.generic = generic
    self.fingerprint = fingerprint
    self.sessionId = sessionId
  }

  package init(
    content: ConversationMessageContent,
    origin: Origin,
    timestamp: Date,
    fingerprint: MessageFingerprint,
    from: MessageSender,
    user: Participant? = nil,
    read: Bool = false,
    automated: Bool = false,
    edited: Bool = false,
    translated: Bool = false,
    ignored: [String: MessageIgnored]? = nil,
    references: [MessageReference]? = nil,
    properties: [String: JSONValue]? = nil,
    sessionId: SessionId? = nil,
  ) {
    self.generic = GenericMessage(
      content: content,
      origin: origin,
      timestamp: timestamp,
      from: from,
      user: user,
      read: read,
      automated: automated,
      edited: edited,
      translated: translated,
      ignored: ignored,
      references: references,
      properties: properties,
    )
    self.fingerprint = fingerprint
    self.sessionId = sessionId
  }

  package subscript<T>(dynamicMember keyPath: WritableKeyPath<GenericMessage, T>) -> T {
    get { self.generic[keyPath: keyPath] }
    set { self.generic[keyPath: keyPath] = newValue }
  }
}

extension Message: Codable {
  private enum CodingKeys: String, CodingKey {
    case fingerprint
    case sessionId = "session_id"
  }

  package init(from decoder: any Decoder) throws {
    self.generic = try GenericMessage(from: decoder)
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.fingerprint = try container.decode(MessageFingerprint.self, forKey: .fingerprint)
    self.sessionId = try container.decodeIfPresent(SessionId.self, forKey: .sessionId)
  }

  package func encode(to encoder: any Encoder) throws {
    try self.generic.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.fingerprint, forKey: .fingerprint)
    try container.encodeIfPresent(self.sessionId, forKey: .sessionId)
  }
}
