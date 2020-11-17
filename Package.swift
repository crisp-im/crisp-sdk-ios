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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.0.6/Crisp_1.0.6.zip",
      checksum: "f9ef9f40cd74f92713ed7721c1c52370fe52be321da8068788163b04aafe4329"
    )
  ]
)
