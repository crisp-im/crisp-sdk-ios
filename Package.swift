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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.2.0-beta.2/Crisp_1.2.0-beta.2.zip",
      checksum: "e5a41ea4e131a27f735d4ecb8509ff506d6e9db0fc29c74f8a1d65bc53838368"
    )
  ]
)
