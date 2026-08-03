internal import CrispChatBox
internal import CrispDomain
internal import CrispLogging
import Foundation
import UIKit

/// The main entry point to set up your Website ID and configure a chat session.
@objc public final class CrispSDK: NSObject {
  /// Associates the Chatbox with your Website ID.
  ///
  /// - Important: Make sure to call this method before you interact with any other SDK methods and
  /// before you present the Chatbox UI. This can be done for example in your
  /// `UIApplicationDelegate` or `UISceneDelegate`.
  ///
  /// ```swift
  /// import Crisp
  /// import UIKit
  ///
  /// @main
  /// class AppDelegate: UIResponder, UIApplicationDelegate {
  ///   func application(
  ///     _ application: UIApplication,
  ///     didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
  ///   ) -> Bool {
  ///     CrispSDK.configure(websiteID: "b8df20e8-0126-4126-b14e-9709f7e58a0d")
  ///
  ///     // ...
  ///
  ///     return true
  ///   }
  /// }
  /// ```
  ///
  /// You can find your Website ID in the [Crisp
  /// dashboard](https://app.crisp.chat/settings/websites/).
  /// ![Copy your Website ID](copy-website-id)
  ///
  /// - Parameter websiteID: Your Website ID.
  @objc public static func configure(websiteID: String) {
    _configure(websiteID: websiteID)
  }

  /// Associates the chat session with a token.
  ///
  /// If your website shows the chatbox for authenticated users only - in other words: users for
  /// which you have an internal identification value, such as an user ID, an email or a token - you
  /// may want to ensure that the Crisp chat session associated to that user stays the same,
  /// whatever the device he is on and whether your user clears his cookies or not. This ensures you
  /// get chats from the same user in the same Crisp session.
  ///
  /// You can do so using Crisp Tokens. A token is a private and secure arbitrary value that is
  /// known to your system, and sent when you inject Crisp in the page. Each user must be associated
  /// to a different token (if you use the token system).
  ///
  /// - Important:
  ///   - `setTokenID` should be called before the chat has been presented. If you want to change
  ///     the token after the chat has been presented you need to call ``Session/reset()`` on
  ///     ``CrispSDK/session`` for the new token to come into effect.
  ///
  ///   - When users logout from their account in your app, make sure to clear the token by calling
  ///     `setTokenID(nil)` and then reset their local session by calling ``Session/reset()`` on
  ///     ``CrispSDK/session``. This will not destroy the remote session with Crisp, it will only
  ///     unbind the app from it. This session will be recovered when the user logs in again to
  ///     their account, via their token.
  ///
  ///   **Example of logout handling:**
  ///   ```swift
  ///   func userLogout() {
  ///     // Execute this sequence when your users are logging out
  ///     CrispSDK.setTokenID(nil) // 1. Clear the token value
  ///     CrispSDK.session.reset() // 2. Unbind the current session
  ///   }
  ///   ```
  ///
  /// [Watch a video tutorial](https://youtu.be/qiOoW5u211U)
  ///
  /// - Parameter tokenID: A unique token by which your system can identify one of your users or
  ///                      `nil` to reset an already configured token.
  ///
  /// - seealso: You can find more information about this concept in the [Web
  ///   SDK documentation](https://docs.crisp.chat/guides/chatbox-sdks/web-sdk/session-continuity/).
  @objc public static func setTokenID(tokenID: String?) {
    CrispSDK.apiModel.configureTokenId(tokenID.map(TokenId.init(rawValue:)))
  }

  /// Opens the chat view.
  ///
  /// - Note: If the ``ChatViewController`` (UIKit) or ``ChatView`` (SwiftUI) is currently
  /// presented, it will switch to the "Chat" tab immediately. If it is not presented yet it
  /// will start with the "Chat" tab on the next presentation.
  @objc public static func openChat() {
    CrispSDK.apiModel.open(.chat)
  }

