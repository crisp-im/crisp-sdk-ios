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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.3.2/Crisp_1.3.2.zip",
      checksum: "1f995236628463baa8f6340cdce931aa8868922e3bf1930f5812370115e1673d"
    )
  ]
)
