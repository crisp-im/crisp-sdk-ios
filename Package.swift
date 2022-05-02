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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.5.0/Crisp_1.5.0.zip",
      checksum: "804ddc78ef38c6e0250cc1623b2b3b84f84af0268fe14eaabb9ba2628a71bc3e"
    )
  ]
)
