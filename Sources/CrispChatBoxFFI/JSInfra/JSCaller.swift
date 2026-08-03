import CrispDomain
import Foundation

package typealias JSEvaluator = @MainActor (_ javaScriptString: String) async throws -> Any?

enum JSEvaluationError: Error {
  case typeMismatch
  case jsException(String)
}

extension JSEvaluationError: CustomStringConvertible {
  var description: String {
    switch self {
    case .typeMismatch:
      "JS evaluation result could not be converted to the expected Swift type"
    case let .jsException(message):
      "JS exception: \(message)"
    }
  }
}

/// JSON-encodes an `Encodable` argument to a JS-source string.
/// Used by the generated `CrispClient` method bodies.
func jsEncode(_ object: some Encodable) -> String {
  let jsonData: Data
  do {
    jsonData = try JSONEncoder().encode(object)
  } catch {
    fatalError("\(object) could not be encoded to JSON")
  }
  guard let json = String(data: jsonData, encoding: .utf8) else {
    fatalError("\(object) could not be converted to String")
  }
  return json
}

@MainActor @dynamicCallable
struct JSCaller {
  private let funcName: String
  private let evaluator: JSEvaluator

  init(funcName: String, evaluator: @escaping JSEvaluator) {
    self.funcName = funcName
    self.evaluator = evaluator
  }

  func dynamicallyCall<T>(withArguments args: [String]) async throws -> T {
    let raw: Any?
    do {
      raw = try await self.evaluator(
        #"""
        const result = await \#(self.funcName)(\#(args.joined(separator: ", ")));
        if (result === null || result === undefined) return result;
        if (typeof result === 'object') return JSON.stringify(result);
        return result;
        """#,
      )
    } catch let nsError as NSError
      where nsError.userInfo["WKJavaScriptExceptionMessage"] is String
    {
      let message = (nsError.userInfo["WKJavaScriptExceptionMessage"] as? String)
        ?? nsError.localizedDescription
      throw JSEvaluationError.jsException(message)
    }

    if T.self == Void.self {
      // swiftlint:disable:next force_cast
      return () as! T
    }

    if let value = raw as? T {
      return value
    }

    if let rawType = T.self as? any RawRepresentable.Type, let raw {
      if let value = decodeRawRepresentable(rawType, from: raw) as? T {
        return value
      }
    }

    if let decodableType = T.self as? any Decodable.Type, let str = raw as? String {
      let decoder = JSONDecoder()
      decoder.userInfo[ConversationMessageDecodingContext.userInfoKey]
        = ConversationMessageDecodingContext()
      let decoded = try decoder.decode(decodableType.self, from: Data(str.utf8))

      guard let value = decoded as? T else {
        throw JSEvaluationError.typeMismatch
      }

      return value
    }

    throw JSEvaluationError.typeMismatch
  }
}

private func decodeRawRepresentable<R: RawRepresentable>(_ type: R.Type, from raw: Any) -> R? {
  guard let str = raw as? R.RawValue else { return nil }
  return R(rawValue: str)
}
