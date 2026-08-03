import CrispDomain
import Foundation

package struct Environment {
  package var locales: [LocaleId]
  package var openURL: OpenURLEffect
  package var notifications: NotificationsClient
  package var session: SessionClient
  package var lifecycle: LifecycleClient
  package var pasteboard: PasteboardClient
}

package extension Environment {
  @MainActor
  static let live = Environment(
    locales: Locales.live,
    openURL: .live,
    notifications: .live,
    session: .live(userDefaults: .standard),
    lifecycle: .live(),
    pasteboard: .live(),
  )
}
