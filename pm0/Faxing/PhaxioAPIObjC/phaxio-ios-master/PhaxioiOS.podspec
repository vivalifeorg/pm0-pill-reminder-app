#
# Be sure to run `pod lib lint PhaxioiOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PhaxioiOS'
  s.version          = '0.1.0'
  s.summary          = 'Build apps that talk fax.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Build apps that talk fax. Send and receive fax through our advanced, best-in-class API. 
  DESC

  s.homepage         = 'https://github.com/phaxio/phaxio-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Nick Schulze' => 'nschulze16@gmail.com' }
  s.source           = { :git => 'https://github.com/phaxio/phaxio-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Phaxio/**/*.{h,m}'
  
  # s.resource_bundles = {
  # 'PhaxioiOS' => ['PhaxioiOS/Assets/*.png']
  # }

  s.public_header_files = 'Phaxio/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
#s.dependency 'AFNetworking', '~> 2.3'
end
