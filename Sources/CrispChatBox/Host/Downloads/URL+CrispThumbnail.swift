import Foundation

extension URL {
  // swiftlint:disable:next force_unwrapping
  static let crisp_imageHost = URL(string: "https://image.crisp.chat")!

  /// Constructs a URL that loads the receiver's destination through the Crisp image service and
  /// processes it as a thumbnail. "Thumbnail processing" basically guarantees that the input image
  /// fills the output image's bounds. You can think of it as `scaleAspectFill`. If the input image
  /// is smaller than the desired output image size, it will be scaled up.
  ///
  /// - Parameter size: The desired size for the output image.
  ///
  /// - Returns: The URL to load and process an image through the Crisp image service.
  func crisp_thumbnailURL(size: CGSize, screenScale: CGFloat) -> URL? {
    guard self.host != URL.crisp_imageHost.host else {
      return self
    }

    var comps = URLComponents(
      url: URL.crisp_imageHost.appendingPathComponent("/process/thumbnail"),
      resolvingAgainstBaseURL: true,
    )
    comps?.queryItems = [
      .init(name: "url", value: self.absoluteString),
      .init(name: "width", value: String(Int(size.width * screenScale))),
      .init(name: "height", value: String(Int(size.height * screenScale))),
    ]
    return comps?.url
  }
}
