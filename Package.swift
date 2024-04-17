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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.5.1/Crisp_2.5.1.zip",
      checksum: "f2df5184f823bab4e532ff662d0614e537ef124656013f48e9bb76f7a2e0cac6"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.5.1/CrispWebRTC_2.5.1.zip",
      checksum: "40c86da48c169070c60d6ac51e8912bc1d948f238a63a39db22c9d4745fad1a3"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.5.1/WebRTC_2.5.1.zip",
      checksum: "7c9214e39d1e6335b984aeb399aa2491218649aed30e7c96e18180ab8b5ff4fa"
    ),
  ]
)
