import CrispChatBoxFFI
import CrispDomain

package extension JSEventBus {
  static func inMemory() -> (
    bus: JSEventBus,
    publish: JSEventPublisher,
  ) {
    var handlers = [String: JSEventHandler]()
    var onError: ((String, JSEventError) -> Void)?

    let bus = JSEventBus(
      register: { channel, handler in
        handlers[channel] = handler
      },
      onError: { onError = $0 },
    )

    let publish = { channel, body in
      guard let handler = handlers[channel] else { return }
      do throws(JSEventError) {
        try handler.handle(event: body)
      } catch {
        onError?(channel, error)
      }
    }

    return (bus, JSEventPublisher(publish: publish))
  }
}

package final class JSEventPublisher {
  private let publish: (_ channel: String, _ body: Any) -> Void

  package init(publish: @escaping (_: String, _: Any) -> Void) {
    self.publish = publish
  }

  package func callAsFunction(channel: String, body: Any) {
    self.publish(channel, body)
  }

  package func onInterfaceLifecycle(_ state: CrispClient.InterfaceLifecycleEvent.State) {
    self.publish("onInterfaceLifecycle", #"{"state": "\#(state)"}"#)
  }

  package func onScriptError(
    source: CrispClient.ScriptErrorEvent.Source = .error,
    message: String,
  ) {
    self.publish("onScriptError", #"{"source": "\#(source)", "message": "\#(message)"}"#)
  }

  package func onPickerClick(
    fingerprint: MessageFingerprint,
    pickerId: PickerId = "",
    choice: String,
  ) {
    self.publish(
      "onPickerClick",
      #"""
      {"fingerprint": \#(fingerprint.rawValue), "picker_id": "\#(pickerId
        .rawValue)", "choice_value": "\#(choice)"}
      """#,
    )
  }
}
