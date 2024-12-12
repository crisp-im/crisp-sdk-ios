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
      url: "https://github.com/nesium/crisp-sdk-ios/releases/download/2.8.1/Crisp_2.8.1.zip",
      checksum: "ce50979133746ff7f6084040ed2ca94fcbd9e805f39c824666b69947c9a96b03"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/nesium/crisp-sdk-ios/releases/download/2.8.1/CrispWebRTC_2.8.1.zip",
      checksum: "9fbb102b80d78936d71aac7b48c4f740a2de69d84bf3ea073635a0242f0bb8ab"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/nesium/crisp-sdk-ios/releases/download/2.8.1/WebRTC_2.8.1.zip",
      checksum: "8de8c1473122e973e6dbe6e246ad5b812d54ed6f83876e9ce4b2f14218c93fb8"
    ),
  ]
)
