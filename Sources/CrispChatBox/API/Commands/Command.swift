import CrispChatBoxFFI
import CrispDomain
import Foundation

package enum Command {
  // Session
  case reset
  case setSessionData([String: any Encodable & Sendable])
  case setSegments(segments: [String], overwrite: Bool)
  case pushEvents([SessionEvent])
  case runBotScenario(BotScenarioId)

  // User
  case setNickname(String)
  case setEmail(address: String, signature: String?)
  case setPhone(String)
  case setAvatar(URL)
  case setCompany(CrispChatBoxFFI.Company)

  // Notifications
  case setDeviceToken(DeviceToken)
  case unsetDeviceToken(DeviceToken)

  // UI
  case injectMessage(Message)
  case showMessage(fingerprint: MessageFingerprint?, content: ConversationMessageContent)
  case open(OpenIntent)
}

extension Command {
  /// Discriminant used by coalescing to identify commands of the same kind.
  var kind: Kind {
    switch self {
    case .reset: .reset
    case .setSessionData: .setSessionData
    case .setSegments: .setSegments
    case .pushEvents: .pushEvents
    case .runBotScenario: .runBotScenario
    case .setNickname: .setNickname
    case .setEmail: .setEmail
    case .setPhone: .setPhone
    case .setAvatar: .setAvatar
    case .setCompany: .setCompany
    case .setDeviceToken: .setDeviceToken
    case .unsetDeviceToken: .unsetDeviceToken
    case .showMessage: .showMessage
    case .open: .open
    case .injectMessage: .injectMessage
    }
  }

  enum Kind: Hashable {
    case reset
    case setSessionData
    case setSegments
    case pushEvents
    case runBotScenario
    case setNickname
    case setEmail
    case setPhone
    case setAvatar
    case setCompany
    case setDeviceToken
    case unsetDeviceToken
    case showMessage
    case open
    case injectMessage
  }
}
