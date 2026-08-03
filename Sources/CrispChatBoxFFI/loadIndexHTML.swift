import CrispClient
import CrispDomain
import Foundation

package enum Presentation: String {
  case `default`
  case sheet
}

package func loadIndexHTML(
  websiteId: WebsiteId,
  sessionId: SessionId?,
  tokenId: TokenId?,
  locales: [LocaleId],
  presentation: Presentation,
  assetsURL: URL,
) throws(CrispClientError) -> String {
  guard let url = Bundle.module.url(forResource: "index", withExtension: "html") else {
    throw .htmlMissing
  }

  let locales = locales
    .map { "\"\($0.identifier)\"" }
    .joined(separator: ",")

  do {
    return try String(contentsOf: url, encoding: .utf8)
      .replacingOccurrences(of: "{{WEBSITE_ID}}", with: websiteId.rawValue)
      .replacingOccurrences(of: "{{SESSION_ID}}", with: sessionId?.rawValue ?? "")
      .replacingOccurrences(of: "{{TOKEN_ID}}", with: tokenId?.rawValue ?? "")
      .replacingOccurrences(of: "{{USER_LOCALES}}", with: "[\(locales)]")
      .replacingOccurrences(of: "{{PRESENTATION}}", with: presentation.rawValue)
      .replacingOccurrences(of: "{{MOBILE_SDK_ENABLED}}", with: "true")
      .replacingOccurrences(of: "{{CRISP_CLIENT_JS}}", with: CrispClient.generatedJS)
      .replacingOccurrences(of: "{{ASSETS_URL}}", with: assetsURL.absoluteString)
  } catch {
    throw .htmlReadFailed(url: url)
  }
}

package func distBundleURL() throws(CrispClientError) -> URL {
  do {
    return try CrispWebClient.bundleURL()
  } catch {
    throw CrispClientError.bundleMissing
  }
}
