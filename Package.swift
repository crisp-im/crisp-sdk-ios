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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.7.0/Crisp_2.7.0.zip",
      checksum: "4a05ecf0a69d76a31bd5b09af0d070afa5234d20a09d66eb46b4b7f88035d9d6"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.7.0/CrispWebRTC_2.7.0.zip",
      checksum: "c965fc1bea369ca33c4500dbea321a6ffabc4d4377b2b552cc5307cdf1eec6a3"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.7.0/WebRTC_2.7.0.zip",
      checksum: "c1cfc5d2606d6f234d98dcae07523683e03ce1f2430016cb7d33871ac80df5df"
    ),
  ]
)
