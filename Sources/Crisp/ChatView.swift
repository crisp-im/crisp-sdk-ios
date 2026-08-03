internal import CrispChatBox
import SwiftUI

/// The View that hosts the Crisp chat (SwiftUI).
///
/// - Important: Make sure that you have configured your Website ID before you present the
/// `ChatView`. See: ``CrispSDK/configure(websiteID:)``.
///
/// You can present the `ChatView` like you would present any other `View`.
///
/// ```swift
/// struct ContentView: View {
///   @State var isChatPresented = false
///
///   var body: some View {
///     Button("Show chat") {
///       self.isChatPresented = true
///     }
///     .sheet(isPresented: self.$isChatPresented) {
///       ChatView()
///     }
///     .padding()
///   }
/// }
/// ```
///
/// - Tip: If you're using UIKit you can present the ``ChatViewController`` instead.
public struct ChatView: View {
  private let configuration: ChatViewConfiguration

  /// Initializes the `ChatView`.
  public init(configuration: ChatViewConfiguration = .default) {
    self.configuration = configuration
  }

  /// The content and behavior of the view.
  public var body: some View {
    OpaqueChatViewWrapper(configuration: self.configuration)
  }
}

private struct OpaqueChatViewWrapper: View {
  let configuration: ChatViewConfiguration

  var body: some View {
    ChatBoxView(
      model: ChatBoxModel(api: CrispSDK.apiModel),
      configuration: self.configuration.chatBoxConfiguration,
    )
  }
}
