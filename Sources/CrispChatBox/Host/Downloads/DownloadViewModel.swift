import Foundation
import UIKit

@MainActor
package final class DownloadViewModel {
  let url: URL
  let onCancel: () -> Void
  let itemProvider: AsyncFileActivityItemProvider
  let origin: CGPoint

  var onStart: (() -> Void)?
  var onProgress: ((Double) -> Void)?

  init(url: URL, name: String, origin: CGPoint, onCancel: @escaping () -> Void) {
    self.url = url
    self.origin = origin
    self.onCancel = onCancel

    var _onStart: (() -> Void)?
    var _onProgress: ((Double) -> Void)?

    self.itemProvider = AsyncFileActivityItemProvider(
      remoteURL: url,
      previewTitle: name,
      previewImageURL: url.crisp_thumbnailURL(
        size: CGSize(width: 80, height: 80),
        screenScale: UIScreen.main.scale,
      ),
      onStart: { _onStart?() },
      onProgress: { _onProgress?($0) },
    )

    _onStart = { [weak self] in self?.onStart?() }
    _onProgress = { [weak self] in self?.onProgress?($0) }
  }
}
