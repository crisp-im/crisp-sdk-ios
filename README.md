![Crisp](https://raw.githubusercontent.com/crisp-im/crisp-sdk-ios/master/docs/img/logo_blue.png)

Chat with app users, integrate your favorite tools, and deliver a great customer experience.

# Crisp iOS SDK

![Crisp screenshot](https://raw.githubusercontent.com/crisp-im/crisp-sdk-ios/master/docs/img/crisp_screenshot.png)

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

**Ensure you embed binaries**

![Embed binaries](https://raw.githubusercontent.com/crisp-im/crisp-sdk-ios/master/docs/img/embed.jpg)


## Requirements

⚠️ Adding Camera and Photo permissions is mandatory, `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` in  `Info.plist`, to inform your users that you need to access to the Camera and Photo Library. You also have to enable **"iCloud Documents"** capability

## Get your website ID

Your website ID can be found in the Crisp App URL:

- https://app.crisp.chat/website/[WEBISTE_ID]/inbox/

Crisp Website ID is an UUID like e30a04ee-f81c-4935-b8d8-5fa55831b1c0


## Usage (Swift)

Start using Crisp by adding the following code on your AppDelegate :

```Swift
import Crisp
Crisp.initialize(websiteId: "YOUR_WEBSITE_ID")
```

You can add the Crisp view by adding in your view `CrispView()` :

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


## Usage (Objective C)

Start using Crisp by adding the following code on your AppDelegate :


```objective-c
#import "Crisp-Swift.h"

[[CrispMain alloc] initializeWithWebsiteId:@"YOUR_WEBSITE_ID"];
```

You can add the Crisp view by adding in your view `CrispView()` :

```objective-c
#import "Crisp-Swift.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CrispView *crispView = [[CrispView alloc] init];
    crispView.bounds = self.view.bounds;
    crispView.center = self.view.center;
    
    [self.view addSubview:crispView];
}

```

## API Usage (Swift):

* `Crisp.tokenId = "XXXX"` sets your own token_id
* `Crisp.locale = "it"` Overrides the Crisp locale with a custom one
* `Crisp.user.set(email: "john.doe@gmail.com");`
* `Crisp.user.set(nickname: "John Doe");`
* `Crisp.user.set(phone: "003370123456789");`
* `Crisp.user.set(avatar: "https://pbs.twimg.com/profile_images/782474226020200448/zDo-gAo0_400x400.jpg");`
* `Crisp.session.set(data: ["key" : "value"]);`
* `Crisp.session.set(segment: "segment");`
* `Crisp.session.set(segments: ["segment1", "segment2"]);`
* `Crisp.session.pushEvent(name: "signup", ["key" : "value"], "blue");`
* `Crisp.session.reset();`

## API Usage (Objective C ):

```
UserInterface *user = [[UserInterface alloc] init];
[user setWithEmail:@"user@gmail.com"];
[user setWithNickname:@"John Doe"];
[user setWithPhone:@"003370123456789"];
[user setWithAvatar:@"https://pbs.twimg.com/profile_images/782474226020200448/zDo-gAo0_400x400.jpg"];

SessionInterface *session = [[SessionInterface alloc] init];

NSMutableDictionary *dict = [NSMutableDictionary dictionary];
[dict setObject: @"Value"  forKey: @"Key"];

[session setWithData:dict];
[session setWithSegment:@"segment"];
    
```

## Credits

Crisp iOS SDk is owned and maintained by [Crisp IM, SARL](https://crisp.chat/en/). You can chat with us on [crisp](https://crisp.chat) or follow us on Twitter at [Crisp_im](http://twitter.com/crisp_im)

## License

Crisp iOS SDk is under Copyright license. see [LICENSE](https://raw.githubusercontent.com/crisp-im/crisp-sdk-ios/master/LICENSE) for more details.
