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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.3.2/Crisp_1.3.2.zip",
      checksum: "02bae47d1a03204665b4604fa9e385870b33a3ac0f7ed4693ee8b2b26f9e1537"
    )
  ]
)
