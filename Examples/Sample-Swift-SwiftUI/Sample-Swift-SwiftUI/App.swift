import Crisp
import SwiftUI

@main
struct CrispDemoApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}

struct ContentView: View {
  @State var isChatPresented = false

  init() {
    #error("Configure your Crisp Website ID here…")
    CrispSDK.configure(websiteID: "YOUR-WEBSITE-ID")
  }

  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      Button(action: { self.isChatPresented = true }) {
        Image("crisp")
          .foregroundColor(.white)
          .frame(width: 60, height: 60)
          .background(Circle().fill(.tint))
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
          .padding()
      }
    }
    .sheet(isPresented: self.$isChatPresented) {
      ChatView()
    }
  }
}
