import Foundation

public struct Message: Equatable, Sendable {
  public var isMe: Bool
  public var content: Content
  public var origin: Origin
  public var timestamp: Date
  public var fingerprint: Int64
  public var from: Sender
  public var user: User?
}

public extension Message {
  enum Origin: Equatable, Sendable {
    case local
    case network
    case update
  }

  enum Sender: Equatable, Sendable {
    case user
    case `operator`
  }

  struct User: Equatable, Sendable {
    public var nickname: String?
    public var userId: String?
    public var avatar: URL?
  }
}
