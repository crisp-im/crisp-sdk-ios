@testable import CrispChatBox
import CrispChatBoxFFI
import Foundation

extension LocalMessage {
  static func userMessage() -> LocalMessage {
    LocalMessage(
      content: .text("hi"),
      origin: .chat,
      timestamp: Date(timeIntervalSinceReferenceDate: 0),
      from: .user,
    )
  }

  static func promptMessage() -> LocalMessage {
    LocalMessage(
      content: .picker(.init(
        id: "",
        text: "?",
        choices: [],
        required: false,
      )),
      origin: .chat,
      timestamp: Date(timeIntervalSinceReferenceDate: 0),
      from: .operator,
      fingerprint: .remote(.requestPushNotificationsPermissionMessageFingerprint),
    )
  }

  /// A `LocalMessage` whose fingerprint matches the JS-side identity prompt
  /// (`$identity`). Its presence shifts the notifications-permission prompt
  /// into its compact (non-standalone) variant.
  static func identityPromptMessage() -> LocalMessage {
    LocalMessage(
      content: .text("identity prompt"),
      origin: .chat,
      timestamp: Date(timeIntervalSinceReferenceDate: 0),
      from: .operator,
      fingerprint: .identityPromptMessageFingerprint,
    )
  }
}
