import SwiftUI

package struct ChatBoxView: View {
  private let model: ChatBoxModel
  private let configuration: ChatViewConfiguration

  package init(model: ChatBoxModel, configuration: ChatViewConfiguration) {
    self.model = model
    self.configuration = configuration
  }

  package var body: some View {
    ChatViewUI(model: self.model, configuration: self.configuration)
      .navigationTitle(.init(verbatim: ""))
      .navigationBarHidden(true)
      .edgesIgnoringSafeArea(.all)
  }
}

private struct ChatViewUI: UIViewControllerRepresentable {
  private let model: ChatBoxModel
  private let configuration: ChatViewConfiguration

  init(model: ChatBoxModel, configuration: ChatViewConfiguration) {
    self.model = model
    self.configuration = configuration
  }

  func makeUIViewController(
    context _: UIViewControllerRepresentableContext<ChatViewUI>,
  ) -> ChatBoxViewController {
    ChatBoxViewController(model: self.model, configuration: self.configuration)
  }

  func updateUIViewController(
    _: ChatBoxViewController,
    context _: UIViewControllerRepresentableContext<ChatViewUI>,
  ) {}
}
