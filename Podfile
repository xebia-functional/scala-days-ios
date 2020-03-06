source 'https://github.com/CocoaPods/Specs.git'
platform :ios, 10.0
use_frameworks!
use_modular_headers!
inhibit_all_warnings!

def firebase
  # enabled Analytics
  pod 'Firebase/Analytics'

  # enabled Crashlytics (Firebase)
  pod 'Fabric', '~> 1.10.2'
  pod 'Crashlytics', '~> 3.14.0'

  # enabled Performance Monitoring
  pod 'Firebase/Performance'
end


abstract_target 'ScalaDaysPods' do
  pod 'Alamofire', '~> 5.0'
  pod 'TwitterKit', '3.4.2'

  target 'ScalaDays' do
    firebase

    # UI
    pod 'SDWebImage', '~> 3.5'
    pod 'SVProgressHUD', '~> 1.0'
    pod 'UIView+AutoLayout', '~> 1.3'

    # QR code library
    pod 'ZBarSDK', '~> 1.3.1'

    # Miscellaneous Utils
    pod 'NSDate+TimeAgo', '~> 1.0.2'

    # Push notifications
    pod 'Localytics', '~> 5.8'
  end

  target 'ScalaDaysTests' do
  end
end
