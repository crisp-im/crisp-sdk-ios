@testable import CrispChatBox
import CrispChatBoxFFI
import Foundation
import Testing
import TestMocks

@Suite("Widget-ready timeout tests")
@MainActor struct ChatBoxHostModelTimeoutTests {
  /// If the JS widget never reports `interfaceLifecycle(.ready)` within the
  /// configured window the model surfaces a `widgetTimeout` error and moves
  /// into the `.error` state.
  @Test func surfacesWidgetTimeoutWhenReadyEventDoesNotArrive() async {
    let model = ChatBoxHostModel(widgetReadyTimeout: NSEC_PER_MSEC * 50) {
      $0.notifications = .noop
    }

    model.onAppear(isPresented: false)
    initializeClient(model: model)

    await waitUntil {
      if case .error = model.state { return true }
      return false
    }

    guard
      case let .error(failureModel) = model.state,
      case .widgetTimeout = failureModel.error
    else {
      Issue.record("Expected .error(.widgetTimeout); got \(model.state)")
      return
    }
  }

  /// As soon as `interfaceLifecycle(.ready)` arrives the timeout is cancelled
  /// and the state stays `.loaded` even past the original deadline.
  @Test func cancelsTimeoutWhenWidgetBecomesReadyInTime() async throws {
    let model = ChatBoxHostModel(widgetReadyTimeout: NSEC_PER_MSEC * 50)
    model.appear()
    let publisher = initializeClient(model: model)
    #expect(model.state.isLoading)

    publisher.onInterfaceLifecycle(.ready)
    #expect(model.state == .loaded)

    try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 200)
    #expect(model.state == .loaded)
  }

  /// Initializing the client doesn't affect the timeout of the boot in progress.
  @Test func reloadThenClientInitializedDoesNotTimeOutEarly() async throws {
    let model = ChatBoxHostModel(widgetReadyTimeout: NSEC_PER_SEC * 2)
    initializeClient(model: model).onInterfaceLifecycle(.ready)

    model.onWebContentProcessTerminated()
    initializeClient(model: model)

    try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 300)
    #expect(model.state.isLoading)
  }

  /// If iOS reaps the WebView's rendering process, the model recovers by returning to
  /// the loading state and re-injecting the chatbox instead of leaving a blank view.
  @Test func reloadsWhenWebContentProcessTerminates() {
    let model = ChatBoxHostModel(widgetReadyTimeout: NSEC_PER_MSEC * 50)
    let publisher = initializeClient(model: model)

    publisher.onInterfaceLifecycle(.ready)
    #expect(model.state == .loaded)

    var didReload = false
    model.onLoadTemplate = { _ in didReload = true }

    model.onWebContentProcessTerminated()

    #expect(model.state.isLoading)
    #expect(didReload)
  }
}
