import Foundation

package enum NotificationPermission: Equatable {
  case notDetermined
  case denied
  case authorized
  case provisional
  case ephemeral
}
