# Swift Package Manager

Integrate Crisp SDK via SPM (recommended)

To integrate the Crisp SDK into your project, add it to the dependencies of your 
Package.swift and specify the `Crisp` product in all targets that will use the library:

```swift
let package = Package(
  dependencies: [
    .package(url: "https://github.com/crisp-im/crisp-sdk-ios.git", .upToNextMajor(from: "3.0.0")),
  ],
  targets: [
    .target(
      name: "<target-name>",
      dependencies: [
        .productItem(name: "Crisp", package: "crisp-sdk-ios")
      ]
    )
  ]
)
```
