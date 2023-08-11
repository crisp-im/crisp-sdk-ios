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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.4.0/Crisp_2.4.0.zip",
      checksum: "b8744f51daae8c6e5b135949dd305ad2fefd250f57833bebfe3c8a2c43916b76"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.4.0/CrispWebRTC_2.4.0.zip",
      checksum: "21014c5921a2dd181dd3e5e4c00ddb557eb2ca538f5962da482c601a24b763ca"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.4.0/WebRTC_2.4.0.zip",
      checksum: "ab647885062827975fbc0980a0a6cb301c684c12c19e76036b355afd1708cf82"
    ),
  ]
)
