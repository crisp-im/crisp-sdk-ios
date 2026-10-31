import CrispChatBoxFFI
import CrispDomain
import CrispLogging
import Foundation
import UniformTypeIdentifiers

@MainActor
package final class ChatBoxHostModel {
  enum State {
    case pending
    case loading(LoadingViewModel)
    case loaded
    case error(FailureViewModel)
  }

  enum Route {
    case externalURL(URL)
    case downloading(DownloadViewModel)
    case copyMessage(LocalMessage, origin: CGPoint)
  }

  private var cancellables = Set<AnyCancellable>()

  private let websiteId: WebsiteId
  private let api: ChatBoxAPI
  private let env: Environment
  private let widgetReadyTimeout: UInt64

  /// Set after WebView was installed
  private var client: CrispClient?

  private var didAppear = false
  private var isPresented = false
  private var notificationPermission = NotificationPermission.notDetermined

  var onStateChange: (() -> Void)?
  var onRouteChange: (() -> Void)?
  var onClose: (() -> Void)?
  /// Loads a boot's template into the web view.
  var onLoadTemplate: ((String) -> Void)?

  /// The model's lifecycle. Leaving a boot, whether it completes, fails or is replaced by a
  /// reload, cancels its pending work.
  private var phase = Phase.pending {
    didSet {
      if case let .booting(boot) = oldValue, boot !== self.currentBoot {
        boot.cancel()
      }
      if let handler = self.onStateChange, self.state != oldValue.state {
        handler()
      }
    }
  }

  var state: State {
    self.phase.state
  }

  private(set) var route: Route? {
    didSet {
      if let handler = self.onRouteChange {
        handler()
      }
    }
  }

  package init(
    websiteId: WebsiteId,
    api: ChatBoxAPI,
    env: Environment,
  ) {
    self.websiteId = websiteId
    self.api = api
    self.env = env
    self.widgetReadyTimeout = NSEC_PER_SEC * 15
  }

  #if DEBUG
    init(
      websiteId: WebsiteId,
      api: ChatBoxAPI,
      env: Environment,
      widgetReadyTimeout: UInt64 = NSEC_PER_SEC * 5,
    ) {
      self.websiteId = websiteId
      self.api = api
      self.env = env
      self.widgetReadyTimeout = widgetReadyTimeout
    }
  #endif
}

extension ChatBoxHostModel {
  func onClientInitialized(_ client: CrispClient) {
    self.client = client

    client.onInterfaceLifecycle { [weak self] in self?.onInterfaceLifecycle(event: $0) }
    client.onInterfaceAction { [weak self] in self?.onInterfaceAction(event: $0) }
    client.onMessageSent { [weak self] in self?.onMessageSent(message: $0) }
    client.onMessageReceived { [weak self] in self?.onMessageReceived(message: $0) }

    client.onPickerClick { [weak self] in self?.onPickerClick(event: $0) }
    client.onLog { [weak self] in self?.onLog(event: $0) }
    client.onScriptError { [weak self] in self?.onError(.scriptError($0)) }

    client.onEventError { [weak self] channel, error in
      self?.onError(.eventDecodingFailed(channel: channel, underlying: error))
    }
  }

  func onError(_ error: CrispHostError) {
    log.error(error)

    if case .scriptError = error {
      // Ignore script errors after the ChatBox was initialized, because these can come from
      // anywhere like trying to play an .ogg which Safari doesn't support.
      guard let boot = self.currentBoot else { return }

      // The web view still running during a reload prelude is about to be replaced, so its
      // errors don't affect the boot that follows.
      guard boot.preludeTask == nil else { return }
    }

    let retry: (() -> Void)? = switch error {
    case .widgetTimeout:
      { [weak self] in
        self?.performReload()
      }
    case .client, .eventDecodingFailed, .scriptError, .webViewNotInstalled:
      nil
    }

    self.phase = .failed(
      FailureViewModel(
        error: error,
        onRetry: retry,
        onCancel: { [weak self] in
          self?.onClose?()
        },
      ),
    )
  }

  func onWebContentProcessTerminated() {
    // iOS reaped the WebView's rendering process (memory pressure, backgrounding, or
    // long invisibility). It won't recover on its own, so reload from scratch,
    // showing the loading state meanwhile instead of a blank web view.
    log.warn("WebContent process terminated. Reloading the chatbox.")
    self.performReload()
  }

