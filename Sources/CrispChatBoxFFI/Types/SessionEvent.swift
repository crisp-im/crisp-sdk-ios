import CrispUtils

package struct SessionEvent {
  package var name: String
  package var color: Color?
  package var data: [String: any Sendable & Encodable]

  package init(name: String, color: Color?, data: [String: any Sendable & Encodable]) {
    self.name = name
    self.color = color
    self.data = data
  }
}

package extension SessionEvent {
  enum Color: String, Codable, Equatable {
    case red
    case orange
    case yellow
    case green
    case blue
    case purple
    case pink
    case brown
    case grey
    case black
  }
}

extension SessionEvent: Encodable {
  private enum CodingKeys: String, CodingKey {
    case name = "text"
    case color
    case data
  }

  package func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.name, forKey: .name)
    try container.encodeIfPresent(self.color, forKey: .color)
    try container.encode(
      self.data.mapValues { value in AnyEncodable(value) },
      forKey: .data,
    )
  }
}
