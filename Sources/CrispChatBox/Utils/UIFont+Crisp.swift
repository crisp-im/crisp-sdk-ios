import UIKit

extension UIFont {
  static func crisp_boldFont(forTextStyle textStyle: UIFont.TextStyle) -> UIFont {
    let font = UIFont.preferredFont(forTextStyle: textStyle)
    return font.fontDescriptor
      .withSymbolicTraits(.traitBold)
      .map { UIFont(descriptor: $0, size: 0) } ?? font
  }
}
