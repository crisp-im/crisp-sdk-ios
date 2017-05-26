Pod::Spec.new do |s|  
    s.name              = 'Crisp'
    s.version           = '1.0.3'
    s.summary           = 'The Crisp iOS Framework'
    s.homepage          = 'https://crisp.im/'

    s.author            = { 'Name' => 'quentin@crisp.im' }
    s.license           = { :type => 'Copyright', :file => 'LICENSE' }

    s.platform          = :ios
    s.source            = { :http => 'https://github.com/crisp-im/crisp-sdk-ios/releases/download/1.0.3/Crisp.zip' }

    s.ios.deployment_target = '9.0'
    s.ios.vendored_frameworks = 'Crisp.framework'
end  