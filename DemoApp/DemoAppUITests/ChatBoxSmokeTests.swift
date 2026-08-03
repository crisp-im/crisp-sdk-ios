import XCTest

@MainActor
final class ChatBoxSmokeTests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  func testChatBoxOpensWithoutError() throws {
    let websiteId = try XCTUnwrap(
      ProcessInfo.processInfo.environment["WEBSITE_ID"].flatMap { $0.isEmpty ? nil : $0 },
      "Set the WEBSITE_ID environment variable to run this test.",
    )

    let app = XCUIApplication()
    app.launchEnvironment["WEBSITE_ID"] = websiteId
    app.launch()

    app.buttons["Start Chat"].tap()

    // Two independent signals must both hold for a healthy chat:
    //   1. The SDK reports the session connected (widget booted + socket session joined).
    //      The DemoApp exposes this marker only once its sessionLoaded callback fires.
    //   2. The widget chrome actually rendered in the web view.
    // Generous timeout to cover a cold WebView start plus the handshake on a slow CI
    // simulator.
    let connected = app.descendants(matching: .any)["crisp.sessionLoaded"]
    let crispFooter = app.webViews.firstMatch.links["We run on crisp"]

    XCTAssertTrue(
      connected.waitForExistence(timeout: 30),
      "Chat did not connect: the SDK's sessionLoaded callback never fired.",
    )
    XCTAssertTrue(
      crispFooter.waitForExistence(timeout: 5),
      "Chat connected but the widget UI did not render (\"We run on crisp\" footer missing).",
    )
  }
}
