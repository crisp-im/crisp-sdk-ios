import CrispChatBoxFFI
import UIKit

package extension ColorMode {
  var userInterfaceStyle: UIUserInterfaceStyle {
    switch self {
    case .light: .light
    case .dark: .dark
    case .auto: .unspecified
    }
  }
}
