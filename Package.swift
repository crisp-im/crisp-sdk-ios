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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.4.4/Crisp_2.4.4.zip",
      checksum: "7c8e64baabfc0075572538f641f293c9f9c5b071c1589493886ab3cf1f3daebd"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.4.4/CrispWebRTC_2.4.4.zip",
      checksum: "84b7e59fd5618630073b2eb8952e2c514a496e7b98bbeeb0dc6e49a22b1fa292"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.4.4/WebRTC_2.4.4.zip",
      checksum: "bcf462c5b0df092da7feb8c601c6c8d4616f8d6412faec4d04e162190e68ced9"
    ),
  ]
)
