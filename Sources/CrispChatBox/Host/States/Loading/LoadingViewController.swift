import UIKit

final class LoadingViewController: UIViewController {
  private static let loaderDelayNanoseconds = UInt64(300_000_000)
  private static let cancelDelayNanoseconds = UInt64(3_000_000_000)
  private static let fadeInDuration = TimeInterval(0.25)

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
      primaryAction: .init { [model] action in
        (action.sender as? UIControl)?.isEnabled = false
        model.cancelButtonTapped()
      },
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

    loadingView.alpha = 0
    cancelButton.alpha = 0
    cancelButton.isUserInteractionEnabled = false

    Task { [weak self, weak loadingView] in
      try? await Task.sleep(nanoseconds: Self.loaderDelayNanoseconds)
      self?.fadeIn(loadingView)
    }

    Task { [weak self, weak cancelButton] in
      try? await Task.sleep(nanoseconds: Self.cancelDelayNanoseconds)
      cancelButton?.isUserInteractionEnabled = true
      self?.fadeIn(cancelButton)
    }
  }

  private func fadeIn(_ target: UIView?) {
    // Skip if the whole overlay is already fading out because loading finished
    guard let target, self.view.alpha == 1 else {
      return
    }

    UIView.animate(
      withDuration: Self.fadeInDuration,
      delay: 0,
      options: [.curveEaseOut, .allowUserInteraction],
    ) {
      target.alpha = 1
    }
  }
}
