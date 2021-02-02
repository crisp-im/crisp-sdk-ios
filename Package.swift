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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.0.10/Crisp_1.0.10.zip",
      checksum: "eb58afafed05b2d81772cd84245f30af33ef0863cf4491dd8c94a61dfe3643f0"
    )
  ]
)
