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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.4.0/Crisp_1.4.0.zip",
      checksum: "c687256c11854077968b569ae03e73bcb87cb0b1da26eb32e2c024c5a7dbdb72"
    )
  ]
)
