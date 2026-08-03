internal import CrispDomain

extension Message.Content {
  var conversationMessageContent: ConversationMessageContent {
    switch self {
    case let .animation(imageFile):
      .animation(.init(mimeType: imageFile.mimeType, url: imageFile.url))

    case let .audio(audioFile):
      .audio(
        .init(mimeType: audioFile.mimeType, url: audioFile.url, duration: audioFile.duration),
      )

    case let .carousel(carouselValue):
      .carousel(
        .init(
          text: carouselValue.text,
          targets: carouselValue.targets.map { target in
            .init(
              title: target.title,
              description: target.description,
              image: target.image,
              actions: target.actions.map { action in
                .init(label: action.label, url: action.url)
              },
            )
          },
        ),
      )

    case let .field(fieldValue):
      .field(
        .init(
          id: FieldId(fieldValue.id),
          text: fieldValue.text,
          explain: fieldValue.explain,
          required: nil,
          value: fieldValue.value,
        ),
      )

    case let .file(fileValue):
      .file(.init(name: fileValue.name, mimeType: fileValue.mimeType, url: fileValue.url))

    case let .picker(pickerValue):
      .picker(
        .init(
          id: PickerId(pickerValue.id),
          text: pickerValue.text,
          choices: pickerValue.choices.map { choice in
            .init(
              label: choice.label,
              icon: choice.icon,
              selected: choice.selected,
              value: choice.value,
              action: choice.action.map { action in
                let kind: ConversationMessageContent.PickerValue.Choice.Action.Kind = switch action
                  .type
                {
                case .link:
                  .link
                case .frame:
                  .frame
                }
                return .init(type: kind, target: action.target)
              },
            )
          },
          required: nil,
        ),
      )

    case let .text(text):
      .text(text)

    case let .textWithAttachment(text, attachment, preview):
      .textWithAttachment(
        text,
        .init(title: attachment.title, website: attachment.website, url: attachment.url),
        preview.map { preview in
          .init(excerpt: preview.excerpt, image: preview.image)
        },
      )

    case let .textWithVideoAttachment(text, attachment, preview):
      .textWithVideoAttachment(
        text,
        .init(title: attachment.title, website: attachment.website, url: attachment.url),
        .init(excerpt: preview.excerpt, image: preview.image, embed: preview.embed),
      )
    }
  }
}

extension Message.Content {
  init?(_ content: ConversationMessageContent) {
    switch content {
    case let .animation(animationValue):
      self = .animation(.init(
        mimeType: animationValue.mimeType,
        url: animationValue.url,
      ))

    case let .audio(audioValue):
      self = .audio(.init(
        mimeType: audioValue.mimeType,
        url: audioValue.url,
        duration: audioValue.duration,
      ))

    case let .carousel(carouselValue):
      self = .carousel(.init(
        text: carouselValue.text,
        targets: carouselValue.targets.map { target in
          .init(
            title: target.title,
            description: target.description,
            image: target.image,
            actions: target.actions.map { action in
              .init(label: action.label, url: action.url)
            },
          )
        },
      ))

    case let .field(fieldValue):
      self = .field(.init(
        id: fieldValue.id.rawValue,
        text: fieldValue.text,
        explain: fieldValue.explain,
        value: fieldValue.value,
      ))

    case let .file(fileValue):
      self = .file(.init(
        name: fileValue.name,
        mimeType: fileValue.mimeType,
        url: fileValue.url,
      ))

    case let .picker(pickerValue):
      self = .picker(.init(
        id: pickerValue.id.rawValue,
        text: pickerValue.text,
        choices: pickerValue.choices.map { choice in
          .init(
            label: choice.label,
            icon: choice.icon,
            selected: choice.selected,
            value: choice.value,
            action: choice.action.map { action in
              let kind: Message.Content.PickerValue.Choice.Action.Kind = switch action.type {
              case .link:
                .link
              case .frame:
                .frame
              }
              return .init(type: kind, target: action.target)
            },
          )
        },
      ))

    case let .text(text):
      self = .text(text)

    case let .textWithAttachment(text, attachment, preview):
      self = .textWithAttachment(
        text,
        .init(title: attachment.title, website: attachment.website, url: attachment.url),
        preview.map { preview in
          .init(excerpt: preview.excerpt, image: preview.image)
        },
      )

    case let .textWithVideoAttachment(text, attachment, preview):
      self = .textWithVideoAttachment(
        text,
        .init(title: attachment.title, website: attachment.website, url: attachment.url),
        .init(excerpt: preview.excerpt, image: preview.image, embed: preview.embed),
      )

    case .event, .note:
      return nil
    }
  }
}
