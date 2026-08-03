import UIKit
import WebKit

final class ChatWebView: WKWebView {
  enum Action {
    case cut
    case paste
    case select
    case selectAll
  }

  var disabledActions = Set<Action>()

  /// Hide the inputAccessoryView with its prev/next buttons which gives away that this
  /// is a web page.
  override var inputAccessoryView: UIView? {
    nil
  }

  /// Allows us to hide default menu items when displaying the "Copy" menu for
  /// a long-pressed message.
  override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    if action == #selector(cut(_:)), self.disabledActions.contains(.cut) {
      return false
    }
    if action == #selector(paste(_:)), self.disabledActions.contains(.paste) {
      return false
    }
    if action == #selector(select(_:)), self.disabledActions.contains(.select) {
      return false
    }
    if action == #selector(selectAll(_:)), self.disabledActions.contains(.selectAll) {
      return false
    }
    return super.canPerformAction(action, withSender: sender)
  }
}
