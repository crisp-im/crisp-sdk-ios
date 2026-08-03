extension [Command] {
  /// Coalesces commands by merging or deduplicating where possible.
  ///
  /// Iterates in reverse to give precedence to later commands. For commands
  /// that can be merged (e.g. `setSessionData`, `setSegments`, `pushEvents`),
  /// earlier and later values are combined. For simple setters, only the latest
  /// value is kept. Commands like `showMessage` are never coalesced.
  func coalesced() -> [Command] {
    var result: [Command] = []
    var kindIndices = [Command.Kind: Int]()

    for earlier in self.reversed() {
      guard let laterIdx = kindIndices[earlier.kind] else {
        result.append(earlier)
        kindIndices[earlier.kind] = result.count - 1
        continue
      }

      let later = result[laterIdx]
      let merged: Command? = switch (earlier, later) {
      case let (.setSessionData(earlierData), .setSessionData(laterData)):
        .setSessionData(earlierData.merging(laterData, uniquingKeysWith: { _, new in new }))
      case let (
        .setSegments(earlierSegments, earlierOverwrite),
        .setSegments(laterSegments, laterOverwrite)
      ):
        if laterOverwrite {
          .setSegments(segments: laterSegments, overwrite: true)
        } else {
          .setSegments(
            segments: earlierSegments + laterSegments,
            overwrite: earlierOverwrite,
          )
        }
      case let (.pushEvents(earlierEvents), .pushEvents(laterEvents)):
        .pushEvents(earlierEvents + laterEvents)
      // Simple setters: keep latest
      case let (.setNickname, .setNickname(v)):
        .setNickname(v)
      case let (.setEmail, .setEmail(a, s)):
        .setEmail(address: a, signature: s)
      case let (.setPhone, .setPhone(v)):
        .setPhone(v)
      case let (.setAvatar, .setAvatar(v)):
        .setAvatar(v)
      case let (.setCompany, .setCompany(v)):
        .setCompany(v)
      case let (.setDeviceToken, .setDeviceToken(v)):
        .setDeviceToken(v)
      case let (.unsetDeviceToken, .unsetDeviceToken(v)):
        .unsetDeviceToken(v)
      case (.runBotScenario, .runBotScenario):
        later
      case (.open, .open):
        later
      case (.reset, .reset):
        later
      // showMessage is never coalesced
      case (.showMessage, .showMessage):
        nil
      default:
        nil
      }

      if let merged {
        result[laterIdx] = merged
      } else {
        result.append(earlier)
        kindIndices.removeValue(forKey: earlier.kind)
      }
    }

    return result.reversed()
  }
}
