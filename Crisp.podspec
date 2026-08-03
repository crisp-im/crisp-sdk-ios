Pod::Spec.new do |s|
  s.name             = 'Crisp'
  s.version          = ENV.fetch('POD_VERSION', '0.0.0')
  s.summary          = 'Crisp SDK for iOS.'
  s.description       = 'Crisp SDK for iOS, used for visitors to get help from operators.'
  s.homepage         = 'https://crisp.chat'
  s.author           = 'Crisp IM SAS'
  s.license          = { :type => 'Commercial' }
  s.source           = { :http => "https://github.com/#{ENV.fetch('CRISP_SDK_REPO')}/releases/download/#{s.version}/Crisp_cocoapods_#{s.version}.zip" }

  s.swift_version    = '6.0'
  s.ios.deployment_target = '14.0'

  # The SDK uses Swift `package` access across its modules. SwiftPM sets
  # -package-name automatically; CocoaPods doesn't, so set it explicitly and
  # consistently (matching the SwiftPM package name) so `package` symbols resolve.
  s.pod_target_xcconfig = { 'OTHER_SWIFT_FLAGS' => '$(inherited) -package-name crisp-sdk-ios' }

  s.source_files     = 'Sources/Crisp/**/*.swift'

  s.dependency 'CrispChatBox', s.version.to_s
end
