import Foundation

public extension Message {
  /// A message to show locally. See ``CrispSDK/showMessage(_:)``
  enum Content: Equatable, Sendable {
    case animation(ImageFile)
    case audio(AudioFile)
    case carousel(CarouselValue)
    case field(FieldValue)
    case file(File)
    case picker(PickerValue)
    case text(String)
    case textWithAttachment(String, WebsiteAttachment, AttachmentPreview?)
    case textWithVideoAttachment(String, WebsiteAttachment, EmbeddedPreview)
  }
}

public extension Message.Content {
  struct WebsiteAttachment: Equatable, Sendable {
    public var title: String
    public var website: String
    public var url: URL

    public init(title: String, website: String, url: URL) {
      self.title = title
      self.website = website
      self.url = url
    }
  }

  struct AttachmentPreview: Equatable, Sendable {
    public var excerpt: String?
    public var image: URL

    public init(excerpt: String?, image: URL) {
      self.excerpt = excerpt
      self.image = image
    }
  }

  struct EmbeddedPreview: Equatable, Sendable {
    public var excerpt: String?
    public var image: URL
    public var embed: URL

    public init(excerpt: String?, image: URL, embed: URL) {
      self.excerpt = excerpt
      self.image = image
      self.embed = embed
    }
  }

  struct ImageFile: Equatable, Sendable {
    public var mimeType: String
    public var url: URL

    public init(mimeType: String, url: URL) {
      self.mimeType = mimeType
      self.url = url
    }
  }

  struct AudioFile: Equatable, Sendable {
    public var mimeType: String
    public var url: URL
    public var duration: Int

    public init(mimeType: String, url: URL, duration: Int) {
      self.mimeType = mimeType
      self.url = url
      self.duration = duration
    }
  }

  struct CarouselValue: Equatable, Sendable {
    public struct Target: Equatable, Sendable {
      public struct Action: Equatable, Sendable {
        public var label: String
        public var url: URL

        public init(label: String, url: URL) {
          self.label = label
          self.url = url
        }
      }

      public var title: String
      public var description: String
      public var image: URL?
      public var actions: [Action]

      public init(title: String, description: String, image: URL? = nil, actions: [Action]) {
        self.title = title
        self.description = description
        self.image = image
        self.actions = actions
      }
    }

    public var text: String
    public var targets: [Target]

    public init(text: String, targets: [Target]) {
      self.text = text
      self.targets = targets
    }
  }

  struct FieldValue: Equatable, Sendable {
    public var id: String
    public var text: String
    public var explain: String
    public var value: String?

    public init(id: String, text: String, explain: String, value: String?) {
      self.id = id
      self.text = text
      self.explain = explain
      self.value = value
    }
  }

  struct File: Codable, Equatable, Sendable {
    public var name: String
    public var mimeType: String
    public var url: URL

    public init(name: String, mimeType: String, url: URL) {
      self.name = name
      self.mimeType = mimeType
      self.url = url
    }
  }

  struct PickerValue: Equatable, Sendable {
    public struct Choice: Equatable, Sendable {
      public struct Action: Equatable, Sendable {
        public enum Kind: String, Equatable, Sendable {
          case link
          case frame
        }

        public var type: Kind
        public var target: URL

        public init(type: Kind, target: URL) {
          self.type = type
          self.target = target
        }
      }

      public var label: String
      public var icon: String?
      public var selected: Bool
      public var value: String
      public var action: Action?

      public init(
        label: String,
        icon: String? = nil,
        selected: Bool,
        value: String,
        action: Action? = nil,
      ) {
        self.label = label
        self.icon = icon
        self.selected = selected
        self.value = value
        self.action = action
      }
    }

    public var id: String
    public var text: String
    public var choices: [Choice]

    public init(id: String, text: String, choices: [Choice]) {
      self.id = id
      self.text = text
      self.choices = choices
    }
  }
}
