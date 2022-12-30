// swift-tools-version:5.7
import PackageDescription

let package = Package(
  name: "Crisp",
  platforms: [.iOS(.v13)],
  products: [
    .library(name: "Crisp", targets: ["CrispTarget"]),
    .library(name: "CrispWebRTC", targets: ["CrispWebRTCTarget"])
  ],
  targets: [
    .target(
      name: "CrispTarget",
      dependencies: [
        .target(name: "Crisp")
      ]
    ),
    .target(
      name: "CrispWebRTCTarget",
      dependencies: [
        .target(name: "CrispWebRTC"),
        .target(name: "WebRTC")
      ]
    ),
    .binaryTarget(
      name: "Crisp",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.0.0-beta.26/Crisp_2.0.0-beta.26.zip",
      checksum: "584dad134550e1145653e46f5963533083e33970f3aad86ef8f6e135fe407a50"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.0.0-beta.26/CrispWebRTC_2.0.0-beta.26.zip",
      checksum: "75692e6fb30ff0038f12b683e8a8c7de6b756ac44af033924cd82be8ac9c5f2f"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.0.0-beta.26/WebRTC_2.0.0-beta.26.zip",
      checksum: "8d98e51d52f88a480db64724e3a39f870fc8f7235a9bebc91697e35b4a8abc55"
    ),
  ]
)
