Pod::Spec.new do |s|  
    s.name                  = 'Crisp'
    s.version               = '1.0.11'
    s.summary               = 'The Crisp iOS Framework'
    s.homepage              = 'https://crisp.im/'

    s.author                = { 'Name' => 'quentin@crisp.im' }
    s.license               = { :type => 'Copyright', :file => 'LICENSE' }

    s.platform              = :ios
    s.source                = { :http => "https://github.com/crisp-im/crisp-sdk-ios/releases/download/#{s.version}/Crisp.zip" }
    s.preserve_paths        = 'Crisp.framework/*'
    s.frameworks            = 'Foundation', 'UIKit', 'SystemConfiguration'
    s.ios.deployment_target = '9.0'
    s.vendored_frameworks   = 'Crisp.framework'
    s.source_files          = 'Crisp.framework/Headers/*.{h}'    
    
    s.requires_arc          = true

    s.dependency 'Socket.IO-Client-Swift',  '10.0.0'
    s.dependency 'SnapKit',                 '3.2.0'
    s.dependency 'ObjectMapper',            '2.2'
    s.dependency 'RxSwift',                 '3.0'
    s.dependency 'RxCocoa',                 '3.0'
    s.dependency 'EasyTipView',             '1.0.2'
    s.dependency 'SDWebImage',              '4.0.0'
    s.dependency 'SDWebImage/GIF'
    s.dependency 'Lightbox',                '1.0.0'
    s.dependency 'SwiftEventBus',           '2.2.0'
    s.dependency 'Alamofire',               '4.0'
    s.dependency 'NVActivityIndicatorView', '3.6.1'
end  