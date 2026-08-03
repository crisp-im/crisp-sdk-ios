// swift-tools-version:6.1

import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "codegen",
  platforms: [.macOS(.v13)],
  products: [
    .library(name: "ChatBoxFFI-Source", targets: ["ChatBoxFFI-Source"]),
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-syntax", "509.0.0" ..< "605.0.0"),
    .package(url: "https://github.com/crisp-im/crisp-utils-ios.git", branch: "master"),
  ],
  targets: [
    .target(
      name: "ChatBoxFFI-Source",
      dependencies: [
        "ChatBoxJSMacros",
        .product(name: "CrispDomain", package: "crisp-utils-ios"),
        .product(name: "CrispLogging", package: "crisp-utils-ios"),
        .product(name: "CrispUtils", package: "crisp-utils-ios"),
      ],
      path: "Sources/CrispChatBoxFFI",
    ),
    .macro(
      name: "ChatBoxJSMacros",
      dependencies: [
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        .product(name: "SwiftSyntax", package: "swift-syntax"),
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftDiagnostics", package: "swift-syntax"),
      ],
    ),
    .executableTarget(
      name: "MacroExpander",
      dependencies: [
        .product(name: "SwiftSyntax", package: "swift-syntax"),
        .product(name: "SwiftParser", package: "swift-syntax"),
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftSyntaxMacroExpansion", package: "swift-syntax"),
        .product(name: "SwiftDiagnostics", package: "swift-syntax"),
      ],
    ),
    .testTarget(
      name: "ChatBoxJSMacrosTests",
      dependencies: [
        "ChatBoxJSMacros",
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
      ],
    ),
  ],
)
