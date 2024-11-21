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
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.8.0/Crisp_2.8.0.zip",
      checksum: "28e5bd7501caeab44b57385c9b9fefa3b494ffedbc1b8e92a19269e194e24870"
    ),
    .binaryTarget(
      name: "CrispWebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.8.0/CrispWebRTC_2.8.0.zip",
      checksum: "462899d74812925363964f748a4576bafbd2373371929d6b797a94e0ee59de83"
    ),
    .binaryTarget(
      name: "WebRTC",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/2.8.0/WebRTC_2.8.0.zip",
      checksum: "d568085f892c92d7934ff636d255daf72e5285007f4d45c24ef4b20e01decdc6"
    ),
  ]
)
