import LinkPresentation
import UIKit

// swiftlint:disable:next no_unchecked_sendable
final class AsyncFileActivityItemProvider: UIActivityItemProvider, @unchecked Sendable {
  typealias StartHandler = @MainActor () -> Void
  typealias ProgressHandler = @MainActor (Double) -> Void

  private let remoteURL: URL
  private let previewTitle: String?
  private let previewImageURL: URL?

  private let onStart: StartHandler
  private let onProgress: ProgressHandler

  private(set) var downloadError: (any Error)?

  private var downloadTask: URLSessionDownloadTask?
  private let semaphore = DispatchSemaphore(value: 0)
  private var localURL: URL?

  init(
    remoteURL: URL,
    previewTitle: String? = nil,
    previewImageURL: URL? = nil,
    onStart: @escaping StartHandler,
    onProgress: @escaping ProgressHandler,
  ) {
    self.remoteURL = remoteURL
    self.previewTitle = previewTitle
    self.previewImageURL = previewImageURL
    self.onStart = onStart
    self.onProgress = onProgress

    let placeholderURL = URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent("placeholder")
      .appendingPathExtension(remoteURL.pathExtension)

    super.init(placeholderItem: placeholderURL)
  }

  override var item: Any {
    if isCancelled {
      return placeholderItem ?? self.remoteURL
    }

    DispatchQueue.main.async { [onStart] in onStart() }

    let delegate = DownloadDelegate(
      onProgress: { [weak self] fraction in
        guard let self else { return }
        DispatchQueue.main.async { self.onProgress(fraction) }
      },
      onFinish: { [weak self] result in
        guard let self else { return }

        switch result {
        case let .success(tempURL):
          do {
            let localURL = Self.buildTemporaryLocalURL(for: self.remoteURL)

            try? FileManager.default.removeItem(at: localURL)
            try FileManager.default.moveItem(at: tempURL, to: localURL)

            self.localURL = localURL
          } catch {
            self.downloadError = error
          }

        case let .failure(error):
          self.downloadError = error
        }

        self.semaphore.signal()
      },
    )

    let session = URLSession(
      configuration: .default,
      delegate: delegate,
      delegateQueue: nil,
    )

    let task = session.downloadTask(with: self.remoteURL)
    self.downloadTask = task
    task.resume()

    while self.semaphore.wait(timeout: .now() + 1.0) == .timedOut {
      if isCancelled {
        task.cancel()
      }
    }
    session.finishTasksAndInvalidate()

    if isCancelled {
      return placeholderItem ?? self.remoteURL
    }

    DispatchQueue.main.async { [onProgress] in onProgress(1.0) }
    return self.localURL ?? self.remoteURL
  }

  override func activityViewControllerLinkMetadata(
    _: UIActivityViewController,
  ) -> LPLinkMetadata? {
    LPLinkMetadata(
      url: self.remoteURL,
      title: self.previewTitle,
      imageURL: self.previewImageURL,
    )
  }
}

private extension AsyncFileActivityItemProvider {
  private static func buildTemporaryLocalURL(for remoteURL: URL) -> URL {
    let ext = remoteURL.pathExtension.isEmpty ? "tmp" : remoteURL.pathExtension
    let name = remoteURL.deletingPathExtension().lastPathComponent
    let safeName = name.isEmpty ? "download" : name
    let unique = "\(safeName)-\(UUID().uuidString).\(ext)"
    return FileManager.default.temporaryDirectory.appendingPathComponent(unique)
  }
}

private final class DownloadDelegate: NSObject, URLSessionDownloadDelegate {
  private let onProgress: @Sendable (Double) -> Void
  private let onFinish: @Sendable (Result<URL, any Error>) -> Void

  init(
    onProgress: @escaping @Sendable (Double) -> Void,
    onFinish: @escaping @Sendable (Result<URL, any Error>) -> Void,
  ) {
    self.onProgress = onProgress
    self.onFinish = onFinish
  }

  func urlSession(
    _: URLSession,
    downloadTask _: URLSessionDownloadTask,
    didWriteData _: Int64,
    totalBytesWritten: Int64,
    totalBytesExpectedToWrite: Int64,
  ) {
    guard totalBytesExpectedToWrite > 0 else { return }
    let fraction = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
    self.onProgress(min(max(fraction, 0), 1))
  }

  func urlSession(
    _: URLSession,
    downloadTask _: URLSessionDownloadTask,
    didFinishDownloadingTo location: URL,
  ) {
    self.onFinish(.success(location))
  }

  func urlSession(
    _: URLSession,
    task _: URLSessionTask,
    didCompleteWithError error: (any Error)?,
  ) {
    guard let error else {
      // Success was already reported via didFinishDownloadingTo.
      return
    }
    self.onFinish(.failure(error))
  }
}
