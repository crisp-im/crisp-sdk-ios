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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.6.4/Crisp_1.6.4.zip",
      checksum: "389f9afcac376de0c48f2c31964d23d24a5aa4358b2e633c6eeb1abdf2cbdd81"
    )
  ]
)