  func onAppear(isPresented: Bool) {
    self.isPresented = isPresented

    guard !self.didAppear else {
      return
    }

    self.didAppear = true
    self.beginBoot()

    let lifecycle = self.env.lifecycle
    let notifications = self.env.notifications

    Task { [weak self] in
      for await permission in notifications.notificationPermission() {
        self?.notificationPermission = permission
      }
    }.store(in: &self.cancellables)

    Task { [weak self] in
      for await _ in lifecycle.applicationWillEnterForeground() {
        self?.reconnectIfNeeded()
      }
    }.store(in: &self.cancellables)

    Task { [weak self] in
      for await _ in lifecycle.applicationDidEnterBackground() {
        self?.disconnect()
      }
    }.store(in: &self.cancellables)

    Task { [weak self] in
      for await state in lifecycle.connectivity() where state == .online {
        self?.reconnectIfNeeded()
      }
    }.store(in: &self.cancellables)
  }

  func onExternalLinkTapped(url: URL) {
    guard url.scheme?.lowercased().hasPrefix("http") == true else {
      Task {
        await self.env.openURL(url)
      }
      return
    }

    self.route = .externalURL(url)
  }

  func onDownloadFinished(error: (any Error)?) {
    if case .downloading = self.route {
      self.route = nil
    }
  }

  func onMenuDismissed() {
    if case .copyMessage = self.route {
      self.route = nil
    }
  }

  func onCopyMessageButtonPressed() {
    guard case let .copyMessage(message, _) = self.route else {
      return
    }

    self.route = nil

    if let textMessage = message.content.textMessage {
      self.env.pasteboard.copyString(textMessage)
    }
  }
}

extension ChatBoxHostModel {
  func onInterfaceLifecycle(event: CrispClient.InterfaceLifecycleEvent) {
    if event.state == .ready {
      self.widgetIsReady()
    }
  }

  func onInterfaceAction(event: CrispClient.InterfaceActionEvent) {
    switch event.action {
    case .close:
      self.onClose?()

    case .select where event.data?.object == .message:
      if
        let message = event.data?.target,
        message.content.textMessage != nil,
        let origin = event.data?.pointer
      {
        self.route = .copyMessage(message, origin: CGPoint(x: origin.x, y: origin.y))
      }

    case .download:
      guard let file = event.data?.file, let origin = event.data?.pointer else {
        return
      }
      let model = DownloadViewModel(
        url: file.url,
        name: file.name,
        origin: CGPoint(x: origin.x, y: origin.y),
      ) { [weak self] in
        self?.route = nil
      }
      self.route = .downloading(model)

    case .speech, .upload, .select:
      break
    }
  }

  func onMessageSent(message: Message) {
    self.api.callbacks.handleMessageSent(message)

    Task {
      do {
        try await self.promptForNotificationPermissionIfNeeded()
      } catch {
        log.error("Failed to prompt for notification permission. \(error.localizedDescription)")
      }
    }
  }

  func onMessageReceived(message: Message) {
    self.api.callbacks.handleMessageReceived(message)
  }

  func onPickerClick(event: CrispClient.PickerClickEvent) {
    guard event.fingerprint == .requestPushNotificationsPermissionMessageFingerprint else {
      return
    }

    guard let value = NotificationPermissionSelection(rawValue: event.choiceValue) else {
      log.warn("Unknown value '\(event.choiceValue)' in notification prompt selected.")
      return
    }

    self.env.session.modifySettings(self.websiteId) { settings in
      settings.pushNotificationsPermissionRequested = true
    }

    switch value {
    case .enable:
      Task { [notifications = self.env.notifications] in
        await notifications.requestPushNotificationsPermission()
      }.store(in: &self.cancellables)

    case .skip:
      break
    }
  }

  func onLog(event: CrispClient.LogEvent) {
    /// Turns "[DEBUG] [init]" into "[init]" or removes it altogether in release builds
    func clean(_ ns: String) -> String {
      #if DEBUG
        (
          (ns.split(separator: "]")
            .last?
            .trimmingCharacters(in: CharacterSet(charactersIn: "[ ")))
            .map { "[\($0)]" } ?? ns,
        ) + " "
      #else
        ""
      #endif
    }

    switch event.level {
    case .debug:
      log.debug("\(clean(event.ns))\(String(describing: event.value))")
    case .info, .log, .unknown:
      log.info("\(clean(event.ns))\(String(describing: event.value))")
    case .warn:
      log.warn("\(clean(event.ns))\(String(describing: event.value))")
    case .error:
      log.error("\(clean(event.ns))\(String(describing: event.value))")
    }
  }
}

