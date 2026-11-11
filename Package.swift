// swift-tools-version:6.1

import PackageDescription

let package = Package(
  name: "crisp-sdk-ios",
  defaultLocalization: "en",
  platforms: [.iOS(.v14), .macCatalyst(.v14)],
  products: [
    .library(name: "Crisp", targets: ["Crisp"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/crisp-im/crisp-utils-ios.git",
      .upToNextMajor(from: "1.0.0"),
    ),
  ],
  targets: [
    .target(
      name: "Crisp",
      dependencies: ["CrispChatBox"],
    ),
    .target(
      name: "CrispChatBox",
      dependencies: [
        "CrispChatBoxFFI",
        .product(name: "CrispDomain", package: "crisp-utils-ios"),
        .product(name: "CrispLogging", package: "crisp-utils-ios"),
        .product(name: "CrispUtils", package: "crisp-utils-ios"),
      ],
      resources: [.process("Assets/Localizable.xcstrings")],
    ),
    .target(
      name: "CrispChatBoxFFI",
      dependencies: [
        "CrispClient",
        .product(name: "CrispDomain", package: "crisp-utils-ios"),
        .product(name: "CrispLogging", package: "crisp-utils-ios"),
        .product(name: "CrispUtils", package: "crisp-utils-ios"),
      ],
      resources: [.copy("index.html")],
    ),
    // mise:crisp-client-target:begin
    .binaryTarget(
      name: "CrispClient",
      url: "https://github.com/crisp-im/crisp-sdk-ios/releases/download/3.1.1/CrispClient.xcframework.zip",
      checksum: "cbf88f62ef0e62e415c1976497e3734d3ae8838d06829b3f68755b5cf115df5c",
    ),
    // mise:crisp-client-target:end

    .testTarget(
      name: "CrispChatBoxFFITests",
      dependencies: ["CrispChatBoxFFI", "TestMocks"],
    ),
    .testTarget(
      name: "CrispChatBoxTests",
      dependencies: ["CrispChatBox", "TestMocks"],
    ),
    .target(
      name: "TestMocks",
      dependencies: ["CrispChatBoxFFI"],
      path: "Tests/TestMocks",
    ),
  ],
  swiftLanguageModes: [.v6],
)
