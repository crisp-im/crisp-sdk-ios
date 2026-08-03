// Polyfill for Bundle.module when package is consumed with CocoaPods
#if !SWIFT_PACKAGE
  import Foundation

  private final class BundleToken {}

  extension Foundation.Bundle {
    static let module: Bundle = {
      let bundleName = "CrispChatBoxFFI"
      let candidates = [
        Bundle.main.resourceURL,
        Bundle(for: BundleToken.self).resourceURL,
        Bundle.main.bundleURL,
      ]
      for candidate in candidates {
        if let url = candidate?.appendingPathComponent(bundleName + ".bundle"),
           let bundle = Bundle(url: url)
        {
          return bundle
        }
      }
      return Bundle(for: BundleToken.self)
    }()
  }
#endif