private extension ChatBoxHostModel {
  func widgetIsReady() {
    let boot = self.currentBoot
    self.phase = .loaded

    if let reset = boot?.reset {
      self.api.commands.completeReset(reset)
      self.env.session.reset()
    }

    // A reset requested while booting makes the session this boot joined obsolete already. The
    // template was generated with the values current at that time (e.g. the token ID), so a newer
    // reset, such as a login (setTokenID + reset) while the chat is loading, can only be applied by
    // regenerating the template and reloading the widget.
    guard self.api.commands.pendingReset == nil else {
      self.reloadForPendingReset()
      return
    }

    self.withClient { client in
      let sessionId: SessionId

      do {
        sessionId = try await client.getSessionIdentifier()
      } catch {
        log.error("Failed to load session identifier. \(error.localizedDescription)")
        return
      }

      self.adoptLoadedSession(sessionId)
      self.api.callbacks.handleSessionLoaded(sessionId: sessionId)
      self.flushCommandQueue()
      self.api.commands.setOnAppendHandler { [weak self = self] in
        Task { @MainActor in
          self?.flushCommandQueue()
        }
      }

      do {
        try await self.promptForNotificationPermissionIfNeeded()
      } catch {
        log.error("Failed to prompt for notification permission. \(error.localizedDescription)")
      }
    }
  }

  /// Makes the session the web client loaded the stored native session.
  func adoptLoadedSession(_ sessionId: SessionId) {
    if self.env.session.load(self.websiteId)?.sessionId != sessionId {
      // The push registration belongs to the device rather than to the session, so carry it
      // over to the new session. Front-queued so that a token the app registered meanwhile wins.
      if let deviceToken = self.storedDeviceToken {
        self.api.commands.enqueueFront(.setDeviceToken(deviceToken))
      }
      self.env.session.reset()
      self.env.session.resetPrevious()
      self.env.session.save(Session(websiteId: self.websiteId, sessionId: sessionId))
    }

    // One-time handoff complete: the web client now owns this session, so we stop injecting the
    // session id on subsequent loads.
    self.env.session.modifySettings(self.websiteId) { settings in
      settings.injectedSessionHandedOff = true
    }
  }

  func flushCommandQueue() {
    guard self.state == .loaded else { return }

    guard self.api.commands.pendingReset == nil else {
      self.reloadForPendingReset()
      return
    }

    let commands = self.api.commands.dequeueCoalesced()
    guard !commands.isEmpty else { return }

    self.withClient { [session = env.session, websiteId] client in
      for command in commands {
        do {
          try await client.execute(command)

          if case let .setDeviceToken(deviceToken) = command {
            session.modifySettings(websiteId) { settings in
              settings.deviceToken = deviceToken
            }
          }

        } catch {
          log.error("Failed to execute command \(command): \(error)")
        }
      }
    }
  }

  func withClient(handler: @MainActor @Sendable @escaping (_ client: CrispClient) async -> Void) {
    guard let client, self.state == .loaded else {
      return
    }
    Task { await handler(client) }
  }

  func promptForNotificationPermissionIfNeeded() async throws {
    guard let client else {
      log.error("Expected CrispClient to be set at this point")
      return
    }

    guard
      // The developer-configurable flag should be set
      self.api.shouldPromptForPermission,
      // We only prompt when the user hasn't configured push notifications in any way already.
      // This could also be the case if our 3rd-party developer has prompted already.
      self.notificationPermission == .notDetermined,
      // And finally we have our own internal flag where we save if the user has already reacted
      // to our prompt. If so, we don't show the prompt again.
      self.env.session.load(self.websiteId)?.settings.pushNotificationsPermissionRequested != true
    else {
      return
    }

    let messages = try await client.getMessages()

    // Make sure that we haven't inserted the prompt message already.
    let promptAlreadyInserted = messages.contains { message in
      message.fingerprint == .remote(.requestPushNotificationsPermissionMessageFingerprint)
    }
    guard !promptAlreadyInserted else { return }

    // Also only when the visitor has already sent a message.
    guard messages.contains(where: { $0.from == .user }) else {
      return
    }

    let isStandalone = !messages.contains { $0.fingerprint == .identityPromptMessageFingerprint }

    try await client.injectMessage(
      .requestPushNotificationsPermissionMessage(isStandalone: isStandalone),
    )
  }

  func reconnectIfNeeded() {
    self.withClient { client in
      do {
        try await client.connectSocket()
      } catch {
        log.warn("Failed to reconnect socket. \(error.localizedDescription)")
      }
    }
  }

  func disconnect() {
    self.withClient { client in
      do {
        try await client.disconnectSocket()
      } catch {
        log.warn("Failed to disconnect socket. \(error.localizedDescription)")
      }
    }
  }

  func performReload(after prelude: (@MainActor () async -> Void)? = nil) {
    self.beginBoot(after: prelude)
  }

  /// Reboots the loaded widget so that the pending reset is applied on boot. The device is
  /// deregistered from the session being left first, since it can't be reached afterwards.
  func reloadForPendingReset() {
    guard let client = self.client, let deviceToken = self.storedDeviceToken else {
      self.performReload()
      return
    }

    self.performReload {
      do {
        try await client.unregisterNotification(deviceToken: deviceToken.description)
      } catch {
        log.error("Failed to unset device token before reset. \(error.localizedDescription)")
      }
    }
  }

