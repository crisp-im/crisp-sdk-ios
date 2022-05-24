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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.5.3/Crisp_1.5.3.zip",
      checksum: "9c920abfbc8e29b1f7d04cb701df1f0745db6f659c770f3fa570f9d5e86bf1b0"
    )
  ]
)
