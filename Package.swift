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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.6.1/Crisp_1.6.1.zip",
      checksum: "e760818a8431f7279b8d8fbf19bf5318fa49afe78e149629c50b6e67b271088f"
    )
  ]
)
