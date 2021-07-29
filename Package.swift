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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.0.15/Crisp_1.0.15.zip",
      checksum: "c91df2c99aaf6b429c319163c74ea0cb4f3a2fc6b08d4511fd02405d0d52a59b"
    )
  ]
)
