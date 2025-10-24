# Podfile for Trusenda CRM iOS App
# Use this if Swift Package Manager doesn't work for Google Places

platform :ios, '16.0'

target 'TrusendaCRM' do
  # Use frameworks
  use_frameworks!

  # Auth0 SDK for iOS
  # Social login (Google, Apple) and secure authentication
  pod 'Auth0', '~> 2.0'

  # Google Places SDK for iOS
  # Address autocomplete for Add Property form
  pod 'GooglePlaces', '~> 9.0'
  
  # Optional: Google Maps SDK if needed for map views
  # pod 'GoogleMaps', '~> 9.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
    end
  end
end

# Installation Instructions:
# 1. Open Terminal
# 2. cd to project directory: cd "/Users/zachthomas/Desktop/CRM-APP-SWIFT"
# 3. Install CocoaPods: sudo gem install cocoapods (if not installed)
# 4. Run: pod install
# 5. Close Xcode
# 6. Open: TrusendaCRM.xcworkspace (NOT .xcodeproj!)
# 7. Build and run

