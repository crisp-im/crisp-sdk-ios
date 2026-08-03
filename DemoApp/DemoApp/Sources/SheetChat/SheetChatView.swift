import Crisp
import SwiftUI

struct SheetChatView: View {
  @Bindable var model: SheetChatViewModel

  var body: some View {
    VStack(spacing: 40) {
      GroupBox(label: Text("Received Callbacks")) {
        CallbackIndicator(name: "Chat opened", info: self.model.callbacks.chatOpened)
        CallbackIndicator(name: "Chat closed", info: self.model.callbacks.chatClosed)
        CallbackIndicator(name: "Message received", info: self.model.callbacks.messageReceived)
        CallbackIndicator(name: "Message sent", info: self.model.callbacks.messageSent)
        CallbackIndicator(name: "Session loaded", info: self.model.callbacks.sessionLoaded)
      }

      GroupBox(label: Text("Navigation")) {
        Button("Open Helpdesk") {
          self.model.openHelpdesk()
        }
      }

      ChatDataView(model: self.model)

      Button("Start Chat") {
        self.model.startChat()
      }.buttonStyle(.borderedProminent)
        .sheet(item: self.$model.route, content: { route in
          switch route {
          case .chat:
            ChatView()
              .overlay {
                // A real "chat connected" signal for UI tests. This marker appears only
                // once the SDK's sessionLoaded callback fires.
                if self.model.callbacks.sessionLoaded.called {
                  Color.clear
                    .frame(width: 1, height: 1)
                    .accessibilityElement()
                    .accessibilityIdentifier("crisp.sessionLoaded")
                    .allowsHitTesting(false)
                }
              }
          }
        })
    }
    .padding()
  }
}

struct CallbackIndicator: View {
  let name: String
  let called: Bool
  let data: String?

  @State var sheetPresented = false

  init(name: String, info: SheetChatViewModel.Callback) {
    self.name = name
    self.called = info.called
    self.data = info.data
  }

  var body: some View {
    HStack {
      Text(self.name)
      Spacer()

      if self.data != nil {
        Button {
          self.sheetPresented = true
        } label: {
          Image(systemName: "text.page")
        }
      }

      Circle()
        .fill(self.called ? Color.green : Color.red)
        .frame(width: 12, height: 12)
    }
    .sheet(isPresented: self.$sheetPresented) {
      VStack {
        ScrollView(.vertical) {
          Text(self.data ?? "<no data>")
            .multilineTextAlignment(.leading)
        }
        .padding()

        Button("Copy") {
          UIPasteboard.general.string = self.data
        }.buttonStyle(.bordered)
      }
      .presentationDetents([.medium])
    }
  }
}

struct ChatDataView: View {
  @Bindable var model: SheetChatViewModel
  @State private var isSheetPresented = false

  var body: some View {
    GroupBox(label: Text("Data")) {
      Button("Set Session Data") {
        self.isSheetPresented = true
      }
      .sheet(isPresented: self.$isSheetPresented) {
        let (key, value) = self.model.loadLastSessionData()

        EntrySheet(isPresented: self.$isSheetPresented, key: key, value: value) {
          self.model.setSessionData(key: $0, value: $1)
        }
      }
    }
  }
}

struct EntrySheet: View {
  @State var key = ""
  @State var value = ""
  @Binding var isPresented: Bool

  init(
    isPresented: Binding<Bool>,
    key: String?,
    value: String?,
    onSave: @escaping (String, String) -> Void,
  ) {
    self._isPresented = isPresented
    self.key = key ?? ""
    self.value = value ?? ""
    self.onSave = onSave
  }

  let onSave: (String, String) -> Void

  var body: some View {
    NavigationStack {
      Form {
        TextField("Key", text: self.$key)
        TextField("Value", text: self.$value)
      }
      .navigationTitle("Add Entry")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { self.isPresented = false }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            self.isPresented = false
            self.onSave(self.key, self.value)
          }
        }
      }
    }
    .presentationDetents([.medium])
  }
}
