import Foundation

extension Bundle {
  var crisp_hasCameraUsageDescription: Bool {
    guard
      let description = self.infoDictionary?["NSCameraUsageDescription"] as? String,
      !description.isEmpty
    else {
      return false
    }
    return true
  }

  var crisp_hasPhotoLibraryAddUsageDescription: Bool {
    guard
      let description = self.infoDictionary?["NSPhotoLibraryAddUsageDescription"] as? String,
      !description.isEmpty
    else {
      return false
    }
    return true
  }

  var crisp_hasMicrophoneUsageDescription: Bool {
    guard
      let description = self.infoDictionary?["NSMicrophoneUsageDescription"] as? String,
      !description.isEmpty
    else {
      return false
    }
    return true
  }
}
