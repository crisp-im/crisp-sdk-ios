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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.6.3/Crisp_1.6.3.zip",
      checksum: "4f8dc1c16f3f36dd265d6d115c88815aacffe6de3c9e0de88934a12ed9f366c7"
    )
  ]
)
