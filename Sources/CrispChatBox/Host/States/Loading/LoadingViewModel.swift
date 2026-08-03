import Foundation

@MainActor
package final class LoadingViewModel {
  let onCancel: (() -> Void)?

  var canCancel: Bool {
    self.onCancel != nil
  }

  init(onCancel: (() -> Void)?) {
    self.onCancel = onCancel
  }

  func cancelButtonTapped() {
    self.onCancel?()
  }
}
