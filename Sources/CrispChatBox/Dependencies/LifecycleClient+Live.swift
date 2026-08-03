import Network
import UIKit

private actor Broadcaster<Value: Sendable> {
  private var currentValue: Value
  private var continuations = [UUID: AsyncStream<Value>.Continuation]()

  init(initialValue: Value) {
    self.currentValue = initialValue
  }

  var value: Value {
    self.currentValue
  }

  func send(_ value: Value) {
    self.currentValue = value
    for continuation in self.continuations.values {
      continuation.yield(value)
    }
  }

  func stream(replayCurrent: Bool = true) -> AsyncStream<Value> {
    AsyncStream { continuation in
      if replayCurrent {
        continuation.yield(self.currentValue)
      }

      let id = UUID()
      self.register(id: id, continuation: continuation)

      continuation.onTermination = { [weak self] _ in
        guard let self else { return }
        Task { await self.unregister(id: id) }
      }
    }
  }

  private func register(id: UUID, continuation: AsyncStream<Value>.Continuation) {
    self.continuations[id] = continuation
  }

  private func unregister(id: UUID) {
    self.continuations.removeValue(forKey: id)
  }
}

private extension NotificationCenter {
  func crisp_notificationStream(named name: Notification.Name) -> AsyncStream<Void> {
    AsyncStream { continuation in
      nonisolated(unsafe) let observer = self.addObserver(
        forName: name,
        object: nil,
        queue: nil,
      ) { _ in
        continuation.yield(())
      }
      continuation.onTermination = { _ in
        self.removeObserver(observer)
      }
    }
  }
}

private let connectivityBroadcaster = Broadcaster<Connectivity>(initialValue: .online)
private let pathMonitorQueue = DispatchQueue(label: "im.crisp.app.pathmonitor")

private let pathMonitor: NWPathMonitor = {
  let monitor = NWPathMonitor()
  monitor.pathUpdateHandler = { path in
    let connectivity: Connectivity = switch path.status {
    case .satisfied:
      .online
    case .unsatisfied, .requiresConnection:
      .offline
    @unknown default:
      .offline
    }
    Task { await connectivityBroadcaster.send(connectivity) }
  }
  monitor.start(queue: pathMonitorQueue)
  return monitor
}()

package extension LifecycleClient {
  @MainActor
  static func live(
    currentApplicationState: UIApplication.State = UIApplication.shared.applicationState,
  ) -> LifecycleClient {
    // Ensure the network monitor is started.
    _ = pathMonitor

    return LifecycleClient(
      applicationWillEnterForeground: {
        NotificationCenter.default
          .crisp_notificationStream(named: UIApplication.willEnterForegroundNotification)
      },
      applicationDidEnterBackground: {
        NotificationCenter.default
          .crisp_notificationStream(named: UIApplication.didEnterBackgroundNotification)
      },
      connectivity: {
        AsyncStream { continuation in
          let task = Task {
            for await value in await connectivityBroadcaster.stream() {
              continuation.yield(value)
            }
            continuation.finish()
          }
          continuation.onTermination = { _ in task.cancel() }
        }
      },
    )
  }
}
