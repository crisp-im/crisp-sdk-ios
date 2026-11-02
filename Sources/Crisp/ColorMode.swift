internal import CrispChatBoxFFI

/// The color mode of the chat.
public enum ColorMode: Sendable {
  /// Always light, regardless of the device appearance.
  case light
  /// Always dark, regardless of the device appearance.
  case dark
  /// Follows the device appearance.
  case auto
}

extension ColorMode {
  var chatBoxColorMode: CrispChatBoxFFI.ColorMode {
    switch self {
    case .light: .light
    case .dark: .dark
    case .auto: .auto
    }
  }
}
