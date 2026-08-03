import CrispDomain
import CrispUtils
import Foundation

@JSClass(jsModule: "./crisp-client.js")
package struct CrispClient {
  @JSMethod(replacement: "injectMessageEnvelope")
  package func injectMessage(_ message: Message) async throws

  package func focusOnForeground() async throws

  package func registerNotification(deviceToken: String) async throws
  package func unregisterNotification(deviceToken: String) async throws

  package func connectSocket() async throws
  package func disconnectSocket() async throws

  package func helpdeskArticleOpen(
    locale: LanguageCode,
    slug: String,
    title: String?,
    category: String?,
  ) async throws
  package func helpdeskSearch() async throws
  package func chatShow() async throws

  package func botScenarioRun(id: BotScenarioId) async throws
  package func getSessionIdentifier() async throws -> SessionId
  package func isSessionOngoing() async throws -> Bool
  package func messageShow(
    type: ConversationMessageType,
    content: ConversationMessageContent,
    fingerprint: MessageFingerprint?,
    prepend: Bool?,
  ) async throws
  package func getMessages() async throws -> [LocalMessage]

  package func setSessionData(_ data: [Tuple]) async throws
  package func getSessionData(key: String?) async throws -> JSONValue

  package func setSessionSegments(_ segments: [String], overwrite: Bool?) async throws
  package func setSessionEvent(
    name: String,
    data: [String: AnyEncodable]?,
    color: SessionEvent.Color?,
  ) async throws

  package func setUserEmail(_ email: String?, signature: String?) async throws
  package func getUserEmail() async throws -> String?

  package func setUserPhone(_ phone: String?) async throws
  package func getUserPhone() async throws -> String?

  package func setUserNickname(_ nickname: String?) async throws
  package func getUserNickname() async throws -> String?

  package func setUserAvatar(_ url: URL?) async throws
  package func getUserAvatar() async throws -> URL?

  package func setUserCompany(name: String, company: Company?) async throws
  package func getUserCompany() async throws -> Company?

  package func reset() async throws

  @JSEvent
  package func onInterfaceLifecycle(
    _ handler: @MainActor @escaping (InterfaceLifecycleEvent) -> Void,
  )
  @JSEvent
  package func onInterfaceAction(_ handler: @MainActor @escaping (InterfaceActionEvent) -> Void)

  @CrispActionEvent("message:sent")
  package func onMessageSent(_ handler: @MainActor @escaping (Message) -> Void)
  @CrispActionEvent("message:received")
  package func onMessageReceived(_ handler: @MainActor @escaping (Message) -> Void)
}

package extension CrispClient {
  struct InterfaceLifecycleEvent: Decodable {
    package enum State: String, Decodable {
      case mounted
      case ready
      case unmounted
      case error
    }

    package struct Data: Decodable {
      package let origin: String?
    }

    package let state: State
    package let data: Data?
  }

  struct InterfaceActionEvent: Decodable {
    package enum Action: String, Decodable {
      case close
      case upload
      case speech
      case select
      case download
    }

    package struct Data: Decodable {
      package enum State: String, Decodable {
        case record
        case cancel
        case send
      }

      package enum Object: String, Decodable {
        case message
      }

      package struct File: Decodable {
        package let type: String
        package let url: URL
        package let name: String
      }

      package struct Pointer: Decodable {
        package let x: Double
        package let y: Double
      }

      package let origin: String?
      package let state: State?
      package let object: Object?
      package let target: LocalMessage?
      package let file: File?
      package let pointer: Pointer?
    }

    package let action: Action
    package let data: Data?
  }
}

/// Extension to communicate with hand-written JS code
@MainActor package extension CrispClient {
  /// Emitted when the user taps a button on a `picker` message that was injected
  /// from native via `CrispEx.injectMessage(...)`. The IndexHTML installer
  /// attaches a per-choice `handler` callback that posts this event back.
  struct PickerClickEvent: Decodable {
    package let fingerprint: MessageFingerprint
    package let pickerId: PickerId
    package let choiceValue: String

    private enum CodingKeys: String, CodingKey {
      case fingerprint
      case pickerId = "picker_id"
      case choiceValue = "choice_value"
    }
  }

  /// Forwarded from the JS `LogSink` callback installed by `connectLogger`.
  /// Mirrors the `(level, ns, value)` triplet emitted from `LoggerHelper`.
  struct LogEvent: Decodable {
    package enum Level: String, Decodable {
      case error, warn, info, log, debug
      case unknown

      package init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = Self(rawValue: raw) ?? .unknown
      }
    }

    package let level: Level
    package let ns: String
    package let value: String
  }

  /// Emitted when the IndexHTML script encounters an uncaught error or an
  /// unhandled promise rejection. Covers module-load failures (e.g. a
  /// non-existent import) that would otherwise surface only as a DOM-ready
  /// timeout ~10 seconds later.
  struct ScriptErrorEvent: Equatable, Decodable {
    package enum Source: String, Equatable, Decodable {
      case error
      case unhandledRejection = "unhandledrejection"
    }

    package let source: Source
    package let message: String
    package let filename: String?
    package let line: Int?
    package let col: Int?
    package let stack: String?
  }

  func onPickerClick(_ handler: @MainActor @escaping (PickerClickEvent) -> Void) {
    self.events.register("onPickerClick", .init(handler))
  }

  func onLog(_ handler: @MainActor @escaping (LogEvent) -> Void) {
    self.events.register("onLog", .init(handler))
  }

  func onScriptError(_ handler: @MainActor @escaping (ScriptErrorEvent) -> Void) {
    self.events.register("onScriptError", .init(handler))
  }
}
