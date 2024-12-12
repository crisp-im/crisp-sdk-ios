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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.8.1/Crisp_2.8.1.zip",
      checksum: "91253f15ff8b5cc64f6719cfe9a45d9102527ba51f92e57ebc0a6d3ffee720b6"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.8.1/CrispWebRTC_2.8.1.zip",
      checksum: "fca9fe752b149c16d19abd7f6411e59df202ca961658ded126d996d28fb858db"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.8.1/WebRTC_2.8.1.zip",
      checksum: "3e76976d3657cf6258b670fd93655ea97624d366656c233d80f607e6bb8694f8"
    ),
  ]
)
