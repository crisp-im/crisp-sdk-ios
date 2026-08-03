import Foundation

/// An enum describing the current status of our user's internet connection.
package enum Connectivity {
  case online
  case offline
}

package struct LifecycleClient {
  package var applicationWillEnterForeground: @Sendable () -> AsyncStream<Void>
  package var applicationDidEnterBackground: @Sendable () -> AsyncStream<Void>
  package var connectivity: @Sendable () -> AsyncStream<Connectivity>

  package init(
    applicationWillEnterForeground: @Sendable @escaping () -> AsyncStream<Void>,
    applicationDidEnterBackground: @Sendable @escaping () -> AsyncStream<Void>,
    connectivity: @Sendable @escaping () -> AsyncStream<Connectivity>,
  ) {
    self.applicationWillEnterForeground = applicationWillEnterForeground
    self.applicationDidEnterBackground = applicationDidEnterBackground
    self.connectivity = connectivity
  }
}

package extension LifecycleClient {
  static let noop = LifecycleClient(
    applicationWillEnterForeground: { AsyncStream { _ in } },
    applicationDidEnterBackground: { AsyncStream { _ in } },
    connectivity: { AsyncStream { _ in } },
  )
}
