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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.5.5/Crisp_2.5.5.zip",
      checksum: "c58134721332a264ab73a1683a656be2defede191ba74c3639667e0c1edef72c"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.5.5/CrispWebRTC_2.5.5.zip",
      checksum: "cc8393599ab968f65b6ad3e6984c2dafd6ad7cb2c67d393522d38eb7ef0ee4c9"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.5.5/WebRTC_2.5.5.zip",
      checksum: "7c9214e39d1e6335b984aeb399aa2491218649aed30e7c96e18180ab8b5ff4fa"
    ),
  ]
)
