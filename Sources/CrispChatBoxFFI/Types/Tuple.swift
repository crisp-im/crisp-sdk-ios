import CrispUtils
import Foundation

package struct Tuple: Encodable {
  var key: String
  var value: AnyEncodable

  package init(key: String, value: any Encodable) {
    self.key = key
    self.value = AnyEncodable(value)
  }

  package func encode(to encoder: any Encoder) throws {
    var container = encoder.unkeyedContainer()
    try container.encode(self.key)
    try container.encode(self.value)
  }
}