  var storedDeviceToken: DeviceToken? {
    self.env.session.load(self.websiteId)?.settings.deviceToken
      ?? self.env.session.loadPrevious(self.websiteId)?.settings.deviceToken
  }

  var currentBoot: Boot? {
    if case let .booting(boot) = self.phase {
      return boot
    }
    return nil
  }

  /// Starts a new boot, replacing (and thereby cancelling) the current one, and loads its template
  /// once the prelude (if any) has finished.
  func beginBoot(after prelude: (@MainActor () async -> Void)? = nil) {
    let boot = Boot(
      loadingModel: LoadingViewModel(
        onCancel: self.isPresented
          ? { [weak self] in self?.onClose?() }
          : nil,
      ),
      timeout: self.widgetReadyTimeout,
    ) { [weak self] boot in
      guard let self, self.currentBoot === boot else { return }
      self.onError(.widgetTimeout)
    }
    self.phase = .booting(boot)

    guard let prelude else {
      self.loadTemplate(of: boot)
      return
    }

    boot.preludeTask = Task { [weak self, weak boot] in
      await prelude()
      guard let self, let boot, self.currentBoot === boot else { return }
      boot.preludeTask = nil
      self.loadTemplate(of: boot)
    }
  }

  /// Generates the boot's template and loads it. Generating it only now, after any prelude, picks
  /// up a reset or token change that arrived meanwhile, instead of booting stale and rebooting.
  func loadTemplate(of boot: Boot) {
    let reset = self.api.commands.pendingReset

    let template: String
    do {
      template = try self.makeTemplate(resetsSession: reset != nil)
    } catch {
      // Moves the phase to `.failed`, which cancels the boot.
      self.onError(.client(error))
      return
    }

    boot.reset = reset
    self.onLoadTemplate?(template)
  }

  func makeTemplate(resetsSession: Bool) throws(CrispClientError) -> String {
    guard let assetsURL = URL(string: "\(LocalFileSchemeHandler.scheme)://file") else {
      throw .invalidAssetsURL
    }

    let session = self.env.session.load(self.websiteId)

    // Inject prior session if needed…
    let injectedSessionId = resetsSession
      || session?.settings.injectedSessionHandedOff == true
      ? nil
      : session?.sessionId

    return try loadIndexHTML(
      websiteId: self.websiteId,
      sessionId: injectedSessionId,
      tokenId: self.api.tokenId,
      resetsSession: resetsSession,
      locales: self.env.locales,
      presentation: self.isPresented ? .sheet : .default,
      assetsURL: assetsURL,
    )
  }
}

extension ChatBoxHostModel {
  enum Phase {
    case pending
    case booting(Boot)
    case loaded
    case failed(FailureViewModel)

    var state: State {
      switch self {
      case .pending: .pending
      case let .booting(boot): .loading(boot.loadingModel)
      case .loaded: .loaded
      case let .failed(model): .error(model)
      }
    }
  }

  /// One attempt to boot the widget, from entering the loading state until the widget reports
  /// ready or the boot fails. Its ready timeout starts with it. Templates are only generated for a
  /// boot (see `loadTemplate(of:)`), so the reset a template applies always has a boot to complete
  /// it.
  @MainActor
  final class Boot {
    /// The reset this boot applies by starting with cleared web storage, set when its template is
    /// generated. Resets are never run in a loaded widget: its runtime reset re-initializes without
    /// the token, which would replace e.g. the user's token session right after login with an
    /// empty one.
    fileprivate(set) var reset: ResetRequest?
    let loadingModel: LoadingViewModel
    /// Work that has to finish before the template is reloaded, e.g. deregistering the device
    /// from the session being left.
    var preludeTask: Task<Void, Never>?
    private var timeoutTask: Task<Void, Never>?

    init(
      loadingModel: LoadingViewModel,
      timeout: UInt64,
      onTimeout: @escaping @MainActor (Boot) -> Void,
    ) {
      self.loadingModel = loadingModel
      self.timeoutTask = Task { [weak self] in
        try? await Task.sleep(nanoseconds: timeout)
        guard !Task.isCancelled, let self else { return }
        onTimeout(self)
      }
    }

    func cancel() {
      self.timeoutTask?.cancel()
      self.preludeTask?.cancel()
    }
  }
}

extension ChatBoxHostModel.State: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.pending, .pending), (.loading, .loading), (.loaded, .loaded):
      true
    case let (.error(lErr), .error(rErr)):
      lErr.error == rErr.error
    case (.pending, _), (.loading, _), (.loaded, _), (.error, _):
      false
    }
  }

  var isLoading: Bool {
    if case .loading = self {
      return true
    }
    return false
  }
}
