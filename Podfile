post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 15.0
       config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      end
    end
  end
 end

target 'Spendo1' do
  use_frameworks!
	pod 'Alamofire'
  pod 'GoogleSignIn'
  pod 'GoogleSignInSwift'
  pod 'GoogleSignInSwiftSupport'
end
