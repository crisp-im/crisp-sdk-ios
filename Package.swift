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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.3.0/Crisp_2.3.0.zip",
      checksum: "64f12fe04612fd083c9c52ae821d3b28c72a3cf489b511ab234b9e2281780759"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.3.0/CrispWebRTC_2.3.0.zip",
      checksum: "ce672fe1efa24424808eaf8d3cbc3ddcec8c7538c2b84449046b9ae09acf2b1b"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.3.0/WebRTC_2.3.0.zip",
      checksum: "c6b97569415f1a10afe49bfe8b905d3c32f636fa10718dd3173c0d1123e8f4c8"
    ),
  ]
)