  /// Opens helpdesk search interface.
  ///
  /// - Note: If the ``ChatViewController`` (UIKit) or ``ChatView`` (SwiftUI) is currently
  /// presented, it will switch to the "Helpdesk" tab immediately. If it is not presented yet it
  /// will start with the "Helpdesk" tab on the next presentation.
  @objc public static func searchHelpdesk() {
    CrispSDK.apiModel.open(.helpdesk)
  }

  /// Sets the device token for push notifications.
  ///
  /// Call this method in your `UIApplicationDelegate` implementation, specifically in the
  /// `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)` method, to provide
  /// the SDK with the device token for push notifications.
  ///
  /// - Parameter token: The device token data received from Apple's push notification service.
  ///
  /// - Note: This method should be called every time the app receives a new device token,
  ///         typically after the app launches or when the token is refreshed.
  ///
  /// - Example:
  ///   ```
  ///   func application(_ application: UIApplication,
  ///                    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
  ///       CrispSDK.setDeviceToken(deviceToken)
  ///   }
  ///   ```
  @objc public static func setDeviceToken(_ token: Data) {
    CrispSDK.apiModel.setDeviceToken(.init(token))
  }

  /// Determines whether a push notification is from Crisp.
  ///
  /// Use this method to identify if an incoming push notification is from Crisp and should be
  /// handled by the SDK. See ``CrispSDK/handlePushNotification(_:)``.
  ///
  /// - Parameter notification: The `UNNotification` object received by your app.
  /// - Returns: `true` if the notification is from Crisp, `false` otherwise.
  ///
  /// - Example:
  ///   ```swift
  ///   func userNotificationCenter(
  ///     _ center: UNUserNotificationCenter,
  ///     willPresent notification: UNNotification,
  ///     withCompletionHandler completionHandler:
  ///       @escaping (UNNotificationPresentationOptions) -> Void
  ///    ) {
  ///       if CrispSDK.isCrispPushNotification(notification) {
  ///           // Handle Crisp notification
  ///           CrispSDK.handlePushNotification(notification)
  ///           completionHandler([.banner, .sound])
  ///       } else {
  ///           // Handle other notifications
  ///           completionHandler([])
  ///       }
  ///   }
  ///   ```
  @objc public static func isCrispPushNotification(_ notification: UNNotification) -> Bool {
    CrispSDK._isRawCrispPushNotification(notification.request.content.userInfo)
  }

  @_documentation(visibility: private)
  @objc public static func _isRawCrispPushNotification(_ payload: [AnyHashable: Any]) -> Bool {
    (payload["sender"] as? String)?.lowercased() == "crisp" &&
      (payload["website_id"] as? String) != nil &&
      (payload["session_id"] as? String) != nil
  }

  /// Handles a Crisp push notification.
  ///
  /// Call this method when you receive a push notification that has been identified as a Crisp
  /// notification. See ``CrispSDK/isCrispPushNotification(_:)``.
  ///
  /// This method ensures proper processing of Crisp-specific notifications by the SDK.
  ///
  /// - Parameter notification: The `UNNotification` object received by your app.
  ///
  /// - Note: This method does nothing if the notification is not from Crisp.
  ///         Currently, this method is a placeholder and does not perform any actions. Future SDK
  ///         updates may add functionality to this method.
  ///
  /// - Example:
  ///   ```swift
  ///   func userNotificationCenter(_ center: UNUserNotificationCenter,
  ///                               didReceive response: UNNotificationResponse,
  ///                               withCompletionHandler completionHandler: @escaping () -> Void) {
  ///       let notification = response.notification
  ///       if CrispSDK.isCrispPushNotification(notification) {
  ///           CrispSDK.handlePushNotification(notification)
  ///       } else {
  ///           // Handle other notifications
  ///       }
  ///       completionHandler()
  ///   }
  ///   ```
  @objc public static func handlePushNotification(_ notification: UNNotification) {
    CrispSDK._handleRawPushNotification(notification.request.content.userInfo)
  }

