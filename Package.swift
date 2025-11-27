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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.12.0/Crisp_2.12.0.zip",
      checksum: "daa48651e26bd763bcd73818e9e369602d52620c7dff698671c709503ec64766"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.12.0/CrispWebRTC_2.12.0.zip",
      checksum: "b37bda8b3d29fd8309f125f6f2ae601b72935a6b491eb06a7d073d1410c8e8d2"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.12.0/WebRTC_2.12.0.zip",
      checksum: "52f73dc7fa80fcfe219ef6b6c11ba9e1795786b88c43832fa4d8f07fc509204b"
    ),
  ]
)
