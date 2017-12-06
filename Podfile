source 'ssh://git@github.com/CocoaPods/Specs.git'
source 'ssh://git@bitbucket.phunware.com:7999/misc/cocoapods-sdk-ios.git'

#platform :ios, '9.0'
inhibit_all_warnings!

def pw_pods
  pod 'PWMapKit', '3.1.7'
  pod 'StepInsideSdk', :http => 'https://phunware-765bf3b3:6dfeef13a4494f79@artifacts.senionlab.com/pods/stepinside-sdk/5.1.1.zip'
  
  pod 'PWEngagement'
end

def general_pods
  pod 'Crashlytics'
  pod 'Fabric'
  pod 'SVPulsingAnnotationView', :git => 'https://github.com/TransitApp/SVPulsingAnnotationView'
  pod 'DZNEmptyDataSet', '~> 1.8.1'
end


target 'Carnival' do
  use_frameworks!
  pw_pods
  general_pods
end

post_install do |installer_representation|
    installer_representation.pods_project.build_configurations.each do |config|
        config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ''
    end
end
