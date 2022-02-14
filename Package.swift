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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.2.0/Crisp_1.2.0.zip",
      checksum: "feed92edc96c0303a1f5b4fdcd4b73df01db437674b1be2ded5e375d54bf8f7a"
    )
  ]
)
