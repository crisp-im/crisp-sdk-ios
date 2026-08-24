# Configure your project

Add the required Info.plist keys

> Important: Both keys below are **required**. The chat lets your users take photos, record voice messages and start audio and video calls. iOS would terminate your app the moment it accesses the camera or the microphone without a usage description.

Add the "Privacy - Camera Usage Description" ([NSCameraUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nscamerausagedescription)) to your app's Info.plist. It is needed for your users to take and upload photos to the chat, and to make video calls.

Add the "Privacy - Microphone Usage Description" ([NSMicrophoneUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nsmicrophoneusagedescription)) to your app's Info.plist. It is needed for your users to record voice messages, and to make audio and video calls.

Both values are shown to your users in the system permission prompt, so describe what your app uses the camera and the microphone for, for example "Take photos and make video calls in the support chat".

See also: [Technical Q&A QA1937](https://developer.apple.com/library/archive/qa/qa1937/_index.html)

![Update Info.plist](update-info-plist.png)
