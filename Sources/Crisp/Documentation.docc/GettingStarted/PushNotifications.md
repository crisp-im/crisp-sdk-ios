# Handling Push Notifications

Learn how to integrate Crisp push notifications into your app.

> Important: Currently, push notifications are only sent to production APNs channels. Notifications will not be received when testing with development provisioning profiles or in sandbox mode. This limitation will be resolved in a future update.

## Prerequisites

1. Create an APNs-enabled private key in your Apple Developer account. See the [Apple documentation](https://developer.apple.com/help/account/manage-keys/create-a-private-key/) for detailed instructions.

2. Upload your key and configure push notifications in the Crisp web app at `Settings > Chatbox Settings > Push Notifications`.

3. Add the "Push Notifications" capability to your app:
   - Open your project in Xcode
   - Select your target
   - Go to the "Signing & Capabilities" tab
   - Click the "+" button and add "Push Notifications"

![Add Push Notifications capability](apns-capability)

## Implementation

### Setting the Device Token

If you're not already doing so, make sure to [register for remote notifications](https://developer.apple.com/documentation/usernotifications/registering-your-app-with-apns) in your app's delegate:

```swift
func application(_ application: UIApplication, 
                 didFinishLaunchingWithOptions launchOptions:[UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    UIApplication.shared.registerForRemoteNotifications()
    return true
}
```

When your app successfully registered for remote notifications, pass the device token to Crisp SDK:

```swift
import Crisp

func application(_ application: UIApplication,
                 didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    CrispSDK.setDeviceToken(deviceToken)
}
```

See ``CrispSDK/setDeviceToken(_:)``

Finally, make sure to [request permission](https://developer.apple.com/documentation/usernotifications/asking-permission-to-use-notifications) from your user to allow remote notifications for your app:

```swift
do {
    try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
} catch {
    // Handle the error here.
}
```

### Identifying Crisp Notifications

To determine if a received notification is from Crisp, use the ``CrispSDK/isCrispPushNotification(_:)`` method:

```swift
func userNotificationCenter(_ center: UNUserNotificationCenter,
                            willPresent notification: UNNotification,
                            withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    if CrispSDK.isCrispPushNotification(notification) {
        // Handle Crisp notification
        CrispSDK.handlePushNotification(notification)
        completionHandler([.banner, .sound])
    } else {
        // Handle other notifications
        completionHandler([])
    }
}
```

### Handling Crisp Notifications

When a Crisp notification is received, use the ``CrispSDK/handlePushNotification(_:)`` method to process it:

```swift
func userNotificationCenter(_ center: UNUserNotificationCenter,
                            didReceive response: UNNotificationResponse,
                            withCompletionHandler completionHandler: @escaping () -> Void) {
    let notification = response.notification
    if CrispSDK.isCrispPushNotification(notification) {
        CrispSDK.handlePushNotification(notification)
    } else {
        // Handle other notifications
    }
    completionHandler()
}
```
