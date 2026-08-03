import CrispDomain
import CrispUtils
import Foundation

package struct GenericMessage {
  package var content: ConversationMessageContent
  package var origin: Origin
  package var timestamp: Date
  package var from: MessageSender
  package var user: Participant?
  package var read: Bool
  package var automated: Bool
  package var edited: Bool
  package var translated: Bool
  package var ignored: [String: MessageIgnored]?
  package var references: [MessageReference]?
  package var properties: [String: JSONValue]?

  package init(
    content: ConversationMessageContent,
    origin: Origin,
    timestamp: Date,
    from: MessageSender,
    user: Participant? = nil,
    read: Bool = false,
    automated: Bool = false,
    edited: Bool = false,
    translated: Bool = false,
    ignored: [String: MessageIgnored]? = nil,
    references: [MessageReference]? = nil,
    properties: [String: JSONValue]? = nil,
  ) {
    self.content = content
    self.origin = origin
    self.timestamp = timestamp
    self.from = from
    self.user = user
    self.read = read
    self.automated = automated
    self.edited = edited
    self.translated = translated
    self.ignored = ignored
    self.references = references
    self.properties = properties
  }
}

package struct MessageIgnored: Codable {
  package var type: String?
  package var reason: String?

  package init(type: String? = nil, reason: String? = nil) {
    self.type = type
    self.reason = reason
  }
}

package struct MessageReference: Codable {
  package var type: String?
  package var name: String?
  package var target: String?

  package init(type: String? = nil, name: String? = nil, target: String? = nil) {
    self.type = type
    self.name = name
    self.target = target
  }
}

extension GenericMessage: Codable {
  enum CodingKeys: String, CodingKey {
    case from
    case origin
    case timestamp
    case read
    case user
    case type
    case content
    case preview
    case automated
    case edited
    case translated
    case ignored
    case references
    case properties
  }

  package init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    // If the key `read` exists and is not nil, we consider the message to be read.
    // A value for this key could be e.g. "chat", but it could also be 0.
    self.read = try container.contains(.read) &&
      !container.decodeNil(forKey: .read) &&
      container.decode(Bool.self, forKey: .read) != false

    self.origin = try container.decodeIfPresent(Origin.self, forKey: .origin) ?? .chat
    self.timestamp = try container.decode(Date.self, forKey: .timestamp)
    self.user = try container.decodeIfPresent(Participant.self, forKey: .user)
    self.from = try container.decode(MessageSender.self, forKey: .from)
    self.automated = try container.decodeIfPresent(Bool.self, forKey: .automated) ?? false
    self.edited = try container.decodeIfPresent(Bool.self, forKey: .edited) ?? false
    self.translated = try container.decodeIfPresent(Bool.self, forKey: .translated) ?? false
    self.ignored = try container.decodeIfPresent(
      [String: MessageIgnored].self,
      forKey: .ignored,
    )
    self.references = try container.decodeIfPresent(
      [MessageReference].self,
      forKey: .references,
    )
    self.properties = try container.decodeIfPresent(
      [String: JSONValue].self,
      forKey: .properties,
    )

    guard
      let context = decoder.userInfo[ConversationMessageDecodingContext.userInfoKey]
      as? ConversationMessageDecodingContext
    else {
      fatalError("""
        Expected `ConversationMessageDecodingContext` to be set when \
        decoding `GenericMessage`. Did you forget to set it?
      """)
    }

    context.messageType = try container.decode(
      CrispDomain.ConversationMessageType.self,
      forKey: .type,
    )

    if container.contains(.preview) {
      context.textMessagePreviews =
        try? container.decode([TextMessagePreview].self, forKey: .preview)
    }

    self.content = try container.decode(ConversationMessageContent.self, forKey: .content)

    // Reset preview for consecutive messages.
    context.textMessagePreviews = nil
  }

  package func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(self.origin, forKey: .origin)
    try container.encode(self.timestamp, forKey: .timestamp)
    try container.encodeIfPresent(self.user, forKey: .user)
    try container.encode(self.from, forKey: .from)
    try container.encode(self.read, forKey: .read)
    try container.encode(self.automated, forKey: .automated)
    try container.encode(self.edited, forKey: .edited)
    try container.encode(self.translated, forKey: .translated)
    try container.encodeIfPresent(self.ignored, forKey: .ignored)
    try container.encodeIfPresent(self.references, forKey: .references)
    try container.encodeIfPresent(self.properties, forKey: .properties)
    try container.encode(self.content.type, forKey: .type)
    try container.encodeIfPresent(self.content.textMessagePreviews, forKey: .preview)
    try container.encode(self.content, forKey: .content)
  }
}
