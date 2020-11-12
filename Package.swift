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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.0.5/Crisp_1.0.5.zip",
      checksum: "63f23b6f97682a1f0fe6db09034f018a506d8e3d2610286598a4d419aa4eeb02"
    )
  ]
)