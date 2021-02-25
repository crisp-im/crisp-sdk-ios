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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.0.12/Crisp_1.0.12.zip",
      checksum: "1166ca05cf965677798b731da51a47164db070ae0ee1e42e5713ab024dc9f05a"
    )
  ]
)
