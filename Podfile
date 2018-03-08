
platform :ios, '11.0'
use_frameworks!

target "pm0" do
  pod "SearchTextField", :git => 'https://github.com/apasccon/SearchTextField', :commit => '97cb555c4721cd80257022637ee255dc812eda3a',  :inhibit_warnings => true
  pod 'SQLite.swift', '~> 0.11.4',   :inhibit_warnings => true
  pod 'DZNEmptyDataSet',  :inhibit_warnings => true
  pod 'Keychain', :inhibit_warnings => true
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
