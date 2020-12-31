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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.0.8/Crisp_1.0.8.zip",
      checksum: "8d115fcd4adfacfc794a82b0572d1d722d5ab683730d1962292af0ba59a3443e"
    )
  ]
)
