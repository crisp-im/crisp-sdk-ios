import UIKit

final class FailureViewController: UIViewController {
  private let model: FailureViewModel

  init(model: FailureViewModel) {
    self.model = model
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = .systemBackground

    let font = UIFont.preferredFont(forTextStyle: .body)
    let boldFont = font.fontDescriptor
      .withSymbolicTraits(.traitBold)
      .map { UIFont(descriptor: $0, size: 0) } ?? font

    let titleLabel = UILabel()
    titleLabel.text = NSLocalizedString(
      "sdk.alert_cannot_start",
      bundle: .module,
      value: "Error starting chat",
      comment: "Title shown when the chat fails to start",
    )
    titleLabel.numberOfLines = 0
    titleLabel.font = boldFont
    titleLabel.textColor = .label

    let messageLabel = UILabel()
    messageLabel.text = NSLocalizedString(
      "sdk.alert_cannot_connect",
      bundle: .module,
      value: "We could not connect to the chat. Try again now, or later.",
      comment: "Message shown when the chat fails to start",
    )
    messageLabel.numberOfLines = 0
    messageLabel.font = font
    messageLabel.textColor = .secondaryLabel

    let retryButton = UIButton.crisp_roundedButton(
      title: NSLocalizedString(
        "sdk.action_try_again",
        bundle: .module,
        value: "Try again",
        comment: "Retry button on the chat failure screen",
      ),
      target: self,
      action: #selector(self.retryButtonTapped),
    )
    retryButton.isHidden = !self.model.canRetry

    let cancelButton = UIButton.crisp_roundedButton(
      title: NSLocalizedString(
        "sdk.action_cancel",
        bundle: .module,
        value: "Cancel",
        comment: "Cancel button on the chat failure screen",
      ),
      target: self,
      action: #selector(self.cancelButtonTapped),
    )
    cancelButton.isHidden = !self.model.canCancel

    let hStack = UIStackView(arrangedSubviews: [cancelButton, retryButton])
    hStack.axis = .horizontal
    hStack.distribution = .fillEqually
    hStack.spacing = 12

    let vStack = UIStackView(arrangedSubviews: [titleLabel, messageLabel, hStack])
    vStack.translatesAutoresizingMaskIntoConstraints = false
    vStack.axis = .vertical
    vStack.alignment = .fill
    vStack.setCustomSpacing(12, after: titleLabel)
    vStack.setCustomSpacing(36, after: messageLabel)
    self.view.addSubview(vStack)

    NSLayoutConstraint.activate([
      vStack.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor),
      vStack.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
      vStack.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
    ])
  }

  @objc func retryButtonTapped() {
    self.model.retryButtonTapped()
  }

  @objc func cancelButtonTapped() {
    self.model.cancelButtonTapped()
  }
}
