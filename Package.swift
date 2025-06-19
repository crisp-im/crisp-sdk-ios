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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.9.0-beta.3/Crisp_2.9.0-beta.3.zip",
      checksum: "4aadedd2e1b99681eb9ed399d53d696f94f7b51d330c47d5c9502a56a7081eec"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.9.0-beta.3/CrispWebRTC_2.9.0-beta.3.zip",
      checksum: "e5a30bf096c5a0486730574fe9002ec5df47178804d6b03ac49da46f17a194fc"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.9.0-beta.3/WebRTC_2.9.0-beta.3.zip",
      checksum: "52f73dc7fa80fcfe219ef6b6c11ba9e1795786b88c43832fa4d8f07fc509204b"
    ),
  ]
)
