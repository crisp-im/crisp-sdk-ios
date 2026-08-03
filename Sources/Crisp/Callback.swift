internal import CrispChatBox
import Foundation

/// Represents a callback that can be used to observe certain events in the CrispChatBox.
/// See ``CrispSDK/addCallback(_:)
public enum Callback {
  /// Chatbox was closed
  ///
  /// Handles the chatbox closed event (triggers your callback function).
  case chatClosed(VoidHandler)

  /// Chatbox was opened
  ///
  /// Handles the chatbox opened event (triggers your callback function).
  case chatOpened(VoidHandler)

  /// Message was received
  ///
  /// Handles the message received event from the operator (triggers your callback function, with
  /// message as first argument).
  case messageReceived(MessageHandler)

  /// Message was sent
  ///
  /// Handles the message sent event from the visitor (triggers your callback function, with
  /// message as first argument).
  case messageSent(MessageHandler)

  /// Session has loaded
  ///
  /// Handles the session loaded event (triggers your callback function, with sessionId).
  case sessionLoaded(SessionIdHandler)
}

public extension Callback {
  typealias MessageHandler = @MainActor (Message) -> Void
  typealias SessionIdHandler = @MainActor (String) -> Void
  typealias VoidHandler = @MainActor () -> Void
}

public final class CallbackToken {
  let id: CallbackId

  init(id: CallbackId) {
    self.id = id
  }
}
