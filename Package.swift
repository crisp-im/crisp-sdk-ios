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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.4.3/Crisp_2.4.3.zip",
      checksum: "8ed7cad67afe7d7f472f683508bb9ae72af56413a6c37e550e65124f02a4fffd"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.4.3/CrispWebRTC_2.4.3.zip",
      checksum: "96982de3595d0703ce17b3aa28605f2a08210a807a6c3ea777b3f09935fe8469"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.4.3/WebRTC_2.4.3.zip",
      checksum: "aaf3cfa3e9b26fa33951fd663cc5d20d5b62e0515d2b2ad94ac92be823b62e6a"
    ),
  ]
)
