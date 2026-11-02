import UIKit

final class LoadingViewController: UIViewController {
  private static let loaderDelay = NSEC_PER_MSEC * 300
  private static let cancelDelay = NSEC_PER_SEC * 3
  static let fadeDuration = TimeInterval(0.25)

  let model: LoadingViewModel
  private var cancellables = Set<AnyCancellable>()

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
      primaryAction: .init { [model] _ in
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

    // Delay via tasks rather than `UIView.animate(delay:)`: in `viewDidLoad` the view has not been
    // rendered yet, so UIKit would apply the final alpha immediately instead of animating
    Task { [weak self, weak loadingView] in
      try? await Task.sleep(nanoseconds: Self.loaderDelay)
      self?.fadeIn(loadingView)
    }.store(in: &self.cancellables)

    Task { [weak self, weak cancelButton] in
      try? await Task.sleep(nanoseconds: Self.cancelDelay)
      self?.fadeIn(cancelButton)
    }.store(in: &self.cancellables)
  }

  private func fadeIn(_ target: UIView?) {
    guard let target, !Task.isCancelled else {
      return
    }

    UIView.animate(
      withDuration: Self.fadeDuration,
      delay: 0,
      options: [.curveEaseOut, .allowUserInteraction],
    ) {
      target.alpha = 1
    }
  }
}
