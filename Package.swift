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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.0.0/Crisp_2.0.0.zip",
      checksum: "7bacf0ce9a63f5caea01f4ac312da763b1773abe26abc25dc6d3ee0244dad222"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.0.0/CrispWebRTC_2.0.0.zip",
      checksum: "d929338ad6e4a7ec2ddb17546a622fd6ea129a602cd892689a67361a6ebd4358"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.0.0/WebRTC_2.0.0.zip",
      checksum: "59ee9fdee695c2be6c6c95231f347cfbe655c56781c13f36188a4c8748594631"
    ),
  ]
)
