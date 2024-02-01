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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.4.5/Crisp_2.4.5.zip",
      checksum: "bf2e9047e57dd0acdb82813a683fc7e1b9e18c1e78c14b36c9904d5a34e9d6b7"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.4.5/CrispWebRTC_2.4.5.zip",
      checksum: "0fa2f0fd0f90f8fdd88ed13973092a3e3c87efbc6ad8c6348abc11b6c1d88e27"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.4.5/WebRTC_2.4.5.zip",
      checksum: "f8eace74f0e034d87c0ee1016ee5f83102be9a281e91aa7f25723b079feeb0c6"
    ),
  ]
)
