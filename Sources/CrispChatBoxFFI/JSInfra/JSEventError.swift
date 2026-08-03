import Foundation

package enum JSEventError: Error, Equatable {
  case badSerialization
  case decodingError(String)
}

extension JSEventError: CustomDebugStringConvertible {
  package var debugDescription: String {
    switch self {
    case .badSerialization:
      "JS message body should be serialized as a String"
    case let .decodingError(debugDescription):
      debugDescription
    }
  }
}
