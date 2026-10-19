internal import CrispChatBox
import Foundation

/// Configuration options that control the appearance and behavior of a ChatViewController/ChatView.
public final class ChatViewConfiguration: Sendable {
  private struct Inner {
    var activatesTextFieldOnAppear: Bool
    var colorMode: ColorMode?
  }

  private let inner: LockIsolated<Inner>

  /// Determines whether the message input field automatically becomes first responder when the
  /// ChatViewController/ChatView appears. When set to `true`, the keyboard will be shown
  /// immediately after the ChatViewController/ChatView is presented. Default value is `true`.
  public var activatesTextFieldOnAppear: Bool {
    get { self.inner.activatesTextFieldOnAppear }
    set { self.inner.withValue { $0.activatesTextFieldOnAppear = newValue } }
  }

  /// Overrides the color mode set in the Crisp dashboard. Default value is `nil`.
  public var colorMode: ColorMode? {
    get { self.inner.colorMode }
    set { self.inner.withValue { $0.colorMode = newValue } }
  }

  private init(activatesTextFieldOnAppear: Bool, colorMode: ColorMode?) {
    self.inner = .init(.init(
      activatesTextFieldOnAppear: activatesTextFieldOnAppear,
      colorMode: colorMode,
    ))
  }
}

public extension ChatViewConfiguration {
  static let `default` = ChatViewConfiguration(
    activatesTextFieldOnAppear: true,
    colorMode: nil,
  )
}

extension ChatViewConfiguration {
  var chatBoxConfiguration: CrispChatBox.ChatViewConfiguration {
    .init(
      activatesTextFieldOnAppear: self.activatesTextFieldOnAppear,
      colorMode: self.colorMode?.chatBoxColorMode,
    )
  }
}
