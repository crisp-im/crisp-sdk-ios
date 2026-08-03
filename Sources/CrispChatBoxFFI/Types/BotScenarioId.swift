import Foundation

/// Identifies a bot scenario.
package struct BotScenarioId:
  Codable,
  Hashable,
  RawRepresentable,
  CustomStringConvertible,
  ExpressibleByStringLiteral,
  CustomDebugStringConvertible
{
  package var rawValue: String

  package init(_ value: String) {
    self.rawValue = value
  }

  package init(stringLiteral value: String) {
    self.rawValue = value
  }

  package init(rawValue value: String) {
    self.rawValue = value
  }

  package var debugDescription: String {
    self.rawValue
  }

  package var description: String {
    self.rawValue
  }
}
