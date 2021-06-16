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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.0.14/Crisp_1.0.14.zip",
      checksum: "f793ffd3a73744c7ed6a0ac49e5469fa4442df735bea3ce754ff71c2298cc49f"
    )
  ]
)
