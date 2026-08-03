import CrispUtils
import Foundation

final class CommandQueue: Sendable {
  private struct State {
    var commands = [Command]()
    var onAppend: (() -> Void)?
  }

  private let state = LockIsolated(State())

  init() {}

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

  func resetAndEnqueue(_ command: Command) {
    self.state.withValue {
      $0.commands.removeAll()
      $0.commands.append(command)
      $0.onAppend?()
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
