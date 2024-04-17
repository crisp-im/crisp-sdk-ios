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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.5.0/Crisp_2.5.0.zip",
      checksum: "c6e0ba5a077387b7b076caab9802b70dfa9d5cd31986a01a538c44ac6a89f8db"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.5.0/CrispWebRTC_2.5.0.zip",
      checksum: "73486e18046a933d5809d83658b40389c03d8ddc0ba8267291e717ab4123ad0c"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.5.0/WebRTC_2.5.0.zip",
      checksum: "332ffc3013715bea9a585858cdd338735096b7515728f662163083e4dfab405f"
    ),
  ]
)
