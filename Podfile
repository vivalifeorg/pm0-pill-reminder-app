
platform :ios, '11.0'
use_frameworks!

target "pm0" do
  pod "SearchTextField", :git => 'https://github.com/langford/SearchTextField', :commit => '9b329767b7ba129ede51c1346b29c0a8a672db62',  :inhibit_warnings => true #dropdown used in entry screen
  pod 'SQLite.swift', '~> 0.11.4',   :inhibit_warnings => true #SQLite Driver
  pod 'DZNEmptyDataSet',  :inhibit_warnings => true #Shows empty view for UITableView/UICollectionView
  pod 'KeychainAccess', :inhibit_warnings => true #Secure Storage Wrapper
  pod 'PhaxioiOS', :path => "pm0/Faxing/PhaxioAPIObjC/phaxio-ios-master", :inhibit_warnings => true #Faxing provider
  pod 'PDFGenerator', '~> 2.1', :inhibit_warnings => true #PDF making lib
  pod 'Down',  :inhibit_warnings => true, :git => 'https://github.com/iwasrobbed/Down', :commit => '4082c8d9432eb37ba6d7a4c379e714828238d061'  #markdown renderer
  pod 'SwiftGen', :inhibit_warnings => true #takes the name of the asset files and generates constants
  pod 'Yams', :inhibit_warnings => true #yaml generator to export data for tests tests for migrations
  pod 'RNCryptor', '~> 5.0', :inhibit_warnings => true #symmetric file encryption for daily checkmarks
  pod 'SwiftySignature', :inhibit_warnings => true # drives signature view
end

#Source https://github.com/CocoaPods/CocoaPods/issues/5334
post_install do |installer|
  installer.pods_project.targets.each do |target|
    next if target.product_type == "com.apple.product-type.bundle"
    target.new_shell_script_build_phase.shell_script = "mkdir -p $PODS_CONFIGURATION_BUILD_DIR/#{target.name}"
    target.build_configurations.each do |config|
      config.build_settings['CONFIGURATION_BUILD_DIR'] = '$PODS_CONFIGURATION_BUILD_DIR'
    end
  end
end
