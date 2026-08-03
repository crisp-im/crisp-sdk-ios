import CrispChatBoxFFI
import CrispDomain
import CrispUtils
import Foundation

package struct VisitorData {
  package struct VerifiableEmail: Equatable {
    package var address: String?
    package var signature: String?

    package init(address: String? = nil, signature: String? = nil) {
      self.address = address
      self.signature = signature
    }
  }

  package var email: VerifiableEmail
  package var phone: String?
  package var nickname: String?
  package var avatar: URL?
  package var company: CrispChatBoxFFI.Company?
  package var segments: [Segment]?
  package var data: [String: any Sendable]?

  package init(
    email: VerifiableEmail,
    phone: String?,
    nickname: String?,
    avatar: URL?,
    company: CrispChatBoxFFI.Company?,
    segments: [Segment]?,
    data: [String: any Sendable]?,
  ) {
    self.email = email
    self.phone = phone
    self.nickname = nickname
    self.avatar = avatar
    self.company = company
    self.segments = segments
    self.data = data
  }
}
