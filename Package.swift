// swift-tools-version:6.1

import PackageDescription

let package = Package(
  name: "crisp-sdk-ios",
  defaultLocalization: "en",
  platforms: [.iOS(.v14), .macOS(.v11), .macCatalyst(.v14)],
  products: [
    .library(name: "Crisp", type: .dynamic, targets: ["Crisp"]),
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
    .target(
      name: "CrispClient",
      path: "Sources/CrispClient",
      resources: [.copy("dist")],
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
