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
      checksum: "8f3824a9100baaafc595dde23e7835f57d9176bade336ac01a350f408e713c52"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.2.1/CrispWebRTC_2.2.1.zip",
      checksum: "b5f67504a9000bc1a6c38f33bc562fbc8e8526924a5032e886fd11c65cfe2f3f"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.2.1/WebRTC_2.2.1.zip",
      checksum: "3eb12a52611fe234da3952c528d3e1f4b94c212da40121ef235f4ce9fd768def"
    ),
  ]
)
