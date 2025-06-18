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
      checksum: "09c02e44e71153d0cc265102b0cf97ada30ee942202776851d09a923e70326ec"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.9.0-beta.2/CrispWebRTC_2.9.0-beta.2.zip",
      checksum: "d1d6881e08095427dbb1939b585ea8efd6daae2a8d34fcae73f87896e8b44cfb"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.9.0-beta.2/WebRTC_2.9.0-beta.2.zip",
      checksum: "52f73dc7fa80fcfe219ef6b6c11ba9e1795786b88c43832fa4d8f07fc509204b"
    ),
  ]
)
