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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.3.1/Crisp_1.3.1.zip",
      checksum: "dd618a5981b90d8ad701e3abd3745b6410172f8dfcf261ee64537886a6444f6c"
    )
  ]
)
