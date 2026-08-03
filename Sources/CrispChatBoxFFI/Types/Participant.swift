import Foundation

package struct Participant: Equatable, Codable {
  package var nickname: String?
  /// Either a `sessionId` if the message was sent by a user, or a `OperatorId` if the message
  /// was sent by an operator or `nil` if the message was sent by a bot.
  package var userId: String?
  package var avatar: URL?

  package init(nickname: String? = nil, userId: String? = nil, avatar: URL? = nil) {
    self.nickname = nickname
    self.userId = userId
    self.avatar = avatar
  }
}
