import CrispDomain
import Foundation

package struct ChatMessageUpdate: Equatable {
  package var fingerprint: MessageFingerprint
  package var content: ConversationMessageContent

  package init(fingerprint: MessageFingerprint, content: ConversationMessageContent) {
    self.fingerprint = fingerprint
    self.content = content
  }
}

extension ChatMessageUpdate: Codable {
  private enum CodingKeys: String, CodingKey {
    case fingerprint
    case content
  }

  package init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.fingerprint = try container.decode(MessageFingerprint.self, forKey: .fingerprint)

    // We have to somehow figure out what kind of message update we've received.
    if let text = try? container.decode(String.self, forKey: .content) {
      self.content = .text(text)
      return
    }

    enum ContentDictCodingKeys: String, CodingKey {
      case choices
      case explain
      case duration
      case name
      case url
    }

    let contentDict = try container.nestedContainer(
      keyedBy: ContentDictCodingKeys.self,
      forKey: .content,
    )

    switch contentDict {
    case _ where contentDict.contains(.choices):
      self.content = try .picker(
        container.decode(ConversationMessageContent.PickerValue.self, forKey: .content),
      )

    case _ where contentDict.contains(.explain):
      self.content = try .field(
        container.decode(ConversationMessageContent.FieldValue.self, forKey: .content),
      )

    case _ where contentDict.contains(.duration):
      self.content = try .audio(
        container.decode(ConversationMessageContent.AudioFile.self, forKey: .content),
      )

    case _ where contentDict.contains(.name):
      self.content = try .file(
        container.decode(ConversationMessageContent.File.self, forKey: .content),
      )

    case _ where contentDict.contains(.url):
      self.content = try .animation(
        container.decode(ConversationMessageContent.ImageFile.self, forKey: .content),
      )

    default:
      throw DecodingError.dataCorruptedError(
        forKey: .content,
        in: container,
        debugDescription: "Could not decode content in ChatMessageUpdate.",
      )
    }
  }

  package func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(self.fingerprint, forKey: .fingerprint)
    try container.encode(self.content, forKey: .content)
  }
}
