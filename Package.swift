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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.9.0-beta.2/Crisp_2.9.0-beta.2.zip",
      checksum: "6e60cbf2d96c5674584724aee4c4a409a8e4cf3c3503e654d02428bfea205abb"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.9.0-beta.2/CrispWebRTC_2.9.0-beta.2.zip",
      checksum: "967b32b89dae5529e3d37c6678a159af4b12ed95aabe27fd625467464a21570a"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.9.0-beta.2/WebRTC_2.9.0-beta.2.zip",
      checksum: "52f73dc7fa80fcfe219ef6b6c11ba9e1795786b88c43832fa4d8f07fc509204b"
    ),
  ]
)
