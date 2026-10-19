@testable import CrispChatBox
import CrispChatBoxFFI
import Foundation
import Testing
import TestMocks

@Suite("Color mode tests")
@MainActor struct ChatBoxHostModelColorModeTests {
  /// The override must reach the widget before the chatbox is revealed to avoid a flash.
  @Test func appliesColorModeBeforeBecomingLoaded() async {
    let model = ChatBoxHostModel()
    model.colorMode = .dark

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
    model.onClientInitialized(CrispClient(evaluator: evaluator, events: bus))

    publisher.onInterfaceLifecycle(.ready)
    await waitUntil { model.state == .loaded }

    #expect(model.state == .loaded)
    #expect(appliedCalls.count == 1)
    #expect(appliedCalls.first?.contains(#"CrispClient.configColorMode("dark")"#) == true)
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

    #expect(model.state == .loaded)
    #expect(!didApply)
  }

  @Test func becomesLoadedEvenWhenApplyingColorModeFails() async {
    struct ApplyError: Error {}

    let model = ChatBoxHostModel()
    model.colorMode = .light

    let (bus, publisher) = JSEventBus.inMemory()
    let evaluator: JSEvaluator = { js in
      if js.contains("CrispClient.configColorMode(") {
        throw ApplyError()
      }
      return nil
    }
    model.onClientInitialized(CrispClient(evaluator: evaluator, events: bus))

    publisher.onInterfaceLifecycle(.ready)
    await waitUntil { model.state == .loaded }

    #expect(model.state == .loaded)
  }
}
