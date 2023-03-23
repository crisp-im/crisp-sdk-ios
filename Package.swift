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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.2.1/Crisp_2.2.1.zip",
      checksum: "5c13034b343bf6e080a7ffdba3e9abf04bc6690a1cf9a75a08c89640283441bb"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.2.1/CrispWebRTC_2.2.1.zip",
      checksum: "2968b1b3f758330de6329177de2987cea8bcce69440ce8172faff9b7a32ef548"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.2.1/WebRTC_2.2.1.zip",
      checksum: "3eb12a52611fe234da3952c528d3e1f4b94c212da40121ef235f4ce9fd768def"
    ),
  ]
)
