import CrispDomain
import Foundation

package enum Locales {
  package static var live: [LocaleId] {
    Locale.preferredLanguages.map(LocaleId.init(identifier:))
  }

  package static let test: [LocaleId] = [LocaleId(identifier: "en")]
}
