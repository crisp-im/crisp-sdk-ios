import UIKit

final class MissingWebsiteIdViewController: UIViewController {
  init() {
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = .red

    let text = """
    Missing Website ID!
    Please read our setup guide.
    """

    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.numberOfLines = 0
    label.font = UIFont.preferredFont(forTextStyle: .title2)
    label.textColor = .white
    label.text = text
    self.view.addSubview(label)

    let openGuideButton = UIButton.crisp_roundedButton(
      title: "Open Setup Guide",
      target: self,
      action: #selector(self.openSetupGuideButtonTapped),
    )
    openGuideButton.setTitleColor(.white, for: .normal)
    openGuideButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
    openGuideButton.layer.borderColor = UIColor.white.cgColor
    openGuideButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)

    let vStack = UIStackView(arrangedSubviews: [label, openGuideButton])
    vStack.translatesAutoresizingMaskIntoConstraints = false
    vStack.axis = .vertical
    vStack.alignment = .center
    vStack.spacing = 48
    self.view.addSubview(vStack)

    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
      label.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
      label.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor),
    ])
  }

  @objc func openSetupGuideButtonTapped() {
    URL(string: "https://docs.crisp.chat/guides/chatbox-sdks/ios-sdk/")
      .map { UIApplication.shared.open($0) }
  }
}
