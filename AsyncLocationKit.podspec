Pod::Spec.new do |s|
  s.name                   = 'AsyncLocationKit'
  s.module_name            = 'AsyncLocationKit'
  s.version                = '1.6.2'
  s.summary                = '📍async/await CoreLocation'
  s.homepage               = 'https://github.com/AsyncSwift/AsyncLocationKit'
  s.license                = 'MIT'
  s.author                 = { 'Pavel Grechikhin' => 'pav.gre4ixin@gmail.com' }
  s.source                 = { :git => 'https://github.com/AsyncSwift/AsyncLocationKit.git', :tag => s.version }
  s.ios.deployment_target = '13.0'
  s.tvos.deployment_target = '13.0'
  s.watchos.deployment_target = '6.0'
  s.requires_arc = true
  s.swift_version = '5.5'
  s.source_files = 'Sources/AsyncLocationKit/**/*.{swift}'
end
