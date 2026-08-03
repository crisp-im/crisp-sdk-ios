import Foundation

extension String {
  func isValidSHA256() -> Bool {
    guard self.count == 64 else {
      return false
    }
    let hexCharacterSet = CharacterSet(charactersIn: "0123456789abcdefABCDEF")
    return self.unicodeScalars.allSatisfy { hexCharacterSet.contains($0) }
  }
}
