import CrispChatBoxFFI
import CrispDomain
import Foundation

enum NotificationPermissionSelection: String {
  case enable
  case skip
}

extension MessageFingerprint {
  static let requestPushNotificationsPermissionMessageFingerprint = MessageFingerprint(-10006)
}

extension LocalMessageFingerprint {
  static let identityPromptMessageFingerprint = Self.local("$identity")
}

extension Message {
  static func requestPushNotificationsPermissionMessage(isStandalone: Bool) -> Self {
    var messageText = NSLocalizedString(
      "sdk.prompt_notification_ask",
      bundle: .module,
      value: "We can send you a notification when we reply",
      comment: "Body of the message offering to send push notifications",
    )

    if isStandalone {
      let intro = NSLocalizedString(
        "sdk.prompt_notification_reply",
        bundle: .module,
        value: "Just in case you leave or we reply later:",
        comment: "Standalone-mode intro shown above the push-notification offer",
      )
      // crisp-client ships both strings as plain text, so the emphasis is
      // applied here rather than baked into the translations.
      messageText = "**\(intro)**\n_\(messageText)_"
    }

    return Message(
      content: .picker(.init(
        id: "",
        text: messageText,
        choices: [
          .init(
            label: NSLocalizedString(
              "sdk.action_notifications_enable",
              bundle: .module,
              value: "Enable Notifications",
              comment: "Push-notification opt-in choice",
            ),
            selected: false,
            value: NotificationPermissionSelection.enable.rawValue,
          ),
          .init(
            label: NSLocalizedString(
              "sdk.action_deny",
              bundle: .module,
              value: "No, thanks",
              comment: "Push-notification opt-out choice",
            ),
            selected: false,
            value: NotificationPermissionSelection.skip.rawValue,
          ),
        ],
        required: false,
      )),
      origin: .chat,
      timestamp: Date(),
      fingerprint: .requestPushNotificationsPermissionMessageFingerprint,
      from: .operator,
      user: .init(nickname: "System"),
      automated: true,
    )
  }
}
