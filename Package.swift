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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.5.3/Crisp_2.5.3.zip",
      checksum: "aaa56ac0f73f137f46f9719d03faafd8fd664889c8f98dc3f754f2d844285832"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.5.3/CrispWebRTC_2.5.3.zip",
      checksum: "0970e2bdaf53af116454a90445820d498595e0aa6aab7e848b7bde64b8b6e5c8"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.5.3/WebRTC_2.5.3.zip",
      checksum: "7c9214e39d1e6335b984aeb399aa2491218649aed30e7c96e18180ab8b5ff4fa"
    ),
  ]
)
