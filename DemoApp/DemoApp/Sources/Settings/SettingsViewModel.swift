import Crisp
import Foundation
import SwiftUI

@MainActor @Observable
public final class SettingsViewModel {
  var websiteId: String? {
    didSet {
      if self.websiteId != oldValue {
        self.websiteIdDidChange()
      }
    }
  }

  var tokenId: String? {
    didSet {
      if self.tokenId != oldValue {
        self.tokenIdDidChange()
      }
    }
  }

  var url: String = "https://www.crisp.com"

  var onShouldReload: (() -> Void)?

  init() {
    self.websiteId =
      // Allow UI tests to inject a website id…
      ProcessInfo.processInfo.environment["WEBSITE_ID"].flatMap { $0.isEmpty ? nil : $0 }
      ?? UserDefaults.standard.string(forKey: .UserDefaultsKey.websiteId)

    if let websiteId {
      CrispSDK.configure(websiteID: websiteId)
    }
  }

  func onAppear() {}

  func resetChatSession() {
    CrispSDK.session.reset()
    self.onShouldReload?()
  }
}

private extension SettingsViewModel {
  func websiteIdDidChange() {
    UserDefaults.standard.set(
      self.websiteId,
      forKey: .UserDefaultsKey.websiteId,
    )

    if let websiteId {
      CrispSDK.configure(websiteID: websiteId)
      self.onShouldReload?()
    }
  }

  func tokenIdDidChange() {
    UserDefaults.standard.set(
      self.tokenId,
      forKey: .UserDefaultsKey.tokenId,
    )
    CrispSDK.setTokenID(tokenID: self.tokenId)
    CrispSDK.session.reset()
  }
}

extension String {
  enum UserDefaultsKey {
    static let websiteId = "WebsiteID"
    static let tokenId = "TokenID"
    static let lastSessionDataKey = "SessionDataKey"
    static let lastSessionDataValue = "SessionDataValue"
    static let mobileSDKEnabled = "MobileSDKEnabled"
  }
}
