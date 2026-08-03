import LinkPresentation
import UIKit
import UniformTypeIdentifiers

extension LPLinkMetadata {
  convenience init(
    url: URL,
    title: String? = nil,
    image: UIImage? = nil,
    imageURL: URL? = nil,
  ) {
    self.init()
    self.originalURL = url
    self.url = url

    if let title {
      self.title = title
    }

    let type = UTType(filenameExtension: url.pathExtension) ?? .image

    if let image {
      self.iconProvider = NSItemProvider(object: image)
    } else if let imageURL, type.conforms(to: .image) {
      self.iconProvider = makeRemoteImageProvider(url: imageURL, type: type)
    }
  }
}

private func makeRemoteImageProvider(url: URL, type: UTType) -> NSItemProvider {
  let provider = NSItemProvider()
  let typeIdentifier = type.identifier

  provider.registerDataRepresentation(
    forTypeIdentifier: typeIdentifier,
    visibility: .all,
  ) { completion -> Progress? in
    let progress = Progress(totalUnitCount: 1)
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
      defer { progress.completedUnitCount = 1 }
      if let data {
        completion(data, nil)
      } else {
        completion(nil, error ?? URLError(.badServerResponse))
      }
    }
    progress.cancellationHandler = { [weak task] in task?.cancel() }
    task.resume()
    return progress
  }

  return provider
}
