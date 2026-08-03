internal import CrispChatBox
internal import CrispChatBoxFFI
internal import CrispLogging
internal import CrispUtils
import Foundation

/// Represents the current user.
///
/// This class can be utilized to supplement information regarding users, aiding website operators
/// in identifying and segmenting them.
///
/// - Note: You should not create an instance of this class yourself. Instead interact with the
/// shared instance at ``CrispSDK/user``.
@objc(CRSPUser) @objcMembers public final class User: NSObject, Sendable {
  private struct Inner {
    var email: String?
    var signature: String?
    var nickname: String?
    var phone: String?
    var avatar: URL?
    var company: Company?
  }

  private let inner: LockIsolated<Inner>
  private let model: ChatBoxAPI

  /// Sets the user email (must be a valid email).
  public var email: String? {
    get { self.inner.email ?? self.model.visitorData?.email.address }
    set {
      if let email = newValue?.trimmedNonEmptyString() {
        self.model.setEmail(email, signature: self.signature)
      }
    }
  }

  /// Sets the signature for user verification.
  ///
  /// See https://docs.crisp.chat/guides/chatbox-sdks/web-sdk/identity-verification
  public var signature: String? {
    get { self.inner.signature ?? self.model.visitorData?.email.signature }
    set {
      guard
        let signature = newValue?.trimmedNonEmptyString(),
        signature.isValidSHA256()
      else {
        log.warn("Not a valid SHA256 signature.")
        return
      }

      self.inner.withValue { $0.signature = signature }

      if let email = self.email {
        self.model.setEmail(email, signature: signature)
      }
    }
  }

  /// Sets the user nickname.
  public var nickname: String? {
    get { self.inner.nickname ?? self.model.visitorData?.nickname }
    set {
      if let nickname = newValue?.trimmedNonEmptyString() {
        self.inner.withValue { $0.nickname = nickname }
        self.model.setNickname(nickname)
      }
    }
  }

  /// Sets the user phone (must be a valid phone number).
  public var phone: String? {
    get { self.inner.phone ?? self.model.visitorData?.phone }
    set {
      if let phone = newValue?.trimmedNonEmptyString() {
        self.inner.withValue { $0.phone = phone }
        self.model.setPhone(phone)
      }
    }
  }

  /// Sets the user avatar.
  public var avatar: URL? {
    get { self.inner.avatar ?? self.model.visitorData?.avatar }
    set {
      if let avatar = newValue {
        self.inner.withValue { $0.avatar = avatar }
        self.model.setAvatar(avatar)
      }
    }
  }

  /// Sets the user company (with optional user employment data).
  public var company: Company? {
    get {
      self.inner.company ?? self.model.visitorData?.company.map(Company.init)
    }
    set {
      if let company = newValue {
        self.inner.withValue { $0.company = company }
        self.model.setCompany(company.company)
      }
    }
  }

  init(model: ChatBoxAPI) {
    self.inner = .init(.init())
    self.model = model
    super.init()
  }

  func reset() {
    self.inner.setValue(.init())
  }
}

/// Identifies the company with which the current user is affiliated.
@objc(CRSPCompany) @objcMembers public final class Company: NSObject, Sendable {
  /// Company name
  public let name: String?
  /// Company website URL
  public let url: URL?
  /// Company description
  public let companyDescription: String?
  /// User employment in company
  public let employment: Employment?
  /// Company location
  public let geolocation: Geolocation?

  /// Initializes a new `Company`.
  /// - Parameters:
  ///   - name: The name for the company.
  ///   - url: The website URL for the company.
  ///   - companyDescription: The description for the company.
  ///   - employment: The user employment in the company.
  ///   - geolocation: The location of the company.
  public init(
    name: String?,
    url: URL?,
    companyDescription: String?,
    employment: Employment?,
    geolocation: Geolocation?,
  ) {
    self.name = name
    self.url = url
    self.companyDescription = companyDescription
    self.employment = employment
    self.geolocation = geolocation
  }
}

/// Indicates the manner in which the current user is affiliated with their company.
@objc(CRSPEmployment) @objcMembers public final class Employment: NSObject, Sendable {
  /// User title in company
  public let title: String?
  /// User role in company
  public let role: String?

  /// Initializes a new `Employment`.
  /// - Parameters:
  ///   - title: The user's title in their company.
  ///   - role: The user's role in their company.
  public init(title: String?, role: String?) {
    self.title = title
    self.role = role
  }
}

/// Indicates the location of the company with which the current user is affiliated.
@objc(CRSPGeolocation) @objcMembers public final class Geolocation: NSObject, Sendable {
  /// City name
  public let city: String?
  /// Country code
  public let country: String?

  /// Initializes a new `Geolocation`.
  /// - Parameters:
  ///   - city: The name of the city.
  ///   - country: The country code.
  public init(city: String?, country: String?) {
    self.city = city
    self.country = country
  }
}

private extension Company {
  convenience init(_ company: CrispChatBoxFFI.Company) {
    self.init(
      name: company.name,
      url: company.url,
      companyDescription: company.companyDescription,
      employment: company.employment.map {
        Employment(title: $0.title, role: $0.role)
      },
      geolocation: company.geolocation.map {
        Geolocation(city: $0.city, country: $0.country)
      },
    )
  }

  var company: CrispChatBoxFFI.Company {
    CrispChatBoxFFI.Company(
      name: self.name,
      url: self.url,
      companyDescription: self.companyDescription,
      employment: self.employment.map {
        .init(title: $0.title, role: $0.role)
      },
      geolocation: self.geolocation.map {
        .init(city: $0.city, country: $0.country)
      },
    )
  }
}
