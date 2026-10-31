import CrispChatBox
import CrispUtils

struct SessionStorage {
  fileprivate let lock: LockIsolated<(current: Session?, previous: Session?, isResetPending: Bool)>

  var current: Session? {
    self.lock.value.current
  }

  var previous: Session? {
    self.lock.value.previous
  }

  var isResetPending: Bool {
    self.lock.value.isResetPending
  }

  init(current: Session? = nil, previous: Session? = nil, isResetPending: Bool = false) {
    self.lock = .init((current: current, previous: previous, isResetPending: isResetPending))
  }
}

extension SessionClient {
  static func inMemory(storage: SessionStorage) -> SessionClient {
    SessionClient(
      save: { newSession in storage.lock.withValue { $0.current = newSession } },
      load: { _ in storage.current },
      loadPrevious: { _ in storage.previous },
      reset: {
        storage.lock.withValue {
          if let current = $0.current {
            $0.previous = current
          }
          $0.current = nil
        }
      },
      resetPrevious: { storage.lock.withValue { $0.previous = nil } },
      isResetPending: { storage.isResetPending },
      setResetPending: { isPending in storage.lock.withValue { $0.isResetPending = isPending } },
      modifySettings: { _, handler in
        storage.lock.withValue {
          if var session = $0.current {
            handler(&session.settings)
            $0.current = session
          }
        }
      },
    )
  }
}
