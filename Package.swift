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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.0.7/Crisp_1.0.7.zip",
      checksum: "8276a3532fad55ec683f59d81129bdcc665207522c5104536e7909e9f0e78940"
    )
  ]
)
