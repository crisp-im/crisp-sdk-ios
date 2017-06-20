# Crisp iOS SDK

## Installation


### Cocoapods (!) Not yet ready

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
github "socketio/socket.io-client-swift" ~> 8.3.3
github "SnapKit/SnapKit" ~> 3.2.0
github "Hearst-DD/ObjectMapper" ~> 2.2
github "ReactiveX/RxSwift" ~> 3.0
github "teodorpatras/EasyTipView"
github "rs/SDWebImage"
github "cesarferreira/SwiftEventBus" == 2.2.0
github "Alamofire/Alamofire" ~> 4.4
github "hyperoslo/Lightbox"
github "ninjaprox/NVActivityIndicatorView"
github "Flipboard/FLAnimatedImage"
binary "https://raw.githubusercontent.com/crisp-im/crisp-sdk-ios/master/framework.json" ~> 1.0.11
```

Run `carthage update` to build the framework and drag all builds `Carthage/Build/iOS/*.framework` into your Xcode project. (*Embedded Binaries* + *Linked Frameworks and Libraries*)

### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate Crisp into your project manually.

- Download the crisp-ios-sdk repo on your computer

- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.

- In the tab bar at the top of that window, open the "General" panel.
 	
- Click on the + button under the "Embedded Binaries" section.

- Select the Crisp.framework downloaded

- In Build Settings tab, add a new path to Framework Search Paths: `$(PROJECT_DIR)/Crisp.framework/Frameworks`


## Usage

Start usign Crisp by adding on your AppDelegate : 

```Swift
import Crisp
Crisp.initialize(websiteId: "YOUR_WEBSITE_ID")
```

### Chatbox

You can add the crisp bubble bu adding on your view `CrispButton()` :

```Swift
import UIKit
import Crisp

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let crispButton = CrispButton()
        view.addSubview(crispButton)
        crispButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        crispButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

```

### Preferences

You can change the main color of crisp and texts :

#### Color 

```swift
Crisp.preference.setColor(.red)
Crisp.preference.setColor(def: .blue)
Crisp.preference.setColor(hex: "000000")
```

Enum `ThemeColors` :

- blue
- amber
- black
- blueGrey
- blueLight
- brown
- cyan
- green
- greenLight
- grey
- indigo
- orange
- orangeDeep
- pink
- purple
- purpleDeep
- red
- teal

#### Theme Texte

```Swift
Crisp.preference.setThemeText(.defaultChat)
Crisp.preference.setThemeText(string: "LOCALIZED_STRING")
```

Enum `ThemeText` :

- defaultChat
- oneChat
- twoChat
- threeChat
- fourChat

#### Theme Welcome 

```Swift
Crisp.preference.setThemeWelcome(.defaultChat)
Crisp.preference.setThemeWelcome(string: "LOCALIZED_STRING")
```

Enum `ThemeWelcome` :

- defaultChat
- oneChat
- twoChat
- threeChat
- fourChat
- fiveChat

### User

- Setters

``` Swift
Crisp.user.set(email: "quentin@crisp.im")
Crisp.user.set(avatar: "http://your.website.com/user_id/size")
Crisp.user.set(nickname: "Quentin de Quelen")
Crisp.user.set(phone: "+33645XXXXXX")
```

- Getters

```Swift
let email = Crisp.user.email
let avatar = Crisp.user.avatar
let nickname = Crisp.user.nickname
let phone = Crisp.user.phone
```

### Chatbox

Open the chatbox with :

```Swift
Crisp.chat.open()
```

Close the chatbox with :

```Swift
Crisp.chat.close()
```
