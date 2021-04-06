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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.0.13/Crisp_1.0.13.zip",
      checksum: "c98a9de498ae29d2e043b32c00a24497efd341f9ca4694c4fbcbab908c2bc6a4"
    )
  ]
)
