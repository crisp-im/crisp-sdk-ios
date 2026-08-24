import UIKit

final class MissingConfigurationViewController: UIViewController {
  private let issues: [ConfigurationIssue]

  init(missingConfiguration: MissingConfiguration) {
    self.issues = ConfigurationIssue.issues(for: missingConfiguration)
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = .systemRed

    let titleLabel = UILabel()
    titleLabel.numberOfLines = 0
    titleLabel.font = .crisp_boldFont(forTextStyle: .title2)
    titleLabel.textColor = .white
    titleLabel.text = self.issues.count == 1
      ? "The Crisp SDK is not fully configured. Please fix the following issue:"
      : "The Crisp SDK is not fully configured. Please fix the following issues:"

    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.alwaysBounceVertical = true
    self.view.addSubview(scrollView)

    let issueViews = self.issues.enumerated().map { index, issue in
      self.makeIssueView(for: issue, at: index)
    }

    let vStack = UIStackView(arrangedSubviews: [titleLabel] + issueViews)
    vStack.translatesAutoresizingMaskIntoConstraints = false
    vStack.axis = .vertical
    vStack.alignment = .fill
    vStack.spacing = 36
    scrollView.addSubview(vStack)

    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
      scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),

      vStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 32),
      vStack.bottomAnchor.constraint(
        equalTo: scrollView.contentLayoutGuide.bottomAnchor,
        constant: -32,
      ),
      vStack.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
      vStack.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
    ])
  }

  private func makeIssueView(for issue: ConfigurationIssue, at index: Int) -> UIView {
    let titleLabel = UILabel()
    titleLabel.numberOfLines = 0
    titleLabel.font = .crisp_boldFont(forTextStyle: .body)
    titleLabel.textColor = .white
    titleLabel.text = issue.title

    let messageLabel = UILabel()
    messageLabel.numberOfLines = 0
    messageLabel.font = .preferredFont(forTextStyle: .body)
    messageLabel.textColor = .white
    messageLabel.text = issue.message

    let documentationButton = UIButton.crisp_roundedButton(
      title: "Open Documentation",
      primaryAction: .init { _ in
        if let url = issue.documentationURL {
          UIApplication.shared.open(url)
        }
      },
    )
    documentationButton.setTitleColor(.white, for: .normal)
    documentationButton.layer.borderColor = UIColor.white.cgColor
    documentationButton.isHidden = issue.documentationURL == nil

    // Keeps the button from stretching across the full width of the stack view.
    let buttonRow = UIStackView(arrangedSubviews: [documentationButton, UIView()])
    buttonRow.axis = .horizontal

    let vStack = UIStackView(arrangedSubviews: [titleLabel, messageLabel, buttonRow])
    vStack.axis = .vertical
    vStack.alignment = .fill
    vStack.spacing = 8
    vStack.setCustomSpacing(16, after: messageLabel)

    return vStack
  }
}

private struct ConfigurationIssue {
  let title: String
  let message: String
  let documentationURL: URL?

  static func issues(for missingConfiguration: MissingConfiguration) -> [ConfigurationIssue] {
    var issues = [ConfigurationIssue]()

    if missingConfiguration.contains(.websiteId) {
      issues.append(
        ConfigurationIssue(
          title: "Missing Website ID",
          message: """
          Call `CrispSDK.configure(websiteID:)` with the Website ID from your Crisp dashboard \
          before you present the chat.
          """,
          documentationURL: URL(
            string: "https://crisp-im.github.io/crisp-sdk-ios/documentation/crisp/configureandpresentsdk",
          ),
        ),
      )
    }

    if missingConfiguration.contains(.cameraUsageDescription) {
      issues.append(
        ConfigurationIssue(
          title: "Missing Camera Usage Description",
          message: """
          Add the `NSCameraUsageDescription` key to your app's Info.plist. iOS terminates your app \
          as soon as a user takes a photo or an operator starts a video call without it.
          """,
          documentationURL: URL(
            string: "https://crisp-im.github.io/crisp-sdk-ios/documentation/crisp/configureproject",
          ),
        ),
      )
    }

    if missingConfiguration.contains(.microphoneUsageDescription) {
      issues.append(
        ConfigurationIssue(
          title: "Missing Microphone Usage Description",
          message: """
          Add the `NSMicrophoneUsageDescription` key to your app's Info.plist. iOS terminates your \
          app as soon as a user records a voice message or an operator starts a call without it.
          """,
          documentationURL: URL(
            string: "https://crisp-im.github.io/crisp-sdk-ios/documentation/crisp/configureproject",
          ),
        ),
      )
    }

    return issues
  }
}
