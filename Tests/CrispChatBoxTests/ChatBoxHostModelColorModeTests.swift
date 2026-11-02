@testable import CrispChatBox
import CrispChatBoxFFI
import CrispDomain
import Foundation
import Testing
import TestMocks

@Suite("Color mode tests")
@MainActor struct ChatBoxHostModelColorModeTests {
  /// The override must reach the widget before the chatbox is revealed to avoid a flash.
  @Test(arguments: [ColorMode.light, .dark, .auto])
  func appliesColorModeBeforeBecomingLoaded(colorMode: ColorMode) async {
    let model = ChatBoxHostModel()

    var stateWhenApplied: ChatBoxHostModel.State?
    var appliedCalls = [String]()

    let (bus, publisher) = JSEventBus.inMemory()
    let evaluator: JSEvaluator = { js in
      if js.contains("CrispClient.configColorMode(") {
        stateWhenApplied = model.state
        appliedCalls.append(js)
      }
      return nil
    }
    model.onClientInitialized(
      CrispClient(evaluator: evaluator, events: bus),
      colorMode: colorMode,
    )

    publisher.onInterfaceLifecycle(.ready)
    await waitUntil { model.state == .loaded }

    #expect(model.state == .loaded)
    #expect(appliedCalls.count == 1)
    #expect(
      appliedCalls.first?.contains(#"CrispClient.configColorMode("\#(colorMode.rawValue)")"#)
        == true,
    )
    #expect(stateWhenApplied != .loaded)
  }

  @Test func leavesWebsiteColorModeUntouchedWithoutOverride() async {
    let model = ChatBoxHostModel()

    var didApply = false
    let (bus, publisher) = JSEventBus.inMemory()
    let evaluator: JSEvaluator = { js in
      if js.contains("CrispClient.configColorMode(") {
        didApply = true
      }
      return nil
    }
    model.onClientInitialized(CrispClient(evaluator: evaluator, events: bus))

    publisher.onInterfaceLifecycle(.ready)
    await settle()

    #expect(model.state == .loaded)
    #expect(!didApply)
  }

  @Test func becomesLoadedEvenWhenApplyingColorModeFails() async {
    struct ApplyError: Error {}

    let model = ChatBoxHostModel()

    let (bus, publisher) = JSEventBus.inMemory()
    let evaluator: JSEvaluator = { js in
      if js.contains("CrispClient.configColorMode(") {
        throw ApplyError()
      }
      return nil
    }
    model.onClientInitialized(
      CrispClient(evaluator: evaluator, events: bus),
      colorMode: .dark,
    )

    publisher.onInterfaceLifecycle(.ready)
    await waitUntil { model.state == .loaded }

    #expect(model.state == .loaded)
  }

  @Test func keepsErrorRaisedWhileApplyingColorMode() async {
    let model = ChatBoxHostModel()
    let gate = Gate()
    var isApplyingColorMode = false

    let publisher = self.initializeClient(model: model, gate: gate) {
      isApplyingColorMode = true
    }
    model.appear()

    publisher.onInterfaceLifecycle(.ready)
    await waitUntil { isApplyingColorMode }

    model.onError(.widgetTimeout)
    gate.open()
    await settle()

    guard case .error = model.state else {
      Issue.record("Expected .error; got \(model.state)")
      return
    }
  }

  @Test func doesNotRevealRebootWhenColorModeOfPreviousBootFinishes() async {
    let model = ChatBoxHostModel()
    let gate = Gate()
    var isApplyingColorMode = false

    let publisher = self.initializeClient(model: model, gate: gate) {
      isApplyingColorMode = true
    }
    model.appear()

    publisher.onInterfaceLifecycle(.ready)
    await waitUntil { isApplyingColorMode }

    model.onError(.widgetTimeout)
    guard case let .error(failure) = model.state else {
      Issue.record("Expected .error; got \(model.state)")
      return
    }
    failure.retryButtonTapped()
    gate.open()
    await settle()

    #expect(model.state.isLoading)
  }

  /// crisp-client reports ready again when initialized twice, which must not start two loads.
  @Test func revealsOnceForRepeatedReadyEvents() async {
    let model = ChatBoxHostModel()
    let gate = Gate()
    var colorModeCalls = 0
    var sessionIdentifierCalls = 0

    let (bus, publisher) = JSEventBus.inMemory()
    let evaluator: JSEvaluator = { js in
      if js.contains("CrispClient.configColorMode(") {
        colorModeCalls += 1
        await gate.wait()
      } else if js.contains("CrispClient.getSessionIdentifier()") {
        sessionIdentifierCalls += 1
        return SessionId.mock.rawValue
      }
      return nil
    }
    model.onClientInitialized(
      CrispClient(evaluator: evaluator, events: bus),
      colorMode: .dark,
    )
    model.appear()

    publisher.onInterfaceLifecycle(.ready)
    publisher.onInterfaceLifecycle(.ready)
    await waitUntil { colorModeCalls == 2 }

    gate.open()
    await waitUntil { sessionIdentifierCalls > 0 }
    await settle()

    #expect(model.state == .loaded)
    #expect(sessionIdentifierCalls == 1)
  }
}

private extension ChatBoxHostModelColorModeTests {
  @discardableResult
  func initializeClient(
    model: ChatBoxHostModel,
    gate: Gate,
    onApplyColorMode: @escaping () -> Void = {},
  ) -> JSEventPublisher {
    let (bus, publisher) = JSEventBus.inMemory()
    let evaluator: JSEvaluator = { js in
      if js.contains("CrispClient.configColorMode(") {
        onApplyColorMode()
        await gate.wait()
      }
      return nil
    }
    model.onClientInitialized(
      CrispClient(evaluator: evaluator, events: bus),
      colorMode: .dark,
    )
    return publisher
  }

  func settle() async {
    for _ in 0 ..< 10 {
      await Task.yield()
    }
  }
}
