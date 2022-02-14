Pod::Spec.new do |spec|
  spec.name                = "Crisp"
  spec.version             = "1.2.0-beta.2"
  spec.summary             = "Crisp SDK for iOS."
  spec.description         = "Crisp SDK for iOS, used for visitors to get help from operators."
  spec.homepage            = "https://crisp.chat"
  spec.author              = "Crisp IM SAS"
  spec.platform            = :ios, "13.0"
  spec.license             = { :type => "Commercial" }
  spec.source              = { :http => "https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.2.0-beta.2/Crisp_1.2.0-beta.2.zip" }
  spec.vendored_frameworks = "Crisp.xcframework"
  spec.preserve_paths      = "Crisp.xcframework"
end
