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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.1.0/Crisp_1.1.0.zip",
      checksum: "cdce593926dc1820cc38e7bb22c685e54a43122af38c15c18584cf886219e66b"
    )
  ]
)
