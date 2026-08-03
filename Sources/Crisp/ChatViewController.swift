internal import CrispChatBox
import UIKit

/// The ViewController that hosts the Crisp chat (UIKit).
///
/// - Important: Make sure that you have configured your Website ID before you present the
/// `ChatViewController`. See: ``CrispSDK/configure(websiteID:)``.
///
/// You can present the `ChatViewController` like you would present any other `UIViewController`.
///
/// ```swift
/// import Crisp
///
/// class YourViewController: UIViewController {
///
///     // ...
///
///     @IBAction func startChat(_ sender: Any) {
///         self.present(ChatViewController(), animated: true)
///     }
/// }
/// ```
///
/// - Tip: If you're using SwiftUI you can present the ``ChatView`` instead.
@objc(CRSPChatViewController) public final class ChatViewController: UIViewController {
  private let rootViewController: ChatBoxViewController

  /// Initializes the `ChatViewController`.
  public init(configuration: ChatViewConfiguration = .default) {
    if
      UIImagePickerController.isSourceTypeAvailable(.camera),
      !Bundle.main.crisp_hasCameraUsageDescription
    {
      // swiftlint:disable:next no_direct_standard_out_logs
      print(
        """

        ***
        To enable receiving video calls in the Crisp chat, please configure \
        the `NSCameraUsageDescription` entry in your app's Info.plist.
        For more information see: https://developer.apple.com/library/archive/qa/qa1937/_index.html.
        ***

        """,
      )
    }

    if !Bundle.main.crisp_hasMicrophoneUsageDescription {
      // swiftlint:disable:next no_direct_standard_out_logs
      print(
        """

        ***
        To enable receiving audio or video calls in the Crisp chat, please configure \
        the `NSMicrophoneUsageDescription` entry in your app's Info.plist.
        For more information see: https://developer.apple.com/library/archive/qa/qa1937/_index.html.
        ***

        """,
      )
    }

    self.rootViewController = ChatBoxViewController(
      model: ChatBoxModel(api: CrispSDK.apiModel),
      configuration: configuration.chatBoxConfiguration,
    )
    super.init(nibName: nil, bundle: nil)
    self.title = "Crisp Chat"
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Called after the controller's view is loaded into memory.
  override public func viewDidLoad() {
    super.viewDidLoad()

    self.rootViewController.view.frame = self.view.bounds
    self.addChild(self.rootViewController)
    self.view.addSubview(self.rootViewController.view)
    self.rootViewController.didMove(toParent: self)
  }

  /// Called to notify the view controller that its view is about to layout its subviews.
  override public func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    self.rootViewController.view.frame = self.view.bounds
  }

  /// Performs some action before the view appears.
  /// - Parameter animated: A Boolean value that indicates whether the view will appear using an
  /// animation.
  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.isNavigationBarHidden = true
  }
}
