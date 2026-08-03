import CrispDomain
import Foundation

package struct HelpdeskArticle: Decodable, Hashable {
  package var title: String?
  package var category: String?
  package var excerpt: String?
  package var locale: LanguageCode
  package var slug: String

  package init(
    title: String?,
    category: String?,
    excerpt: String?,
    locale: LanguageCode,
    slug: String,
  ) {
    self.title = title
    self.category = category
    self.excerpt = excerpt
    self.locale = locale
    self.slug = slug
  }
}
