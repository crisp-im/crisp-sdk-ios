import CrispUtils
import Foundation

/// Identifies one `enqueueReset()` call, so that a boot only completes the reset it applied and
/// not one requested while it was underway.
struct ResetRequest: Equatable {
  fileprivate let id: Int
}

final class CommandQueue: Sendable {
  private struct State {
    var commands = [Command]()
    var pendingReset: ResetRequest?
    var resetCount = 0
    var onAppend: (() -> Void)?
  }

  private let state: LockIsolated<State>
  private let session: SessionClient

  init(session: SessionClient) {
    // Restore a reset that was still pending when the app was terminated, so that e.g. a logout
    // right before the app was killed is still applied on the next boot.
    let isResetPending = session.isResetPending()
    self.state = LockIsolated(
      State(
        pendingReset: isResetPending ? ResetRequest(id: 1) : nil,
        resetCount: isResetPending ? 1 : 0,
      ),
    )
    self.session = session
  }

  func enqueue(_ command: Command) {
    self.state.withValue {
      $0.commands.append(command)
      $0.onAppend?()
    }
  }

  func enqueueFront(_ command: Command) {
    self.state.withValue {
      $0.commands.insert(command, at: 0)
      $0.onAppend?()
    }
  }

  func dequeueCoalesced() -> [Command] {
    self.state.withValue {
      let commands = $0.commands.coalesced()
      $0.commands.removeAll()
      return commands
    }
  }

  /// Requests a session reset and discards the pending session-scoped commands. Commands that
  /// belong to the app install rather than to the session (see ``Command/outlivesReset``) are
  /// kept so that they apply to the new session.
  ///
  /// The reset stays pending until a boot that applied it calls ``completeReset(_:)``.
  func enqueueReset() {
    self.state.withValue {
      $0.commands.removeAll { !$0.outlivesReset }
      $0.resetCount += 1
      $0.pendingReset = ResetRequest(id: $0.resetCount)
      self.session.setResetPending(true)
      $0.onAppend?()
    }
  }

  var pendingReset: ResetRequest? {
    self.state.withValue { $0.pendingReset }
  }

  func completeReset(_ request: ResetRequest) {
    self.state.withValue {
      if $0.pendingReset == request {
        $0.pendingReset = nil
        self.session.setResetPending(false)
      }
    }
  }

  func setOnAppendHandler(_ handler: (@Sendable () -> Void)?) {
    self.state.withValue { $0.onAppend = handler }
  }
}

#if DEBUG
  extension CommandQueue {
    var commands: [Command] {
      self.state.withValue {
        $0.commands
      }
    }
  }
#endif
