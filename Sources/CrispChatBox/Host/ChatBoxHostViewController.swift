import CrispChatBoxFFI
import CrispDomain
import CrispLogging
import CrispUtils
import SafariServices
import UIKit
import UniformTypeIdentifiers
import WebKit

final class ChatBoxHostViewController: ContainerViewController {
  private let model: ChatBoxHostModel
  private let config: ChatViewConfiguration
  private var webView: ChatWebView?
  private var didAppear = false

  private var overlayViewController: UIViewController?

  private var cancellables = Set<AnyCancellable>()

  init(model: ChatBoxHostModel, config: ChatViewConfiguration) {
    self.model = model
    self.config = config

    super.init()

    NotificationCenter.default.addObserver(
      forName: UIMenuController.willHideMenuNotification,
      object: nil,
      queue: nil,
    ) { [weak self] _ in
      Task { @MainActor in
        self?.webView?.disabledActions = []
        model.onMenuDismissed()
      }
    }.store(in: &self.cancellables)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    do {
      try self.installWebView()
    } catch {
      self.model.onError(error)
    }

    self.model.onRouteChange = { [weak self] in
      self?.handleRouteChange()
    }

    self.model.onClose = { [weak self] in
      self?.dismiss(animated: true)
    }

    self.model.onRetry = { [weak self, weak model] in
      do throws(CrispHostError) {
        try self?.loadHTML()
      } catch {
        model?.onError(error)
      }
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    // We have to wait until viewWillAppear to load the HTML since we need to know if we're being
    // presented or not to properly configure the JS widget. The same goes for updating the state:
    // The Loading- and FailureViewControllers show a cancel button conditionally if we're being
    // presented, since these buttons otherwise wouldn't do anything because we have no means of
    // dismissing a non(-modally)-presented ViewController.

    self.model.onAppear(isPresented: self.presentingViewController != nil)

    self.model.onStateChange = { [weak self] in
      self?.handleStateChange()
    }

    self.handleStateChange()

    if !self.didAppear {
      self.didAppear = true

      do {
        try self.loadHTML()
      } catch {
        self.model.onError(error)
      }
    }
  }
}

private extension ChatBoxHostViewController {
  func handleStateChange() {
    // Mask the web view with `alpha`, not `isHidden`: a hidden WKWebView is treated as
    // non-visible, so WebKit suspends its rendering and iOS may reap its WebContent
    // process — either of which leaves a blank surface once it's revealed. Keeping it at
    // alpha 0 behind the opaque loading/failure overlays lets it keep rendering.
    switch self.model.state {
    case .pending:
      self.contentViewController = nil
      self.webView?.alpha = 0

    case let .loading(model):
      self.contentViewController = LoadingViewController(model: model)
      self.webView?.alpha = 0

    case .loaded:
      self.contentViewController = nil
      self.webView?.alpha = 1

    case let .error(model):
      self.contentViewController = FailureViewController(model: model)
      self.webView?.alpha = 0
    }
  }

  func handleRouteChange() {
    if let overlayViewController {
      overlayViewController.willMove(toParent: nil)
      overlayViewController.view.removeFromSuperview()
      overlayViewController.removeFromParent()
    }

    self.overlayViewController = nil

    switch self.model.route {
    case let .externalURL(url):
      let ctrl = SFSafariViewController(url: url)
      self.present(ctrl, animated: true)

    case let .downloading(model):
      let ctrl = DownloadProgressViewController(model: model)
      self.overlayViewController = ctrl
      ctrl.view.frame = self.view.bounds
      self.addChild(ctrl)
      self.view.addSubview(ctrl.view)
      ctrl.didMove(toParent: self)

      var excludedActivityTypes: [UIActivity.ActivityType] = [
        .addToReadingList,
      ]
      if #available(iOS 16.4, *) {
        excludedActivityTypes.append(.addToHomeScreen)
      }

      let activityVC = UIActivityViewController(
        activityItems: [model.itemProvider],
        applicationActivities: nil,
      )
      activityVC.excludedActivityTypes = excludedActivityTypes

      activityVC.completionWithItemsHandler = { [weak self, weak model] _, _, _, _ in
        self?.model.onDownloadFinished(error: model?.itemProvider.downloadError)
      }

      if UIDevice.current.userInterfaceIdiom == .pad {
        activityVC.modalPresentationStyle = .popover
        activityVC.popoverPresentationController?.sourceView = self.webView
        activityVC.popoverPresentationController?.sourceRect = CGRect(
          origin: model.origin,
          size: CGSize(width: 1, height: 1),
        )
      }

      self.present(activityVC, animated: true)

    case let .copyMessage(_, origin):
      guard let webView else { return }

      webView.disabledActions = [.cut, .paste, .select, .selectAll]

      let menu = UIMenuController.shared
      menu.menuItems = [
        UIMenuItem(
          title: NSLocalizedString(
            "sdk.action_copy",
            bundle: .module,
            value: "Copy",
            comment: "Copy-message context menu action",
          ),
          action: #selector(self.copyMessage),
        ),
      ]
      let rect = CGRect(
        origin: origin,
        size: CGSize(width: 1, height: 1),
      )
      menu.showMenu(from: webView, rect: rect)

    case .none:
      break
    }
  }

