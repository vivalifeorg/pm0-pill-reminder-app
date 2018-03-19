Pod::Spec.new do |s|
  s.name = 'PhaxioSwiftAlamofire'
  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.11'
  s.tvos.deployment_target = '9.0'
  s.version = '0.0.1'
  s.source = { :git => 'git@github.com:swagger-api/swagger-mustache.git', :tag => 'v1.0.0' }
  s.authors = 'Swagger Codegen'
  s.license = 'Proprietary'
  s.homepage = 'localhost'
  s.summary = 'Swagger-Codegen-Output-Swift-4-Library-for-Phaxio-Faxing-Service'
  s.source_files = 'PhaxioSwiftAlamofire/Classes/**/*.swift'
  s.dependency 'Alamofire', '~> 4.5.0'
end
