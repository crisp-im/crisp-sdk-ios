![Crisp](./.github/logo.png)

Chat with app users, integrate your favorite tools, and deliver a great customer experience.

# Crisp iOS SDK

<img src="./.github/screenshot.png" width="375" alt="Crisp screenshot">

[![CocoaPods](https://img.shields.io/cocoapods/v/Crisp.svg)](https://cocoapods.org/?q=crisp)
[![Twitter](https://img.shields.io/badge/twitter-@crisp_im-blue.svg?style=flat)](http://twitter.com/crisp_im)

## How to use

### 1. Install Crisp iOS SDK

#### Option 1: Using [CocoaPods](http://cocoapods.org)

Add Crisp to your Podfile:

```ruby
use_frameworks!

target :YourTargetName do
  pod 'Crisp'
end
```

Then run  `pod install`

#### Option 2: Manual installation

1. Download and extract the [Crisp iOS SDK](https://github.com/crisp-im/crisp-sdk-ios/releases).
2. Drag the `Crisp.xcframework` into your project, select `Copy items if needed` in the following dialog and click `Finish`.

<img src="./.github/manual_install_1.png" width="443" alt="Drag framework to project">
<img src="./.github/manual_install_2.png" width="698" alt="Copy items if needed">

3. Finally, configure the `Crisp.xcframework` to `Embed & Sign` in the `Frameworks, Libraries, and Embedded Content` section of your app's target settings.

<img src="./.github/manual_install_3.png" width="698" alt="Embed and Sign">

### 2. Update your Info.plist

To enable your users to take and upload photos to the chat as well as download photos to their photo library, add the 
`Privacy - Camera Usage Description` ([NSCameraUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nscamerausagedescription)) and `Privacy - Photo Library Additions Usage Description` ([NSPhotoLibraryAddUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nsphotolibraryaddusagedescription)) to your app's Info.plist.

<img src="./.github/update_info_plist.png" width="900" alt="Update Info.plist">

### 3. Configure the Crisp iOS SDK

Go to your Crisp dashboard (https://app.crisp.chat), copy your website id from the resulting URL and configure the `CrispSDK` in your app's `AppDelegate`.

<img src="./.github/copy_website_id.png" width="583" alt="Copy website id">

<img src="./.github/configure_sdk.png" width="900" alt="Configure CrispSDK">

### 4. Present the `ChatViewController`

<img src="./.github/present_viewcontroller.png" width="900" alt="Present ChatViewController">

## Credits

Crisp iOS SDk is owned and maintained by [Crisp IM, SARL](https://crisp.chat/en/). You can chat with us on [crisp](https://crisp.chat) or follow us on Twitter at [Crisp_im](http://twitter.com/crisp_im)

## License

Crisp iOS SDk is under Copyright license. see [LICENSE](https://raw.githubusercontent.com/crisp-im/crisp-sdk-ios/master/LICENSE) for more details.
