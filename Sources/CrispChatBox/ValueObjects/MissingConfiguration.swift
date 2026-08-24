import CrispDomain
import Foundation

/// The pieces of setup a host app must provide before the chat can be presented.
struct MissingConfiguration: OptionSet, Hashable {
  /// `CrispSDK.configure(websiteID:)` was never called.
  static let websiteId = MissingConfiguration(rawValue: 1 << 0)

  /// `NSCameraUsageDescription` is missing from the host app's Info.plist.
  static let cameraUsageDescription = MissingConfiguration(rawValue: 1 << 1)

  /// `NSMicrophoneUsageDescription` is missing from the host app's Info.plist.
  static let microphoneUsageDescription = MissingConfiguration(rawValue: 1 << 2)

  let rawValue: Int
}

extension MissingConfiguration {
  init(websiteId: WebsiteId?, bundle: Bundle) {
    self = []

    if websiteId == nil {
      self.insert(.websiteId)
    }
    if !bundle.crisp_hasCameraUsageDescription {
      self.insert(.cameraUsageDescription)
    }
    if !bundle.crisp_hasMicrophoneUsageDescription {
      self.insert(.microphoneUsageDescription)
    }
  }
}
