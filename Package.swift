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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.6.0/Crisp_1.6.0.zip",
      checksum: "7b253d2bb68d81de4f680cf4ab22ec29676c6d1787c093b08df05b71777b004f"
    )
  ]
)
