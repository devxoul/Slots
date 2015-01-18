Pod::Spec.new do |s|
  s.name             = 'Bucket'
  s.version          = '0.1.0'
  s.summary          = 'Dynamic contents management for Swift.'
  s.homepage         = 'https://github.com/devxoul/Bucket'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Suyeol Jeon' => 'devxoul@gmail.com' }
  s.source           = { :git => 'https://github.com/devxoul/Bucket.git', :tag => s.version.to_s }
  s.source_files     = 'Bucket/*.{swift}'
  s.requires_arc     = true

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
end
