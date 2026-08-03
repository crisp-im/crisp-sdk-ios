import Foundation

@MainActor
package final class FailureViewModel {
  let error: CrispHostError

  let onRetry: (() -> Void)?
  let onCancel: (() -> Void)?

  var canRetry: Bool {
    self.onRetry != nil
  }

  var canCancel: Bool {
    self.onCancel != nil
  }

  init(
    error: CrispHostError,
    onRetry: (() -> Void)?,
    onCancel: (() -> Void)?,
  ) {
    self.error = error
    self.onRetry = onRetry
    self.onCancel = onCancel
  }

  func retryButtonTapped() {
    self.onRetry?()
  }

  func cancelButtonTapped() {
    self.onCancel?()
  }
}
