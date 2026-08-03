import CrispDomain
import CrispUtils
import Foundation

@dynamicMemberLookup
package struct LocalMessage {
  private var generic: GenericMessage
  package var fingerprint: LocalMessageFingerprint?
  package var error: Bool?
  package var sending: Bool?
  package var metas: Metas?

  package init(
    generic: GenericMessage,
    fingerprint: LocalMessageFingerprint? = nil,
    error: Bool? = nil,
    sending: Bool? = nil,
    metas: Metas? = nil,
  ) {
    self.generic = generic
    self.fingerprint = fingerprint
    self.error = error
    self.sending = sending
    self.metas = metas
  }

  package init(
    content: ConversationMessageContent,
    origin: Origin,
    timestamp: Date,
    from: MessageSender,
    fingerprint: LocalMessageFingerprint? = nil,
    user: Participant? = nil,
    read: Bool = false,
    automated: Bool = false,
    edited: Bool = false,
    translated: Bool = false,
    ignored: [String: MessageIgnored]? = nil,
    references: [MessageReference]? = nil,
    properties: [String: JSONValue]? = nil,
    error: Bool? = nil,
    sending: Bool? = nil,
    metas: Metas? = nil,
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
    self.error = error
    self.sending = sending
    self.metas = metas
  }

  package subscript<T>(dynamicMember keyPath: WritableKeyPath<GenericMessage, T>) -> T {
    get { self.generic[keyPath: keyPath] }
    set { self.generic[keyPath: keyPath] = newValue }
  }
}

package extension LocalMessage {
  struct Metas: Codable {
    package var isNew: Bool?
    package var isPending: Bool?
    package var error: String?
    package var field: Field?

    private enum CodingKeys: String, CodingKey {
      case isNew = "is_new"
      case isPending = "is_pending"
      case error
      case field
    }

    package init(
      isNew: Bool? = nil,
      isPending: Bool? = nil,
      error: String? = nil,
      field: Field? = nil,
    ) {
      self.isNew = isNew
      self.isPending = isPending
      self.error = error
      self.field = field
    }

    package struct Field: Codable {
      package var value: String?

      package init(value: String? = nil) {
        self.value = value
      }
    }
  }
}

package enum LocalMessageFingerprint: Equatable {
  case remote(MessageFingerprint)
  case local(String)
}

extension LocalMessageFingerprint: Codable {
  package init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()

    if let rawValue = try? container.decode(Int64.self) {
      self = .remote(MessageFingerprint(rawValue: rawValue))
    } else {
      self = try .local(container.decode(String.self))
    }
  }

  package func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()

    switch self {
    case let .remote(fingerprint):
      try container.encode(fingerprint)
    case let .local(string):
      try container.encode(string)
    }
  }
}

extension LocalMessage: Codable {
  private enum CodingKeys: String, CodingKey {
    case fingerprint
    case error
    case sending
    case metas
  }

  package init(from decoder: any Decoder) throws {
    self.generic = try GenericMessage(from: decoder)
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.fingerprint = try container.decodeIfPresent(
      LocalMessageFingerprint.self,
      forKey: .fingerprint,
    )
    self.error = try container.decodeIfPresent(Bool.self, forKey: .error)
    self.sending = try container.decodeIfPresent(Bool.self, forKey: .sending)
    self.metas = try container.decodeIfPresent(Metas.self, forKey: .metas)
  }

  package func encode(to encoder: any Encoder) throws {
    try self.generic.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(self.fingerprint, forKey: .fingerprint)
    try container.encodeIfPresent(self.error, forKey: .error)
    try container.encodeIfPresent(self.sending, forKey: .sending)
    try container.encodeIfPresent(self.metas, forKey: .metas)
  }
}
