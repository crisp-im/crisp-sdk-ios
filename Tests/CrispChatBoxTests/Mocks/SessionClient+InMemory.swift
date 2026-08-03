import CrispChatBox
import CrispUtils

struct SessionStorage {
  fileprivate let lock: LockIsolated<(current: Session?, previous: Session?)>

  var current: Session? {
    self.lock.value.current
  }

  var previous: Session? {
    self.lock.value.previous
  }

  init(current: Session? = nil, previous: Session? = nil) {
    self.lock = .init((current: current, previous: previous))
  }
}

extension SessionClient {
  static func inMemory(storage: SessionStorage) -> SessionClient {
    SessionClient(
      save: { newSession in storage.lock.withValue { $0.current = newSession } },
      load: { _ in storage.current },
      loadPrevious: { _ in storage.previous },
      reset: { storage.lock.withValue { $0.current = nil } },
      resetPrevious: { storage.lock.withValue { $0.previous = nil } },
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
