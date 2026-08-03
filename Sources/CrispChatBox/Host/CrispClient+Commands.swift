import CrispChatBoxFFI
import CrispUtils

package extension CrispClient {
  @MainActor
  func execute(_ command: Command) async throws {
    switch command {
    case let .injectMessage(message):
      try await self.injectMessage(message)

    case .reset:
      try await self.reset()

    case let .setSessionData(data):
      try await self.setSessionData(data.map { key, value in
        Tuple(key: key, value: value)
      })

    case let .setSegments(segments, overwrite):
      try await self.setSessionSegments(segments, overwrite: overwrite)

    case let .pushEvents(events):
      for event in events {
        try await self.setSessionEvent(
          name: event.name,
          data: event.data.mapValues(AnyEncodable.init),
          color: event.color,
        )
      }

    case let .runBotScenario(id):
      try await self.botScenarioRun(id: id)

    case let .setNickname(nickname):
      try await self.setUserNickname(nickname)

    case let .setEmail(address, signature):
      try await self.setUserEmail(address, signature: signature)

    case let .setPhone(phone):
      try await self.setUserPhone(phone)

    case let .setAvatar(url):
      try await self.setUserAvatar(url)

    case let .setCompany(company):
      try await self.setUserCompany(name: company.name ?? "", company: company)

    case let .setDeviceToken(token):
      try await self.registerNotification(deviceToken: token.description)

    case let .unsetDeviceToken(token):
      try await self.unregisterNotification(deviceToken: token.description)

    case let .showMessage(fingerprint, content):
      try await self.messageShow(
        type: content.type,
        content: content,
        fingerprint: fingerprint,
        prepend: nil,
      )

    case let .open(intent):
      switch intent {
      case .chat:
        try await self.chatShow()

      case .helpdesk:
        try await self.helpdeskSearch()

      case let .helpdeskArticle(article):
        try await self.helpdeskArticleOpen(
          locale: article.locale,
          slug: article.slug,
          title: article.title,
          category: article.category,
        )
      }
    }
  }
}
