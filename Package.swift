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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.6.2/Crisp_1.6.2.zip",
      checksum: "c3964e30b2c37839a96ff429fca5b17759d78cf0dcdbc61a0ae0c55c908050e1"
    )
  ]
)
