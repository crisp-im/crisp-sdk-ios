import UIKit

package final class ChatBoxViewController: ContainerViewController {
  private var model: ChatBoxModel
  private let configuration: ChatViewConfiguration
  private var hostController: ChatBoxHostViewController?

  package init(model: ChatBoxModel, configuration: ChatViewConfiguration) {
    self.model = model
    self.configuration = configuration

    super.init()

    self.title = "Crisp Chat"
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override package func viewDidLoad() {
    super.viewDidLoad()

    self.view.preservesSuperviewLayoutMargins = true

    switch self.model.route {
    case .missingWebsiteId:
      self.contentViewController = MissingWebsiteIdViewController()
    case let .fullyConfigured(model):
      self.contentViewController = ChatBoxHostViewController(
        model: model,
        config: self.configuration,
      )
    }
  }

  override package func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.model.onDidAppear()
  }

  override package func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    if self.crisp_isBeingRemoved {
      self.model.onDisappear()
    }
  }
}
