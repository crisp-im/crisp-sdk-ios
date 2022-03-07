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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.3.0/Crisp_1.3.0.zip",
      checksum: "2e7b49b52160dd6ef53545180112f5bd47fd361b28f62b6a6701faa16db9735f"
    )
  ]
)
