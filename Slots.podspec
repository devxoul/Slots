Pod::Spec.new do |s|
  s.name             = 'Slots'
  s.version          = '1.2.1'
  s.summary          = 'Dynamic contents management for Swift.'
  s.homepage         = 'https://github.com/devxoul/Slots'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Suyeol Jeon' => 'devxoul@gmail.com' }
  s.source           = { :git => 'https://github.com/devxoul/Slots.git', :tag => s.version.to_s }
  s.source_files     = 'Slots/*.{swift}'
  s.requires_arc     = true

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
end
