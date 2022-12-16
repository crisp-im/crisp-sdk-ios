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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.0.0-beta.25/Crisp_2.0.0-beta.25.zip",
      checksum: "32b666ccf60054e2f60358e240435439750d2b305cbe3ffc57dc2006da1479d5"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.0.0-beta.25/CrispWebRTC_2.0.0-beta.25.zip",
      checksum: "b87bd66c29cba5c8ba5a482c762b39a401c27e1fd2c05a8d2eccaa76873825cf"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.0.0-beta.25/WebRTC_2.0.0-beta.25.zip",
      checksum: "8d98e51d52f88a480db64724e3a39f870fc8f7235a9bebc91697e35b4a8abc55"
    ),
  ]
)
