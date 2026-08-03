import Crisp
import Foundation

@MainActor @Observable
public final class MainViewModel {
  let sheetChatViewModel: SheetChatViewModel
  let settingsViewModel: SettingsViewModel

  var chatBoxModelId = 0

  var viewConfiguration: ChatViewConfiguration = .default

  init() {
    self.sheetChatViewModel = SheetChatViewModel()
    self.settingsViewModel = SettingsViewModel()

    self.settingsViewModel.onShouldReload = { [weak self] in
      self?.chatBoxModelId += 1
    }
  }
}
