# Configure your project

Add required Info.plist Keys

To enable your users to take and upload photos to the chat add the "Privacy - Camera Usage Description"  ([NSCameraUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nscamerausagedescription)) to your 
app's Info.plist.

If you want to make audio or video calls with your users you'll also need the "Privacy - Microphone Usage Description"  ([NSMicrophoneUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nsmicrophoneusagedescription)). 

See also: [Technical Q&A QA1937](https://developer.apple.com/library/archive/qa/qa1937/_index.html)

![Update Info.plist](update-info-plist.png)
