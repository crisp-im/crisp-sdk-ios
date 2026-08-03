import Crisp
import SwiftUI

struct MainView: View {
  enum Tab {
    case sheet
    case inline
    case settings
  }

  @State var model: MainViewModel
  @State var selectedTab = Tab.sheet

  var body: some View {
    TabView(selection: self.$selectedTab) {
      SheetChatView(model: self.model.sheetChatViewModel)
        .tabItem {
          Label("Sheet", systemImage: "macwindow")
        }
        .tag(Tab.sheet)

      ChatView(configuration: self.model.viewConfiguration)
        .id(self.model.chatBoxModelId)
        .tabItem {
          Label("Inline", systemImage: "bubble")
        }
        .tag(Tab.inline)
        .ignoresSafeArea()

      SettingsView(model: self.model.settingsViewModel)
        .tabItem {
          Label("Settings", systemImage: "gear")
        }
        .tag(Tab.settings)
    }
  }
}
