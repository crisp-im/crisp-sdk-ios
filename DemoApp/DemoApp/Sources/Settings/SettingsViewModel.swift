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

  var colorMode: ColorMode? {
    didSet {
      if self.colorMode != oldValue {
        self.colorModeDidChange()
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

    self.colorMode = UserDefaults.standard.string(forKey: .UserDefaultsKey.colorMode)
      .flatMap(ColorMode.init(storageValue:))
    ChatViewConfiguration.default.colorMode = self.colorMode
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

  func colorModeDidChange() {
    UserDefaults.standard.set(
      self.colorMode?.storageValue,
      forKey: .UserDefaultsKey.colorMode,
    )
    ChatViewConfiguration.default.colorMode = self.colorMode
    self.onShouldReload?()
  }
}

private extension ColorMode {
  init?(storageValue: String) {
    switch storageValue {
    case "light": self = .light
    case "dark": self = .dark
    case "auto": self = .auto
    default: return nil
    }
  }

  var storageValue: String {
    switch self {
    case .light: "light"
    case .dark: "dark"
    case .auto: "auto"
    }
  }
}

extension String {
  enum UserDefaultsKey {
    static let websiteId = "WebsiteID"
    static let tokenId = "TokenID"
    static let lastSessionDataKey = "SessionDataKey"
    static let lastSessionDataValue = "SessionDataValue"
    static let mobileSDKEnabled = "MobileSDKEnabled"
    static let colorMode = "ColorMode"
  }
}