  func installWebView() throws(CrispHostError) {
    let schemeHandler: LocalFileSchemeHandler
    do {
      schemeHandler = try LocalFileSchemeHandler(baseDir: distBundleURL())
    } catch {
      throw .client(error)
    }

    let contentController = WKUserContentController()

    let configuration = WKWebViewConfiguration()
    configuration.userContentController = contentController
    configuration.setURLSchemeHandler(schemeHandler, forURLScheme: LocalFileSchemeHandler.scheme)
    configuration.allowsInlineMediaPlayback = true
    configuration.mediaTypesRequiringUserActionForPlayback = []
    if #available(iOS 14.0, *) {
      configuration.limitsNavigationsToAppBoundDomains = false
    }

    let webView = ChatWebView(frame: .zero, configuration: configuration)
    webView.translatesAutoresizingMaskIntoConstraints = false
    if #available(iOS 16.4, *) {
      webView.isInspectable = true
    }
    webView.navigationDelegate = self
    webView.uiDelegate = self
    webView.allowsLinkPreview = false
    webView.scrollView.contentInsetAdjustmentBehavior = .never
    webView.scrollView.alwaysBounceVertical = false
    if #available(iOS 17.4, *) {
      webView.scrollView.bouncesVertically = false
    }
    self.view.addSubview(webView)
    self.webView = webView

    let client = CrispClient(
      evaluator: webView.crisp_makeJSEvaluator(),
      events: .live(controller: contentController),
    )
    self.model.onClientInitialized(client)

    NSLayoutConstraint.activate([
      webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      webView.heightAnchor.constraint(equalTo: self.view.heightAnchor),
      webView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
    ])
  }

  func loadHTML() throws(CrispHostError) {
    guard let webView else {
      throw .webViewNotInstalled
    }

    let htmlString: String
    do {
      htmlString = try self.model.loadBaseHTML()
    } catch {
      throw .client(error)
    }

    guard let baseURL = URL(string: "\(LocalFileSchemeHandler.scheme)://file/") else {
      fatalError("Could not construct baseURL")
    }

    // We introduce our own URL scheme to prevent CORS errors
    webView.loadHTMLString(htmlString, baseURL: baseURL)
  }

  @objc func copyMessage() {
    self.model.onCopyMessageButtonPressed()
  }
}

extension ChatBoxHostViewController: WKNavigationDelegate {
  func webView(_: WKWebView, didFinish _: WKNavigation) {}

  func webViewWebContentProcessDidTerminate(_: WKWebView) {
    self.model.onWebContentProcessTerminated()
  }

  func webView(
    _: WKWebView,
    decidePolicyFor navigationResponse: WKNavigationResponse,
  ) async
    -> WKNavigationResponsePolicy
  {
    if navigationResponse.canShowMIMEType {
      .allow
    } else {
      if #available(iOS 14.5, *) {
        .download
      } else {
        .allow
      }
    }
  }

  @available(iOS 14.5, *)
  func webView(
    _: WKWebView,
    navigationResponse _: WKNavigationResponse,
    didBecome download: WKDownload,
  ) {
    download.delegate = self
  }

  @available(iOS 14.5, *)
  func webView(
    _: WKWebView,
    navigationAction _: WKNavigationAction,
    didBecome download: WKDownload,
  ) {
    download.delegate = self
  }
}

@available(iOS 14.5, *)
extension ChatBoxHostViewController: WKDownloadDelegate {
  func download(
    _: WKDownload,
    decideDestinationUsing _: URLResponse,
    suggestedFilename: String,
  ) async -> URL? {
    let urls = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)

    guard let name = suggestedFilename
      .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
    else {
      fatalError("URL-encoding suggestedFilename should not fail for .urlPathAllowed")
    }

    guard let destination = URL(string: name, relativeTo: urls[0]) else {
      fatalError(
        "URL construction should not fail from a URL-encoded filename relative to a valid documents URL",
      )
    }

    log.info("Saving download to \(destination.absoluteString)…")
    return destination
  }

  func downloadDidFinish(_: WKDownload) {
    log.info("Download finished")
  }

  func download(_: WKDownload, didFailWithError error: any Error, resumeData _: Data?) {
    log.error("Download failed. Reason: \(error.localizedDescription)")
  }

  func download(
    _: WKDownload,
    willPerformHTTPRedirection _: HTTPURLResponse,
    newRequest _: URLRequest,
    decisionHandler: @escaping @MainActor (WKDownload.RedirectPolicy) -> Void,
  ) {
    decisionHandler(.allow)
  }
}

extension ChatBoxHostViewController: WKUIDelegate {
  func webView(
    _: WKWebView,
    createWebViewWith _: WKWebViewConfiguration,
    for navigationAction: WKNavigationAction,
    windowFeatures _: WKWindowFeatures,
  ) -> WKWebView? {
    guard let url = navigationAction.request.url else {
      return nil
    }
    self.model.onExternalLinkTapped(url: url)
    return nil
  }

  @available(iOS 15.0, *)
  func webView(
    _: WKWebView,
    decideMediaCapturePermissionsFor origin: WKSecurityOrigin,
    initiatedBy _: WKFrameInfo,
    type _: WKMediaCaptureType,
  ) async -> WKPermissionDecision {
    // The chatbox is only ever served from our own bundle over the custom scheme,
    // so grant camera/microphone capture (used for calls) to that origin only.
    origin.protocol == LocalFileSchemeHandler.scheme ? .grant : .deny
  }
}
