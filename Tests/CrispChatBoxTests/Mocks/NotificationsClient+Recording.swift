import CrispChatBox
import Foundation

@MainActor
final class NotificationsRecorder {
  private(set) var permissionRequestCount = 0

  fileprivate let permissionStream: AsyncStream<NotificationPermission>
  private let permissionContinuation: AsyncStream<NotificationPermission>.Continuation

  init() {
    let (stream, continuation) = AsyncStream<NotificationPermission>.makeStream()
    self.permissionStream = stream
    self.permissionContinuation = continuation
  }

  func recordPermissionRequest() {
    self.permissionRequestCount += 1
  }

  func setPermission(_ permission: NotificationPermission) {
    self.permissionContinuation.yield(permission)
  }
}

extension NotificationsClient {
  static func recording(into recorder: NotificationsRecorder) -> Self {
    .init(
      requestPushNotificationsPermission: {
        await MainActor.run { recorder.recordPermissionRequest() }
      },
      notificationPermission: { recorder.permissionStream },
    )
  }
}
