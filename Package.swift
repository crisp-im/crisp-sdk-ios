// swift-tools-version:5.7
import PackageDescription

let package = Package(
  name: "Crisp",
  platforms: [.iOS(.v13)],
  products: [
    .library(name: "Crisp", targets: ["CrispTarget"]),
    .library(name: "CrispWebRTC", targets: ["CrispWebRTCTarget"])
  ],
  targets: [
    .target(
      name: "CrispTarget",
      dependencies: [
        .target(name: "Crisp")
      ]
    ),
    .target(
      name: "CrispWebRTCTarget",
      dependencies: [
        .target(name: "CrispWebRTC"),
        .target(name: "WebRTC")
      ]
    ),
    .binaryTarget(
      name: "Crisp",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.4.6/Crisp_2.4.6.zip",
      checksum: "55bfeae29f865d80700648114e29be1c69f7b22578c5854118d095bc73165af4"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.4.6/CrispWebRTC_2.4.6.zip",
      checksum: "6aafe5304f8a4e80299a51ef72ff7a7770c0c453ed2550636d768b393070f72f"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.4.6/WebRTC_2.4.6.zip",
      checksum: "53e4fd3faee1ba44b091c4a67130ca47c0b8eaf5f8aeccd9bc6e3543de8bff54"
    ),
  ]
)
