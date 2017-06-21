Pod::Spec.new do |s|
    s.name                  = 'Crisp'
    s.version               = '1.0.11'
    s.summary               = 'The Crisp iOS Framework'
    s.homepage              = 'https://crisp.im/'

    s.author                = {
        'Name' => 'quentin@crisp.im'
    }
    s.license               = {
        :type => 'Copyright',
        :file => 'LICENSE'
    }

    s.platform              = :ios
    s.source                = {
        :git => 'https://github.com/crisp-im/crisp-sdk-ios.git',
        :tag => '#{s.version}'
    }
    s.frameworks            = 'SystemConfiguration'
    s.ios.deployment_target = '9.0'
    s.vendored_frameworks   = 'Crisp.framework'

    s.requires_arc          = true
    s.xcconfig              = {
        'FRAMEWORK_SEARCH_PATH' => '$(SRCROOT)/Pods/Crisp/Crisp.framework/Frameworks/'
    }

    # s.dependency 'Socket.IO-Client-Swift',  '10.0'
    # s.dependency 'SnapKit',                 '3.2'
    # s.dependency 'ObjectMapper',            '2.2'
    # s.dependency 'RxSwift',                 '3.0'
    # s.dependency 'RxCocoa',                 '3.0'
    # s.dependency 'EasyTipView',             '1.0'
    # s.dependency 'SDWebImage',              '4.0'
    # s.dependency 'SDWebImage/GIF'
    # s.dependency 'Lightbox',                '1.0'
    # s.dependency 'SwiftEventBus'
    # s.dependency 'Alamofire',               '4.0'
    # s.dependency 'NVActivityIndicatorView', '3.6'
end