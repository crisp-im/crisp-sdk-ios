import CrispChatBoxFFI
import Foundation

@MainActor
package final class RecordingJSEvaluator {
  struct TimeoutError: Error {}

  private struct Waiter {
    let id: UUID
    let predicate: (String) -> Bool
    let continuation: CheckedContinuation<String, any Error>
  }

  package private(set) var calls: [String] = []

  private var waiters = [Waiter]()
  private let handler: (String) async throws -> Any?

  package init(handler: @escaping (String) async throws -> Any? = { _ in nil }) {
    self.handler = handler
  }

  package func asEvaluator() -> JSEvaluator {
    { [self] js in
      try await self.evaluate(js)?.value
    }
  }

  @discardableResult
  package func waitForCall(
    matching predicate: @Sendable @escaping (String) -> Bool,
    timeout: UInt64 = NSEC_PER_MSEC * 500,
  ) async throws -> String {
    if let existing = calls.first(where: predicate) {
      return existing
    }

    let id = UUID()

    // Register the waiter synchronously on the MainActor so that any concurrent
    // `evaluate(_:)` running on the same actor can see and wake it. Spawning the
    // waiter via TaskGroup would leave a check-then-append window during which
    // a matching call could slip through and be missed.
    return try await withCheckedThrowingContinuation { cont in
      self.waiters.append(Waiter(id: id, predicate: predicate, continuation: cont))

      Task { @MainActor [weak self] in
        try? await Task.sleep(nanoseconds: timeout)
        self?.removeWaiter(id: id)
      }
    }
  }
}

// swiftlint:disable:next no_unchecked_sendable
private struct SendableJSValue: @unchecked Sendable {
  let value: Any?
}

private extension RecordingJSEvaluator {
  private func evaluate(_ js: String) async throws -> SendableJSValue? {
    self.calls.append(js)

    // Wake any waiters whose predicate now matches.
    self.waiters.removeAll { waiter in
      if waiter.predicate(js) {
        waiter.continuation.resume(returning: js)
        return true
      }
      return false
    }

    return try await SendableJSValue(value: self.handler(js))
  }

  private func removeWaiter(id: UUID) {
    if let idx = waiters.firstIndex(where: { $0.id == id }) {
      let w = self.waiters.remove(at: idx)
      w.continuation.resume(throwing: TimeoutError())
    }
  }
}
