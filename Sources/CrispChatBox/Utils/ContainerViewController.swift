import UIKit

package class ContainerViewController: UIViewController {
  package var contentViewController: UIViewController? {
    didSet {
      if self.contentViewController === oldValue {
        return
      }

      oldValue?.willMove(toParent: nil)
      oldValue?.view.removeFromSuperview()
      oldValue?.removeFromParent()

      guard self.isViewLoaded, let ctrl = self.contentViewController else {
        return
      }

      UIView.performWithoutAnimation {
        self.installViewController(ctrl)
        if self.view.window != nil {
          self.view.layoutIfNeeded()
        }
      }
    }
  }

  package init() {
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  package required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override package func viewDidLoad() {
    super.viewDidLoad()

    self.contentViewController.map(self.installViewController)
  }

  override package func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    self.contentViewController?.view.frame = self.view.bounds
  }
}

private extension ContainerViewController {
  func installViewController(_ viewController: UIViewController) {
    viewController.view.frame = self.view.bounds
    self.addChild(viewController)
    self.view.addSubview(viewController.view)
    viewController.didMove(toParent: self)
  }
}
