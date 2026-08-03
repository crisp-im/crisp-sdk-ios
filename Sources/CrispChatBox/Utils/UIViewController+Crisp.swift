import UIKit

extension UIViewController {
  /// Returns `true` if the current ViewController or one of its parents is being permanently
  /// removed from the view hierarchy.
  var crisp_isBeingRemoved: Bool {
    // When pushing more than one ViewController on a UINavigationController very
    // rapidly (think, same runloop cycle), apparently it can happen that the the first
    // ViewController receives a will-/didDisappear call - correctly, since it did disappear -
    // where `isMovingFromParent` equals `true`. However, the `parent`(ViewController) is not nil
    // in these cases, which is why we check for it.
    (self.isMovingFromParent && self.parent == nil) ||
      self.isBeingDismissed ||
      self.parent?.crisp_isBeingRemoved ?? false
  }
}
