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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.5.4/Crisp_2.5.4.zip",
      checksum: "5f265478d86bc4c57bbe1e3545b9be863d35c786ffdd17ab867a8dd43b1d0b79"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.5.4/CrispWebRTC_2.5.4.zip",
      checksum: "85de65caaf2d31d2ebe21de6b42723192814368e642642ddcc110bd44e616dcf"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.5.4/WebRTC_2.5.4.zip",
      checksum: "7c9214e39d1e6335b984aeb399aa2491218649aed30e7c96e18180ab8b5ff4fa"
    ),
  ]
)
