import CrispDomain
import CrispUtils
import Foundation

@MainActor
package final class ChatBoxModel {
  enum Route {
    case missingConfiguration(MissingConfiguration)
    case fullyConfigured(ChatBoxHostModel)
  }

  private var isVisible = false
  private let api: ChatBoxAPI

  let route: Route

  package init(api: ChatBoxAPI, env: Environment = .live, bundle: Bundle = .main) {
    self.api = api

    var missingConfiguration = MissingConfiguration(websiteId: api.websiteId, bundle: bundle)

    if api.missingUsageDescriptionWarningsDisabled {
      missingConfiguration.subtract(
        [.cameraUsageDescription, .microphoneUsageDescription],
      )
    }

    guard let websiteId = api.websiteId, missingConfiguration.isEmpty else {
      self.route = .missingConfiguration(missingConfiguration)
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
