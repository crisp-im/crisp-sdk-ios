import Crisp
import CrispLogging
import Foundation

@MainActor @Observable
public final class SheetChatViewModel {
  enum Route {
    case chat
  }

  struct Callback {
    var called = false
    var data: String?
  }

  struct Callbacks {
    var chatOpened = Callback()
    var chatClosed = Callback()
    var messageReceived = Callback()
    var messageSent = Callback()
    var sessionLoaded = Callback()
  }

  var route: Route?
  var callbacks = Callbacks()

  var viewConfiguration: ChatViewConfiguration = .default

  init() {
    log.addLogHandler(OSLogHandler(label: "crisp-chatbox"))
    log.setLogLevel(.info)

    CrispSDK.addCallback(.chatOpened { [weak self] in
      self?.callbacks.chatOpened.called = true
    })

    CrispSDK.addCallback(.chatClosed { [weak self] in
      self?.callbacks.chatClosed.called = true
    })

    CrispSDK.addCallback(.sessionLoaded { [weak self] sessionId in
      self?.callbacks.sessionLoaded = .init(called: true, data: sessionId)
    })

    CrispSDK.addCallback(.messageReceived { [weak self] message in
      guard let self else { return }

      let encoder = JSONEncoder()
      encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

      let string = String(describing: message)

      let data = self.callbacks.messageReceived.data.map { "\($0)\n\n" } ?? ""
      self.callbacks.messageReceived.called = true
      self.callbacks.messageReceived.data = data + string
    })

    CrispSDK.addCallback(.messageSent { [weak self] message in
      guard let self else { return }

      let encoder = JSONEncoder()
      encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

      let string = String(describing: message)

      let data = self.callbacks.messageSent.data.map { "\($0)\n\n" } ?? ""
      self.callbacks.messageSent.called = true
      self.callbacks.messageSent.data = data + string
    })
  }

  func startChat() {
    self.route = .chat
  }

  func openHelpdesk() {
    CrispSDK.searchHelpdesk()
  }

  func loadLastSessionData() -> (key: String?, value: String?) {
    let key = UserDefaults.standard.string(forKey: .UserDefaultsKey.lastSessionDataKey)
    let value = UserDefaults.standard.string(forKey: .UserDefaultsKey.lastSessionDataValue)
    return (key: key, value: value)
  }

  func setSessionData(key: String, value: String) {
    UserDefaults.standard.set(key, forKey: .UserDefaultsKey.lastSessionDataKey)
    UserDefaults.standard.set(value, forKey: .UserDefaultsKey.lastSessionDataValue)
    CrispSDK.session.setString(value, forKey: key)
  }
}

extension SheetChatViewModel.Route: Identifiable {
  var id: String {
    switch self {
    case .chat: "chat"
    }
  }
}
