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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.2.0/Crisp_2.2.0.zip",
      checksum: "d5a6a380facc17135fce3d32cada87e24e8995170b917f7594bde713c648a47a"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.2.0/CrispWebRTC_2.2.0.zip",
      checksum: "921fa3602c8c8bea977f64dc9f19cb94f118b27824688b790e416fe5da990ff2"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.2.0/WebRTC_2.2.0.zip",
      checksum: "88de6a3fcc2f930ffddc3e1786f24ff40ebbf83c0c478d2ed1d0bf25fe9670ec"
    ),
  ]
)
