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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.0.11/Crisp_1.0.11.zip",
      checksum: "9a4dc72a47ed2df871b0b9caa90c8d7bbb55d21c320734693263f6ac86b3039b"
    )
  ]
)
