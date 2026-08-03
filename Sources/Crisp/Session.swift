internal import CrispChatBox
internal import CrispChatBoxFFI
internal import CrispUtils
import Foundation

@objc(CRSPSessionEventColor)
public enum SessionEventColor: Int, Sendable {
  case red
  case orange
  case yellow
  case green
  case blue
  case purple
  case pink
  case brown
  case grey
  case black
}

/// Represents a session event.
///
/// If you are using Crisp in an app where users are authenticated, you may want to push events
/// to retarget them later on different channels.
///
/// - Note: You should not create an instance of this class yourself. Instead interact with the
/// shared instance at ``CrispSDK/session``.
@objc(CRSPSessionEvent) @objcMembers public final class SessionEvent: NSObject, Sendable {
  private struct Inner {
    var data = [String: any Sendable & Encodable]()
    var name: String
    var color: SessionEventColor?
  }

  private let inner: LockIsolated<Inner>

  /// The name of the event.
  public var name: String {
    get { self.inner.name }
    set { self.inner.withValue { $0.name = newValue } }
  }

  /// The color of the event.
  public var color: SessionEventColor? {
    get { self.inner.color }
    set { self.inner.withValue { $0.color = newValue } }
  }

  /// Initializes a new `SessionEvent`.
  /// - Parameters:
  ///   - name: The name for the event.
  ///   - color: The color for the event.
  public init(name: String, color: SessionEventColor?) {
    self.inner = .init(.init(name: name, color: color))
    super.init()
  }

  /// Set the event data for a given key, with a `Bool` value.
  public func setBool(_ value: Bool, forKey key: String) {
    self.inner.withValue { $0.data[key] = value }
  }

  /// Set the event data for a given key, with a `Int` value.
  public func setInt(_ value: Int, forKey key: String) {
    self.inner.withValue { $0.data[key] = value }
  }

  /// Set the event data for a given key, with a `String` value.
  public func setString(_ value: String, forKey key: String) {
    self.inner.withValue { $0.data[key] = value }
  }
}

/// Represents the current session.
@objc(CRSPSession) @objcMembers public final class Session: NSObject, Sendable {
  private struct Inner {
    var data = [String: any Sendable]()
    var segments: [String]?
  }

  private let inner: LockIsolated<Inner>
  private let model: ChatBoxAPI

  /// Returns true if a session is ongoing (ie. messages have been received or sent), else false.
  public var isOngoing: Bool {
    self.model.isSessionOngoing
  }

  /// Returns the current session identifier (or null if not yet loaded).
  public var identifier: String? {
    self.model.sessionId?.rawValue
  }

  /// Set the session data for a given key, with a `Bool` value.
  public func setBool(_ value: Bool, forKey key: String) {
    self.model.setSessionData([key: value])
    self.inner.withValue { $0.data[key] = value }
  }

  /// Set the session data for a given key, with a `String` value.
  public func getBool(forKey key: String) -> Bool? {
    (self.inner.data[key] as? Bool) ?? self.model.visitorData?.data?[key] as? Bool
  }

  /// Set the session data for a given key, with a `Int` value.
  public func setInt(_ value: Int, forKey key: String) {
    self.model.setSessionData([key: value])
    self.inner.withValue { $0.data[key] = value }
  }

  /// Returns the current session data for a given key.
  public func getInt(forKey key: String) -> Int? {
    (self.inner.data[key] as? Int) ?? self.model.visitorData?.data?[key] as? Int
  }

  /// Set the session data for a given key, with a `String` value.
  public func setString(_ value: String, forKey key: String) {
    self.model.setSessionData([key: value])
    self.inner.withValue { $0.data[key] = value }
  }

  /// Returns the current session data for a given key.
  public func getString(forKey key: String) -> String? {
    (self.inner.data[key] as? String) ?? self.model.visitorData?.data?[key] as? String
  }

  @available(*, deprecated, renamed: "pushEvents")
  public func pushEvent(_ event: SessionEvent) {
    self.pushEvents([event])
  }

  /// Sets one or multiple session events, with a text and an optional data object and optional
  /// color.
  /// - Parameter events: The events to push
  public func pushEvents(_ events: [SessionEvent]) {
    self.model.pushEvents(events.map(\.sessionEvent))
  }

  @available(*, deprecated, renamed: "segments")
  public var segment: String? {
    get { self.segments?.first }
    set {
      if let segment = newValue {
        self.setSegments([segment])
      }
    }
  }

  /// Sets the session segments.
  @available(*, deprecated, message: "Use 'setSegments(_:overwrite:)' instead.")
  public var segments: [String]? {
    get {
      self.inner.segments ?? self.model.visitorData?.segments?.map(\.rawValue)
    }
    set {
      if let segments = newValue {
        self.setSegments(segments)
      }
    }
  }

  /// Sets the session segments.
  public func setSegments(_ segments: [String], overwrite: Bool = false) {
    let segments = segments.compactMap { $0.trimmedNonEmptyString() }
    self.model.setSegments(segments, overwrite: overwrite)
    self.inner.withValue { $0.segments = segments }
  }

  /// Runs a Bot scenario with given identifier (from configured Bot scenarios, if the Bot plugin is
  /// enabled on your website).
  public func runBotScenario(id: String) {
    self.model.runBotScenario(id: .init(rawValue: id))
  }

  /// Initiates a new chat session by resetting the chatbox.
  ///
  /// This method should be invoked when the user logs out in your application.
  ///
  /// - Important:
  ///   If you have associated a token with the current chat session by calling
  ///   ``CrispSDK/setTokenID(tokenID:)`` you need to reset the token first before calling this
  ///   method, otherwise the user's chat session would be restored.
  ///
  ///   **Example of logout handling, if a token was configured:**
  ///   ```swift
  ///   func userLogout() {
  ///     // Execute this sequence when your users are logging out
  ///     CrispSDK.setTokenID(nil) // 1. Clear the token value
  ///     CrispSDK.session.reset() // 2. Unbind the current session
  ///   }
  ///   ```
  ///
  /// - seealso: ``CrispSDK/setTokenID(tokenID:)``
  public func reset() {
    self.model.resetSession()
    CrispSDK.user.reset()
    self.inner.setValue(.init())
  }

  init(model: ChatBoxAPI) {
    self.model = model
    self.inner = .init(.init())
    super.init()
  }
}

private extension SessionEvent {
  var sessionEvent: CrispChatBoxFFI.SessionEvent {
    .init(
      name: self.name,
      color: self.color?.color,
      data: self.inner.data,
    )
  }
}

private extension SessionEventColor {
  var color: CrispChatBoxFFI.SessionEvent.Color {
    switch self {
    case .red:
      .red
    case .orange:
      .orange
    case .yellow:
      .yellow
    case .green:
      .green
    case .blue:
      .blue
    case .purple:
      .purple
    case .pink:
      .pink
    case .brown:
      .brown
    case .grey:
      .grey
    case .black:
      .black
    }
  }
}
