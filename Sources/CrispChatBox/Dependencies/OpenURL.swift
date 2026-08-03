import UIKit

package struct OpenURLEffect {
  private let handler: @Sendable (URL) async -> Bool

  package init(handler: @Sendable @escaping (URL) async -> Bool) {
    self.handler = handler
  }

  package func callAsFunction(_ url: URL) async -> Bool {
    await self.handler(url)
  }
}

package extension OpenURLEffect {
  static let live = OpenURLEffect { url in
    await withCheckedContinuation { continuation in
      Task { @MainActor in
        UIApplication.shared.open(url) { canOpen in
          continuation.resume(returning: canOpen)
        }
      }
    }
  }

  static let noop = OpenURLEffect { _ in false }
}
