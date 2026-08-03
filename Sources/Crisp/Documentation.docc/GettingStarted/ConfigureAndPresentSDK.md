# Configure SDK and present the Chat

Complete these final steps to get started

After you've integrated the SDK into your project and configured the required Info.plist keys, 
you're now ready to configure the SDK with your Website ID and present the 
``ChatView`` (SwiftUI) or ``ChatViewController`` (UIKit).

### Configure the Crisp iOS SDK

Go to your Crisp Dashboard, and copy your Website ID:

![Copy your Website ID](copy-website-id)

In your `AppDelegate` or `SceneDelegate` configure the Website ID in the SDK code:

```swift
import Crisp

CrispSDK.configure(websiteID: "YOUR_WEBSITE_ID")
```
![Configure CrispSDK](configure-sdk)

See ``CrispSDK/configure(websiteID:)``

### Present the ChatView

In SwiftUI, present ``ChatView`` — for example from a sheet:

```swift
import Crisp
import SwiftUI

struct ContentView: View {
    @State private var isChatPresented = false

    var body: some View {
        Button("Show chat") {
            self.isChatPresented = true
        }
        .sheet(isPresented: self.$isChatPresented) {
            ChatView()
        }
    }
}
```

In UIKit, present a ``ChatViewController``:

```swift
import Crisp

class ViewController: UIViewController {
    @IBAction func startChat(_ sender: Any) {
        self.present(ChatViewController(), animated: true)
    }
}
```

See ``ChatView`` and ``ChatViewController``.

![Present ChatViewController](present-viewcontroller)

