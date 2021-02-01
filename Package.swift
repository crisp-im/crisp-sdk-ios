// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "Crisp",
  products: [
    .library(name: "Crisp", targets: ["Crisp"])
  ],
  targets: [
    .binaryTarget(
      name: "Crisp",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.0.9/Crisp_1.0.9.zip",
      checksum: "e0024cf0fe879d5654c8a6029515432e7588a217d5edf9e84b37571d333ab115"
    )
  ]
)
