import CrispChatBoxFFI

/// Configuration options that control the appearance and behavior of a ChatViewController.
package struct ChatViewConfiguration {
  /// Determines whether the message input field automatically becomes first responder when the
  /// ChatViewController appears. When set to `true`, the keyboard will be shown immediately after
  /// the ChatViewController is presented. Default value is `false`.
  package var activatesTextFieldOnAppear: Bool

  /// Overrides the color mode set in the Crisp dashboard. `nil` keeps the dashboard's color mode.
  package var colorMode: ColorMode?

  package init(activatesTextFieldOnAppear: Bool = true, colorMode: ColorMode? = nil) {
    self.activatesTextFieldOnAppear = activatesTextFieldOnAppear
    self.colorMode = colorMode
  }
}
