// swift-tools-version:5.7
import PackageDescription

let package = Package(
  name: "Crisp",
  platforms: [.iOS(.v13)],
  products: [
    .library(name: "Crisp", targets: ["Crisp"])
  ],
  targets: [
    .binaryTarget(
      name: "Crisp",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.0.0-beta.19/Crisp_2.0.0-beta.19.zip",
      checksum: "bf7aeab6fa56c8c11dc0be58a4d16d97fda1e51c2d3721635afb78d0277819b0"
    )
  ]
)
