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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.5.2/Crisp_1.5.2.zip",
      checksum: "f8c11c83d41a7a7eb224e4801bff4b2a6d3569a7382867d70a1e2b08a3dfd293"
    )
  ]
)
