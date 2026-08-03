import CrispDomain
import Foundation

package struct SessionClient {
  package var save: @Sendable (Session) -> Void
  package var load: @Sendable (WebsiteId) -> Session?
  package var loadPrevious: @Sendable (WebsiteId) -> Session?
  package var reset: @Sendable () -> Void
  package var resetPrevious: @Sendable () -> Void
  package var modifySettings: @Sendable (
    WebsiteId,
    @Sendable (inout Session.Settings) -> Void
  ) -> Void

  package init(
    save: @Sendable @escaping (Session) -> Void,
    load: @Sendable @escaping (WebsiteId) -> Session?,
    loadPrevious: @Sendable @escaping (WebsiteId) -> Session?,
    reset: @Sendable @escaping () -> Void,
    resetPrevious: @Sendable @escaping () -> Void,
    modifySettings: @Sendable @escaping (
      WebsiteId,
      @Sendable (inout Session.Settings) -> Void
    ) -> Void,
  ) {
    self.save = save
    self.load = load
    self.loadPrevious = loadPrevious
    self.reset = reset
    self.resetPrevious = resetPrevious
    self.modifySettings = modifySettings
  }
}

#if DEBUG
  package extension SessionClient {
    static let noop = SessionClient(
      save: { _ in },
      load: { _ in nil },
      loadPrevious: { _ in nil },
      reset: {},
      resetPrevious: {},
      modifySettings: { _, _ in },
    )
  }
#endif

package struct Session: Codable, Equatable {
  package struct Settings: Codable, Equatable {
    package var deviceToken: DeviceToken?
    package var pushNotificationsPermissionRequested: Bool
    package var injectedSessionHandedOff: Bool

    package init(
      deviceToken: DeviceToken? = nil,
      pushNotificationsPermissionRequested: Bool = false,
      injectedSessionHandedOff: Bool = false,
    ) {
      self.deviceToken = deviceToken
      self.pushNotificationsPermissionRequested = pushNotificationsPermissionRequested
      self.injectedSessionHandedOff = injectedSessionHandedOff
    }

    /// Custom decoder for backwards compatibility: settings persisted by an older SDK version
    /// decode missing keys to their defaults instead of throwing.
    package init(from decoder: any Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.deviceToken = try container.decodeIfPresent(DeviceToken.self, forKey: .deviceToken)
      self.pushNotificationsPermissionRequested = try container.decodeIfPresent(
        Bool.self,
        forKey: .pushNotificationsPermissionRequested,
      ) ?? false
      self.injectedSessionHandedOff = try container.decodeIfPresent(
        Bool.self,
        forKey: .injectedSessionHandedOff,
      ) ?? false
    }
  }

  package var websiteId: WebsiteId
  package var sessionId: SessionId
  package var settings: Settings

  package init(
    websiteId: WebsiteId,
    sessionId: SessionId,
    settings: Settings = Settings(),
  ) {
    self.websiteId = websiteId
    self.sessionId = sessionId
    self.settings = settings
  }

  /// Custom decoder init for backwards compatibility
  package init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.websiteId = try container.decode(WebsiteId.self, forKey: .websiteId)
    self.sessionId = try container.decode(SessionId.self, forKey: .sessionId)
    self.settings = try container.decodeIfPresent(Settings.self, forKey: .settings) ?? Settings()
  }
}
