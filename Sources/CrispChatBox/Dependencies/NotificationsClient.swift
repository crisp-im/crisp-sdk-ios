import CrispLogging
import Foundation
import UserNotifications

package struct NotificationsClient {
  package var requestPushNotificationsPermission: @Sendable () async -> Void
  package var notificationPermission: @Sendable () -> AsyncStream<NotificationPermission>

  package init(
    requestPushNotificationsPermission: @Sendable @escaping () async -> Void,
    notificationPermission: @Sendable @escaping () -> AsyncStream<NotificationPermission>,
  ) {
    self.requestPushNotificationsPermission = requestPushNotificationsPermission
    self.notificationPermission = notificationPermission
  }
}

package extension NotificationsClient {
  static let live: Self = {
    let storage = PermissionStorage()

    return .init(
      requestPushNotificationsPermission: {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        do {
          _ = try await UNUserNotificationCenter.current().requestAuthorization(options: options)
        } catch {
          log.error(error)
        }
        await storage.refresh()
      },
      notificationPermission: {
        AsyncStream { continuation in
          let task = Task {
            await storage.refresh()
            for await value in await storage.stream() {
              continuation.yield(value)
            }
            continuation.finish()
          }
          continuation.onTermination = { _ in
            task.cancel()
          }
        }
      },
    )
  }()

  static let noop = NotificationsClient(
    requestPushNotificationsPermission: {},
    notificationPermission: { AsyncStream { _ in } },
  )
}

private actor PermissionStorage {
  private var currentValue: NotificationPermission = .notDetermined
  private var continuations: [UUID: AsyncStream<NotificationPermission>.Continuation] = [:]

  func refresh() async {
    let settings = await UNUserNotificationCenter.current().notificationSettings()
    let permission = NotificationPermission(authorizationStatus: settings.authorizationStatus)
    self.currentValue = permission
    for continuation in self.continuations.values {
      continuation.yield(permission)
    }
  }

  func stream() -> AsyncStream<NotificationPermission> {
    AsyncStream { continuation in
      let id = UUID()
      continuation.yield(self.currentValue)
      self.register(id: id, continuation: continuation)
      continuation.onTermination = { [weak self] _ in
        guard let self else { return }
        Task { await self.unregister(id: id) }
      }
    }
  }

  private func register(id: UUID, continuation: AsyncStream<NotificationPermission>.Continuation) {
    self.continuations[id] = continuation
  }

  private func unregister(id: UUID) {
    self.continuations.removeValue(forKey: id)
  }
}

private extension NotificationPermission {
  init(authorizationStatus: UNAuthorizationStatus) {
    switch authorizationStatus {
    case .notDetermined:
      self = .notDetermined
    case .denied:
      self = .denied
    case .authorized:
      self = .authorized
    case .provisional:
      self = .provisional
    case .ephemeral:
      self = .ephemeral
    @unknown default:
      self = .notDetermined
    }
  }
}
