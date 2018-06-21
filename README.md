![Crisp](https://raw.githubusercontent.com/crisp-im/crisp-sdk-ios/master/docs/img/logo_blue.png)

Chat with app users, integrate your favorite tools, and deliver a great customer experience.

# Crisp iOS SDK

![Crisp screenshot](https://raw.githubusercontent.com/crisp-im/crisp-sdk-ios/master/docs/img/crisp_screenshot.jpg)

[![CocoaPods](https://img.shields.io/cocoapods/v/Crisp.svg)](https://cocoapods.org/?q=crisp)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Twitter](https://img.shields.io/badge/twitter-@crisp_im-blue.svg?style=flat)](http://twitter.com/crisp_im)


## Installation

### Cocoapods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate Crisp into your Xcode project using CocoaPods, specify it in your Podfile:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'Crisp'
end
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Crisp into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "crisp-im/crisp-sdk-ios"
```

Run `carthage update` to build the framework and drag the built `Crisp.framework` into your Xcode project.


## Requirements

⚠️ Adding Camera and Photo permissions is mandatory, `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` in  `Info.plist`, to inform your users that you need to access to the Camera and Photo Library. You also have to enable **"iCloud Documents"** capability

## Get your website ID

Your website ID can be found in the Crisp App URL:

- https://app.crisp.chat/website/[WEBISTE_ID]/inbox/

Crisp Website ID is an UUID like e30a04ee-f81c-4935-b8d8-5fa55831b1c0


## Usage

Start using Crisp by adding the following code on your AppDelegate :

```Swift
import Crisp
Crisp.initialize(websiteId: "YOUR_WEBSITE_ID")
```

### Chatbox

You can add the Crisp bubble by adding in your view `CrispView()` :

```Swift
import UIKit
import Crisp

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let crispView = CrispView()
        crispView.bounds = view.bounds
        crispView.center = view.center

        view.addSubview(crispView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

```

## Availables APIs:

* `Crisp.user.set(email: "john.doe@gmail.com");`
* `Crisp.user.set(nickname: "John Doe");`
* `Crisp.user.set(phone: "003370123456789");`
* `Crisp.user.set(avatar: "https://pbs.twimg.com/profile_images/782474226020200448/zDo-gAo0_400x400.jpg");`
* `Crisp.session.set(data: ["key" : "value"]);`
* `Crisp.session.set(segment: "segment");`
* `Crisp.session.set(segments: ["segment1", "segment2"]);`
* `Crisp.session.reset();`

## Credits

Crisp iOS SDk is owned and maintained by [Crisp IM, SARL](https://crisp.chat/en/). You can chat with us on [crisp](https://crisp.chat) or follow us on Twitter at [Crisp_im](http://twitter.com/crisp_im)

## License

Crisp iOS SDk is under Copyright license. see [LICENSE](https://raw.githubusercontent.com/crisp-im/crisp-sdk-ios/master/LICENSE) for more details.