  @_documentation(visibility: private)
  @objc public static func _handleRawPushNotification(_ payload: [AnyHashable: Any]) {
    guard CrispSDK._isRawCrispPushNotification(payload) else {
      return
    }
    // Does nothing yet
  }

  /// Opens target helpdesk article.
  ///
  /// `locale` and `slug` can be found in the full URL of the article; slug is the ID at the end
  /// of the URL; title and category are optional.
  ///
  /// ```swift
  /// // Example 1: opens an article with ID '10ud15y' for locale 'en' (English)
  /// CrispSDK.openHelpdeskArticle(locale: "en", slug: "10ud15y")
  /// ```
  ///
  /// ```swift
  /// // Example 1: opens an article with ID '10ud15y' for locale 'en' (English)
  /// CrispSDK.openHelpdeskArticle(
  ///     locale: "en",
  ///     slug: "1nko1cm",
  ///     title: "How to install Crisp Live Chat on Nuxt.js",
  ///     category: "Install Crisp"
  /// )
  /// ```
  ///
  /// - Note: If the ``ChatViewController`` (UIKit) or ``ChatView`` (SwiftUI) is currently
  /// presented, it will switch to the Helpdesk article immediately. If it is not presented yet
  /// it will start with the Helpdesk article on the next presentation.
  ///
  /// - Parameters:
  ///   - locale: The locale of the article to show.
  ///   - slug: The slug of the article to show.
  ///   - title: The title of the article to show.
  ///   - category: The category of the article to show.
  @objc public static func openHelpdeskArticle(
    locale: String,
    slug: String,
    title: String? = nil,
    category: String? = nil,
  ) {
    CrispSDK.apiModel.open(.helpdeskArticle(
      .init(
        title: title,
        category: category,
        excerpt: nil,
        locale: .init(rawValue: locale),
        slug: slug,
      ),
    ))
  }

  /// Shows a message as operator in local chatbox.
  ///
  /// Showing a local message won't initiate a conversation, i.e. the conversation will not show
  /// up in the Crisp app until either:
  ///   - Your user sends a message _or_
  ///   - You initiate the conversation by sending a message from the Crisp app
  ///
  /// - Parameter content: The content for the message to show.
  public static func showMessage(with content: Message.Content) {
    CrispSDK.apiModel.showMessage(fingerprint: nil, content: content.conversationMessageContent)
  }

  /// Adds a callback that is invoked when certain ChatBox events occur.
  ///
  /// Example:
  /// ```swift
  /// let cancelToken = CrispSDK.addCallback(.messageReceived { message in
  ///   print("Message received!", message)
  /// }
  /// ```
  ///
  /// - Parameter callback: The callback to add.
  /// - Returns: An opaque token that can be used to remove the callback with
  /// ``CrispSDK/removeCallback(token:)``.
  @discardableResult
  public static func addCallback(_ callback: Callback) -> CallbackToken {
    let chatCallback: ChatCallback = switch callback {
    case let .chatClosed(handler):
      .chatClosed(.init(handler: handler))

    case let .chatOpened(handler):
      .chatOpened(.init(handler: handler))

    case let .messageReceived(handler):
      .messageReceived(.init { conversationMessage in
        if let message = Message(conversationMessage) {
          handler(message)
        }
      })

    case let .messageSent(handler):
      .messageSent(.init { conversationMessage in
        if let message = Message(conversationMessage) {
          handler(message)
        }
      })

    case let .sessionLoaded(handler):
      .sessionLoaded(.init { sessionId in
        handler(sessionId.rawValue)
      })
    }

    self.apiModel.addCallback(chatCallback)

    return CallbackToken(id: chatCallback.id)
  }

  /// Removes a callback added with ``CrispSDK/addCallback(_:)``.
  ///
  /// - Parameter token: The token for the callback to remove.
  public static func removeCallback(token: CallbackToken) {
    CrispSDK.apiModel.removeCallback(token.id)
  }

