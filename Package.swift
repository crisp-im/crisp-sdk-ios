// swift-tools-version:5.7
import PackageDescription

let package = Package(
  name: "Crisp",
  platforms: [.iOS(.v13)],
  products: [
    .library(name: "Crisp", targets: ["Crisp"])
  ],
  targets: [
    .binaryTarget(
      name: "Crisp",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.0.0-beta.20/Crisp_2.0.0-beta.20.zip",
      checksum: "abbe9e4884bc9e2a62455d226a59755a3bdcb8f688b085a428496cf6202df5c5"
    )
  ]
)
