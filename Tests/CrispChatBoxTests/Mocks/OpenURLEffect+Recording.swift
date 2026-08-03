import CrispChatBox
import Foundation

@MainActor
final class OpenURLRecorder {
  private(set) var openedURLs: [URL] = []

  func record(_ url: URL) {
    self.openedURLs.append(url)
  }
}

extension OpenURLEffect {
  static func recording(into recorder: OpenURLRecorder) -> Self {
    .init { url in
      await MainActor.run { recorder.record(url) }
      return true
    }
  }
}
