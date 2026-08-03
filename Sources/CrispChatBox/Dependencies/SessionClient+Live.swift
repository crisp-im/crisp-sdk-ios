import CrispDomain
import CrispLogging
import Foundation

package extension SessionClient {
  static func live(userDefaults: UserDefaults) -> Self {
    // https://developer.apple.com/forums/thread/757527?answerId=792408022#792408022
    nonisolated(unsafe) let userDefaults = userDefaults

    let currentSessionKey = "session"
    let previousSessionKey = "previous_session"

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    @Sendable func loadSession(forKey key: String, websiteId: WebsiteId) -> Session? {
      do {
        let session = try userDefaults.data(forKey: key)
          .map { data in try decoder.decode(Session.self, from: data) }

        guard session?.websiteId == websiteId else {
          userDefaults.removeObject(forKey: key)
          userDefaults.synchronize()
          return nil
        }

        return session
      } catch {
        log.error("Failed to load saved session. Reason: \(error.localizedDescription)")
        return nil
      }
    }

    @Sendable func saveSession(_ session: Session) {
      do {
        let data = try encoder.encode(session)
        userDefaults.set(data, forKey: currentSessionKey)
        userDefaults.synchronize()
        log.debug("Successfully saved session \(session.sessionId)")
      } catch {
        log.error("Failed to save session. Reason \(error.localizedDescription)")
      }
    }

    return .init(
      save: { newSession in
        saveSession(newSession)
      },
      load: { websiteId in
        loadSession(forKey: currentSessionKey, websiteId: websiteId)
      },
      loadPrevious: { websiteId in
        loadSession(forKey: previousSessionKey, websiteId: websiteId)
      },
      reset: {
        if let currentSessionData = userDefaults.data(forKey: currentSessionKey) {
          userDefaults.set(currentSessionData, forKey: previousSessionKey)
        }
        userDefaults.removeObject(forKey: currentSessionKey)
        userDefaults.synchronize()
      },
      resetPrevious: {
        userDefaults.removeObject(forKey: previousSessionKey)
        userDefaults.synchronize()
      },
      modifySettings: { websiteId, modify in
        guard var session = loadSession(forKey: currentSessionKey, websiteId: websiteId) else {
          return
        }
        modify(&session.settings)
        saveSession(session)
      },
    )
  }
}
