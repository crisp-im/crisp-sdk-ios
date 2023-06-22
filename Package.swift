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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.3.1/Crisp_2.3.1.zip",
      checksum: "ed202507dcd116ed28783a764cf0e4a3d6bb8da4d94fc95fdd7294c08bbe7f68"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.3.1/CrispWebRTC_2.3.1.zip",
      checksum: "22d8c38db6d0f9be78a91f93030dc8aaf021cd7eb266dd74d375b81d7d63f775"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.3.1/WebRTC_2.3.1.zip",
      checksum: "d03666c8e6a2174c693a3c3183babe02d69828b10d0033ea790476eb1ee598a3"
    ),
  ]
)
