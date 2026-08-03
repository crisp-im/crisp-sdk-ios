@testable import CrispChatBox
import Foundation
import Testing

@Suite("External link tests")
@MainActor struct ChatBoxHostModelExternalLinkTests {
  /// `http(s)://…` taps route the WebView through `SFSafariViewController`,
  /// surfaced as `route == .externalURL(url)`. The system-level openURL
  /// effect should not be invoked.
  @Test func setsExternalURLRouteForHttpsLinks() async throws {
    let recorder = OpenURLRecorder()
    let model = ChatBoxHostModel { $0.openURL = .recording(into: recorder) }

    let url = try #require(URL(string: "https://example.com/article"))
    model.onExternalLinkTapped(url: url)

    guard case let .externalURL(routedURL) = model.route else {
      Issue.record("Expected route == .externalURL(url); got \(String(describing: model.route))")
      return
    }
    #expect(routedURL == url)

    // `openURL` shouldn't have been called for an http link.
    try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 100)
    #expect(recorder.openedURLs.isEmpty)
  }

  /// Non-http schemes (mailto, tel, custom app links) bypass the in-app
  /// browser and are handed off to the system via `OpenURLEffect`. The
  /// model's route stays nil.
  @Test func delegatesToOpenURLForNonHttpLinks() async throws {
    let recorder = OpenURLRecorder()
    let model = ChatBoxHostModel { $0.openURL = .recording(into: recorder) }

    let url = try #require(URL(string: "mailto:foo@bar.com"))
    model.onExternalLinkTapped(url: url)

    // `openURL` is invoked from a Task, poll until it lands.
    await waitUntil { !recorder.openedURLs.isEmpty }

    #expect(recorder.openedURLs == [url])
    #expect(model.route == nil)
  }
}
