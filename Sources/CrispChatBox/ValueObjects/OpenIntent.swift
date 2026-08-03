import CrispDomain

package enum OpenIntent: Equatable {
  case chat
  case helpdesk
  case helpdeskArticle(HelpdeskArticle)
}
