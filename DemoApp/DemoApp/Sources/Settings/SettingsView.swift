import SwiftUI

struct SettingsView: View {
  @Bindable var model: SettingsViewModel

  var body: some View {
    VStack {
      WebsiteIdView(model: self.model)

      TokenIdView(model: self.model)

      GroupBox(label: Label("Session", systemImage: "bubble")) {
        Button("Reset Session") {
          self.model.resetChatSession()
        }
      }

      Spacer()
    }
    .padding()
    .onAppear { self.model.onAppear() }
  }
}

struct WebsiteIdView: View {
  @Bindable var model: SettingsViewModel

  @State var isAlertPresented = false
  @State var websiteId = ""

  var body: some View {
    GroupBox(label: Label("Website ID", systemImage: "globe")) {
      HStack {
        Text(self.model.websiteId ?? "<none>")
          .foregroundStyle(self.model.websiteId == nil ? .secondary : .primary)
        Spacer()
        Button("Set") {
          self.websiteId = self.model.websiteId ?? ""
          self.isAlertPresented = true
        }
      }
    }
    .alert("Set Website ID", isPresented: self.$isAlertPresented) {
      TextField("Website ID", text: self.$websiteId)
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)

      Button("OK") {
        self.model.websiteId = self.websiteId.isEmpty
          ? nil
          : self.websiteId
      }
      .keyboardShortcut(.defaultAction)

      Button("Cancel", role: .cancel) {}
    } message: {
      Text("Changing the Website ID will reload the chat.")
    }
  }
}

struct TokenIdView: View {
  @Bindable var model: SettingsViewModel

  @State var isAlertPresented = false
  @State var tokenId = ""

  var body: some View {
    GroupBox(label: Label("Token ID", systemImage: "person")) {
      HStack {
        Text("\(self.model.tokenId ?? "<none>")")
          .foregroundStyle(self.model.tokenId == nil ? .secondary : .primary)
        Spacer()
        Button("Set") {
          self.tokenId = self.model.tokenId ?? ""
          self.isAlertPresented = true
        }
      }
    }
    .alert("Set Token ID", isPresented: self.$isAlertPresented) {
      TextField("Token ID", text: self.$tokenId)
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)

      Button("OK") {
        self.model.tokenId = self.tokenId.isEmpty
          ? nil
          : self.tokenId
      }
      .keyboardShortcut(.defaultAction)

      Button("Cancel", role: .cancel) {}
    } message: {
      Text("Changing the Token ID will reset the session.")
    }
  }
}