  /// When set to `true`, displays a message that prompts the user to enable push notifications
  /// after they sent their first message. The default value is `true`.
  ///
  /// - Parameter flag: Whether to display a message with a notification permission prompt.
  @objc public static func setShouldPromptForNotificationPermission(_ flag: Bool) {
    CrispSDK.apiModel.configureShouldPromptForNotificationsPermission(flag)
  }

  @available(*, deprecated, message: "locale is no longer available")
  @objc public nonisolated(unsafe) static var locale = Locale.current

  /// The shared `User` object.
  @objc public static let user = User(model: CrispSDK.apiModel)

  /// The shared `Session` object.
  @objc public static let session = Session(model: CrispSDK.apiModel)

  /// The version of the Crisp SDK.
  public static var version: String {
    chatBoxVersion
  }

  static let apiModel = ChatBoxAPI()

  override private init() {
    super.init()
  }
}

private extension CrispSDK {
  nonisolated(unsafe) static var defaultLogHandlerAdded = false

  static func _configure(websiteID: String) {
    // swiftlint:disable:next no_direct_standard_out_logs
    print(
      "Initialized Crisp SDK (Version \(self.version), Web Client: \(webClientVersion), WebRTC enabled).",
    )

    CrispSDK.apiModel.configureWebsiteId(.init(websiteID))
  }
}

/// The log levels used in a `CrispLogHandler`.
@frozen public enum Severity: Int {
  case debug
  case info
  case warning
  case error
}

extension Severity: CustomStringConvertible {
  public var description: String {
    switch self {
    case .debug: "debug"
    case .info: "info"
    case .warning: "warning"
    case .error: "error"
    }
  }
}

private extension Severity {
  init(level: LogLevel) {
    switch level {
    case .debug:
      self = .debug
    case .info:
      self = .info
    case .warn:
      self = .warning
    case .error:
      self = .error
    }
  }
}

/// Allows providing a custom log handler for debug messages.
///
/// You can for example send these to a service like Firebase Crashlytics.
///
/// - See: ``CrispSDK/addLogHandler(_:)``
public protocol CrispLogHandler: Sendable {
  func log(severity: Severity, message: String)
  func log(error: any Error)
}

private struct LogHandlerWrapper<T: CrispLogHandler>: LogHandler {
  private let logger: T

  init(logger: T) {
    self.logger = logger
  }

  func log(
    level: LogLevel,
    message: String,
    timestamp _: Date,
    file _: StaticString,
    function _: StaticString,
    line _: UInt,
  ) {
    self.logger.log(severity: Severity(level: level), message: message)
  }

  func logError(
    _ error: any Error,
    timestamp _: Date,
    file _: StaticString,
    function _: StaticString,
    line _: UInt,
  ) {
    self.logger.log(error: error)
  }
}

public extension CrispSDK {
  /// Sets the log level for debug messages. Default is `warning`.
  static func setLogLevel(_ severity: Severity) {
    let level: LogLevel = switch severity {
    case .debug:
      .debug
    case .info:
      .info
    case .warning:
      .warn
    case .error:
      .error
    }
    CrispLogging.log.setLogLevel(level)
  }

  /// Adds a handler to log debug messages.
  ///
  /// The handler might be called from a thread other than the main thread.
  static func addLogHandler(_ handler: some CrispLogHandler) {
    CrispLogging.log.addLogHandler(LogHandlerWrapper(logger: handler))
  }

  @available(
    *,
    deprecated,
    message: "log is no longer available. Use addLogHandler(_:) to add a custom logging handler instead."
  )
  nonisolated(unsafe) static var log: (
    _: Severity,
    _: @autoclosure () -> String
  ) -> Void = { _, _ in }

  @available(
    *,
    deprecated,
    message: "logError is no longer available. Use addLogHandler(_:) to add a custom logging handler instead."
  )
  nonisolated(unsafe) static var logError: (any Error) -> Void = { _ in }
}
