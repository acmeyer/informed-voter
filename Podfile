platform :ios, '10.0'
use_frameworks!

target 'InformedVoter' do
  pod 'SwiftyJSON'
  pod 'GooglePlaces'
  pod 'GoogleMaps'
  pod 'Alamofire', '~> 4.0'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'OneSignal'
  pod 'RealmSwift'
  pod 'SVProgressHUD'
end

target 'InformedVoterMessages' do
  pod 'SwiftyJSON'
  pod 'GooglePlaces'
  pod 'GoogleMaps'
  pod 'Alamofire', '~> 4.0'
  pod 'RealmSwift'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
