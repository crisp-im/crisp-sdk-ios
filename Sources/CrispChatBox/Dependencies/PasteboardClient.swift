import UIKit

package struct PasteboardClient {
  package var copyString: @Sendable (String) -> Void

  package init(copyString: @Sendable @escaping (String) -> Void) {
    self.copyString = copyString
  }
}

package extension PasteboardClient {
  static func live(pasteboard: UIPasteboard = .general) -> Self {
    .init(copyString: { pasteboard.string = $0 })
  }
}
