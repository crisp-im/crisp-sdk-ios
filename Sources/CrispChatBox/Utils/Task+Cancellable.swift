@_exported import class Combine.AnyCancellable
import Foundation

extension Task {
  func asCancellable() -> AnyCancellable {
    AnyCancellable {
      self.cancel()
    }
  }

  func store(in cancellables: inout Set<AnyCancellable>) {
    self.asCancellable().store(in: &cancellables)
  }
}
