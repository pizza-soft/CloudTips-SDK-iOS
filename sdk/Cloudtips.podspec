#
#  Be sure to run `pod spec lint SDK-iOS.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "Cloudtips"
  spec.version      = "1.2.3"
  spec.summary      = "Core library that allows you to use tips from Cloudtips in your app"
  spec.description  = "Core library that allows you to use tips from Cloudtips in your app"

  spec.homepage     = "https://cloudtips.ru/"

  spec.license      = "{ :type => 'Apache 2.0' }"

  spec.author       = { "Anton Ignatov" => "a.ignatov@cloudpayments.ru",
			"Sergey Iskhakov" => "s.iskhakov@cloudpayments.ru" }
	
  spec.platform     = :ios
  spec.ios.deployment_target = "11.0"

  spec.source       = { :git => "https://github.com/cloudpayments/CloudTips-SDK-iOS.git", :tag => "#{spec.version}" }
  spec.source_files  = 'Sources/**/*.{.h,swift}'

  spec.resource_bundles = { 'CloudtipsSDK' => [
    'Resources/**/*.{json,png,jpeg,jpg,storyboard,xib,xcassets}'
    ]
  }
  
  spec.requires_arc = true
  
  spec.dependency 'SDWebImage', '~> 5.0'
  spec.dependency 'Cloudpayments'
  spec.dependency 'ReCaptcha'
  spec.dependency 'YandexLoginSDK'
  spec.dependency 'PromiseKit/CorePromise'
  spec.dependency 'SnapKit'

  spec.vendored_frameworks = 'YandexPaySDK/Static/YandexPaySDK.xcframework', 'YandexPaySDK/Static/XPlatPaySDK.xcframework'
  spec.resources = ["YandexPaySDK/Static/YandexPaySDKResources.bundle"]

end
