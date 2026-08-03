import Crisp
import CrispLogging
import SwiftUI
import UserNotifications

@main
struct DemoApp: App {
  @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

  var body: some Scene {
    WindowGroup {
      MainView(model: MainViewModel())
    }
  }
}

private final class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil,
  ) -> Bool {
    application.registerForRemoteNotifications()
    UNUserNotificationCenter.current().delegate = self
    return true
  }

  func application(
    _: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data,
  ) {
    CrispSDK.setDeviceToken(deviceToken)
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  nonisolated func userNotificationCenter(
    _: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
  ) async {
    let content = response.notification.request.content
    log.info("Received notification: \(content.title) — \(content.body)")
    log.debug("Notification content: \(content)")
  }

  nonisolated func userNotificationCenter(
    _: UNUserNotificationCenter,
    willPresent notification: UNNotification,
  ) async -> UNNotificationPresentationOptions {
    let content = notification.request.content
    log.info("Will present: \(content.title) — \(content.body)")
    log.debug("Notification userInfo: \(content.userInfo)")

    return [.badge, .banner, .list, .sound]
  }
}
