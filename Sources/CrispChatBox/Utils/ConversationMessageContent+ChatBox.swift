import CrispDomain

extension ConversationMessageContent {
  /// Returns the text content of the receiver, if available.
  var textMessage: String? {
    switch self {
    case let .text(text):
      text
    case let .textWithAttachment(text, _, _):
      text
    case let .textWithVideoAttachment(text, _, _):
      text
    case let .note(text):
      text
    case .file, .animation, .audio, .picker, .field, .event, .carousel:
      .none
    }
  }
}
