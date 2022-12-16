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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.0.0-beta.24/Crisp_2.0.0-beta.24.zip",
      checksum: "f53b060799416bf7146eb34240853ec6b4963e3da95f0783a9daf056b70760f2"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.0.0-beta.24/CrispWebRTC_2.0.0-beta.24.zip",
      checksum: "20830485137cb02242c153b641a1376a71a1b663fa696c3aade3bc83f7860bac"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.0.0-beta.24/WebRTC_2.0.0-beta.24.zip",
      checksum: "8d98e51d52f88a480db64724e3a39f870fc8f7235a9bebc91697e35b4a8abc55"
    ),
  ]
)
