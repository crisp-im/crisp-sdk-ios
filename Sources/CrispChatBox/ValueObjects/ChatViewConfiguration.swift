import Foundation

/// Configuration options that control the appearance and behavior of a ChatViewController.
package struct ChatViewConfiguration {
  /// Determines whether the message input field automatically becomes first responder when the
  /// ChatViewController appears. When set to `true`, the keyboard will be shown immediately after
  /// the ChatViewController is presented. Default value is `false`.
  package var activatesTextFieldOnAppear: Bool

  package init(activatesTextFieldOnAppear: Bool = true) {
    self.activatesTextFieldOnAppear = activatesTextFieldOnAppear
  }
}
