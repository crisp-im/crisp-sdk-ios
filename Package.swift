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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.1.0/Crisp_2.1.0.zip",
      checksum: "2369bc48c6f67edb71b2ddaa4dc3f95adccd0c1ef15cf1c44f3ec9a4071ee0d7"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.1.0/CrispWebRTC_2.1.0.zip",
      checksum: "9612197eb69af8a3edc975e4b3ff627ada3d7a45e8d29adbc619381e30bc66b0"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.1.0/WebRTC_2.1.0.zip",
      checksum: "d8a6b905326c00fa230802dc96188000baf3908a5f9b94851ed4d77ecae582b6"
    ),
  ]
)
