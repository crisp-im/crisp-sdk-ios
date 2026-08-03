import Foundation

package struct Company: Codable, Equatable {
  package let name: String?
  package let url: URL?
  package let companyDescription: String?

  package let employment: Employment?
  package let geolocation: Geolocation?

  package init(
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

package struct Employment: Codable, Equatable {
  package let title: String?
  package let role: String?

  package init(title: String?, role: String?) {
    self.title = title
    self.role = role
  }
}

package struct Geolocation: Codable, Equatable {
  package let city: String?
  package let country: String?

  package init(city: String?, country: String?) {
    self.city = city
    self.country = country
  }
}
