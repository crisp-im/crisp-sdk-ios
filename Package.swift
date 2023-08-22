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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.4.1/Crisp_2.4.1.zip",
      checksum: "7214342fdb11b3c5f7e7847e7c0c0b94ed679c5cbec28faf9bad6e8e95a2633a"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.4.1/CrispWebRTC_2.4.1.zip",
      checksum: "5fb814579553448c1e6a839f69e08a8de6c8e77c73f75f45eec1d4afbdc52ebf"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.4.1/WebRTC_2.4.1.zip",
      checksum: "c9c52fe89b82fa51c98ae64c835f54e71584813a56035364a79e1f7a5c6ff5b8"
    ),
  ]
)
