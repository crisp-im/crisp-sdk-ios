@testable import CrispChatBoxFFI
import Foundation
import Testing
import TestMocks

@MainActor
struct JSEventBusTests {
  struct Payload: Decodable, Equatable {
    let value: Int
  }

  @Test func deliversTypedHandlerWhenBodyDecodes() {
    let (bus, deliver) = JSEventBus.inMemory()

    var received: Payload?
    bus.register("interface_action", JSEventHandler { (payload: Payload) in
      received = payload
    })

    deliver(channel: "interface_action", body: #"{"value": 42}"#)

    #expect(received == Payload(value: 42))
  }

  @Test func invokesVoidHandlerRegardlessOfBody() {
    let (bus, deliver) = JSEventBus.inMemory()

    var fired = 0
    bus.register("start_new_conversation", JSEventHandler { fired += 1 })

    deliver(channel: "start_new_conversation", body: "{}")

    #expect(fired == 1)
  }

  @Test func routesDecodingErrorThroughOnErrorSink() {
    let (bus, deliver) = JSEventBus.inMemory()

    var received: Payload?
    bus.register("interface_action", JSEventHandler { (payload: Payload) in
      received = payload
    })

    var errors = [(channel: String, error: JSEventError)]()
    bus.onError { errors.append((channel: $0, error: $1)) }

    deliver(channel: "interface_action", body: #"{"value": "not-an-int"}"#)

    #expect(received == nil)
    #expect(errors.count == 1)
    #expect(errors.first?.channel == "interface_action")
    if case .decodingError = errors.first?.error {
      // pass
    } else {
      Issue.record("Expected .decodingError, got \(String(describing: errors.first?.error))")
    }
  }

  @Test func routesNonStringBodyAsBadSerialization() {
    let (bus, deliver) = JSEventBus.inMemory()

    bus.register("interface_action", JSEventHandler { (_: Payload) in })

    var errors = [JSEventError]()
    bus.onError { _, error in errors.append(error) }

    deliver(channel: "interface_action", body: 12345 as Any)

    #expect(errors == [.badSerialization])
  }

  @Test func deliversOnlyToTheRegisteredChannel() {
    let (bus, deliver) = JSEventBus.inMemory()

    var aFired = 0
    var bFired = 0
    bus.register("a", JSEventHandler { aFired += 1 })
    bus.register("b", JSEventHandler { bFired += 1 })

    deliver(channel: "a", body: "{}")

    #expect(aFired == 1)
    #expect(bFired == 0)
  }
}
