import WebKit

package extension WKWebView {
  /// We need to use `callAsyncJavaScript` because the ChatBox methods
  /// return Promises and `evaluateJavaScript` in these cases fails with "JavaScript execution
  /// returned a result of an unsupported type". So we need to bump to iOS 14. We're sticking with
  /// the completionHandler variant of `callAsyncJavaScript` where since the newer async-ready
  /// version would require iOS 15
  func crisp_makeJSEvaluator() -> JSEvaluator {
    { [weak self] javaScript in
      guard let self else { return nil }

      return try await withCheckedThrowingContinuation { continuation in
        self.callAsyncJavaScript(javaScript, in: nil, in: .page) { result in
          switch result {
          case let .success(value):
            continuation.resume(returning: SendableJSValue(value: value))
          case let .failure(error):
            continuation.resume(throwing: error)
          }
        }
      }.value
    }
  }
}

// `Any?` can't cross the strict-concurrency `@Sendable` boundary on its own,
// but the values WebKit hands back from `callAsyncJavaScript` are bridged
// JSON Foundation types (`NSString`/`NSNumber`/`NSArray`/`NSDictionary`),
// which are immutable and safe to send. This box exists so we can transport them through the
// continuation without disabling concurrency checking on the call sites.
// swiftlint:disable:next no_unchecked_sendable
struct SendableJSValue: @unchecked Sendable {
  let value: Any?
}
