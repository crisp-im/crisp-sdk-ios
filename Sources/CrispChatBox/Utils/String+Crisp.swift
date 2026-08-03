import Foundation

package extension String {
  func trimmedNonEmptyString() -> String? {
    let trimmedString = self.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmedString.isEmpty {
      return nil
    }
    return trimmedString
  }
}
