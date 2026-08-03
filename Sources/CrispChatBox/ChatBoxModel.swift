import CrispDomain
import CrispUtils
import Foundation

@MainActor
package final class ChatBoxModel {
  enum Route {
    case missingWebsiteId
    case fullyConfigured(ChatBoxHostModel)
  }

  private var isVisible = false
  private let api: ChatBoxAPI

  let route: Route

  package init(api: ChatBoxAPI, env: Environment = .live) {
    self.api = api

    guard let websiteId = api.websiteId else {
      self.route = .missingWebsiteId
      return
    }

    self.route = .fullyConfigured(ChatBoxHostModel(websiteId: websiteId, api: api, env: env))
  }

  func onDidAppear() {
    guard !self.isVisible else { return }

    self.isVisible = true
    self.api.callbacks.handleChatOpened()
  }

  func onDisappear() {
    guard self.isVisible else { return }

    self.isVisible = false
    self.api.callbacks.handleChatClosed()
  }
}
