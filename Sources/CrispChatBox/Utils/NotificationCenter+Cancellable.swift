import class Combine.AnyCancellable
import Foundation

extension NSObjectProtocol {
  func store(in cancellables: inout Set<AnyCancellable>) {
    AnyCancellable {
      NotificationCenter.default.removeObserver(self)
    }.store(in: &cancellables)
  }
}
