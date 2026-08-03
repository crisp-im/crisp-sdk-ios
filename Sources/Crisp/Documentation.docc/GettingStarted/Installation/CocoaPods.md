# CocoaPods (Deprecated)

Integrate Crisp SDK via CocoaPods

- Warning: We will stop publishing to CocoaPods at the end of September 2026. We recommend migrating to <doc:SwiftPM> or manually installing the [pre-built XCFramework from GitHub releases](https://github.com/crisp-im/crisp-sdk-ios/releases/latest). 

To integrate the Crisp SDK into your project add `Crisp` to your Podfile:

```ruby
use_frameworks!

target :YourTargetName do
  pod 'Crisp'
end
```

Then run the following command from your terminal:
 
```sh
$ pod install
```
