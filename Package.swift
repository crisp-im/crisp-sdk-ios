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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.5.1/Crisp_1.5.1.zip",
      checksum: "49565b2337d02a9723cf441a7d5798ebfeb210de927b4423d992baea1088ee96"
    )
  ]
)
