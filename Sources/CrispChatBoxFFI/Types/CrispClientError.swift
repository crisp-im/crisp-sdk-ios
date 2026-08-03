import Foundation

package enum CrispClientError: Error, Equatable {
  case bundleMissing
  case htmlMissing
  case htmlReadFailed(url: URL)
  case invalidAssetsURL
}

extension CrispClientError: LocalizedError {
  package var errorDescription: String? {
    self.localizedDescription
  }

  package var localizedDescription: String {
    switch self {
    case .bundleMissing:
      "dist bundle is missing"
    case .htmlMissing:
      "index.html is missing"
    case let .htmlReadFailed(url):
      "Could not read index.html from \(url.absoluteString)"
    case .invalidAssetsURL:
      "Could not build assets URL"
    }
  }
}
