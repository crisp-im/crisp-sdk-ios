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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.8.2/Crisp_2.8.2.zip",
      checksum: "b2d0d8777ea67aebcbf064a301457e8e2bf9f78246eb27e277f26500d6546115"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.8.2/CrispWebRTC_2.8.2.zip",
      checksum: "7ad95984ca6a67c1dc5cf3f49b2c1b9198584ce657e98f48e3c0b3f7608b9b1a"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.8.2/WebRTC_2.8.2.zip",
      checksum: "e747699b629ca70b3ce2409094664f60fa490368e77b51f8c801ce8c482ae030"
    ),
  ]
)
