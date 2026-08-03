import UIKit

final class LoadingViewController: UIViewController {
  private let model: LoadingViewModel

  init(model: LoadingViewModel) {
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

    let loadingView = LoadingAnimationView()
    loadingView.translatesAutoresizingMaskIntoConstraints = false
    loadingView.startAnimating()
    self.view.addSubview(loadingView)

    let cancelButton = UIButton.crisp_roundedButton(
      title: NSLocalizedString(
        "sdk.action_cancel",
        bundle: .module,
        value: "Cancel",
        comment: "Cancel button on the loading screen",
      ),
      target: self,
      action: #selector(self.cancelButtonTapped),
    )
    cancelButton.isHidden = !self.model.canCancel
    self.view.addSubview(cancelButton)

    NSLayoutConstraint.activate([
      loadingView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor),
      loadingView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),

      cancelButton.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
      cancelButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
      cancelButton.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
    ])
  }

  @objc func cancelButtonTapped() {
    self.model.cancelButtonTapped()
  }
}
