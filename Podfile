source 'https://github.com/CocoaPods/Specs.git'
platform :ios, 10.0
use_frameworks!
use_modular_headers!
inhibit_all_warnings!

def firebase
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Performance'

  # Pods for PodTest
  pod 'Fabric', '~> 1.10.2'
  pod 'Crashlytics', '~> 3.14.0'
end

abstract_target 'ScalaDaysPods' do
  pod 'Alamofire', '~> 5.0'
  pod 'TwitterKit', '3.3.0'

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
