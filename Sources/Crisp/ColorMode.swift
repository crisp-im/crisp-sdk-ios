internal import CrispChatBox

/// The color mode of the chat.
public enum ColorMode: Sendable {
  case light
  case dark
  case auto
}

extension ColorMode {
  var chatBoxColorMode: CrispChatBox.ColorMode {
    switch self {
    case .light: .light
    case .dark: .dark
    case .auto: .auto
    }
  }
}
