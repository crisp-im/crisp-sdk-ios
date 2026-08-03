import Foundation

/// Represents a APNs device token
package struct DeviceToken:
  Codable,
  Hashable,
  RawRepresentable,

  CustomStringConvertible
{
  package var rawValue: Data

  package init(_ value: Data) {
    self.rawValue = value
  }

  package init(rawValue value: Data) {
    self.rawValue = value
  }

  package init?(_ hexString: String) {
    // Ensure the string length is even
    guard hexString.count % 2 == 0 else { return nil }

    var data = Data()

    // Convert pairs of hex characters to bytes
    for i in stride(from: 0, to: hexString.count, by: 2) {
      let start = hexString.index(hexString.startIndex, offsetBy: i)
      let end = hexString.index(start, offsetBy: 2)
      let byteString = String(hexString[start ..< end])

      if let byte = UInt8(byteString, radix: 16) {
        data.append(byte)
      } else {
        return nil
      }
    }

    self.rawValue = data
  }

  package var description: String {
    self.rawValue.map { String(format: "%.2hhx", $0) }.joined()
  }
}
