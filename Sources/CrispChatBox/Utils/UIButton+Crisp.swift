import UIKit

extension UIButton {
  static func crisp_roundedButton(title: String, primaryAction: UIAction?) -> UIButton {
    let button = UIButton(type: .roundedRect, primaryAction: primaryAction)
    button.setTitle(title, for: .normal)

    button.translatesAutoresizingMaskIntoConstraints = false
    button.layer.borderWidth = 1
    button.layer.borderColor = UIColor.opaqueSeparator.cgColor
    button.layer.cornerCurve = .continuous
    button.layer.cornerRadius = 9
    button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

    return button
  }
}
