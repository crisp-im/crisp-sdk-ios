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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.2.0-beta.1/Crisp_1.2.0-beta.1.zip",
      checksum: "96a03813cb986d1d5678ca3b3a247bb46ca8d0072bc75910d8c145cbfb1e03bc"
    )
  ]
)
