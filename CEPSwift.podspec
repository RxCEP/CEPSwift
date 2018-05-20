Pod::Spec.new do |s|
  s.name             = 'CEPSwift'
  s.version          = '0.1.0'
  s.summary          = 'Complex Event Processing Engine for Swift.'
  s.description      = 'CEPSwift is a Complex Event Processing Engine for Swift built on top of RxSwift! You can create event streams, apply common CEP operators and deal with them asynchronous.'
  s.homepage         = 'https://github.com/guedesbgeorge/CEPSwift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'George Guedes' => 'guedesbgeorge42@gmail.com' }
  s.source           = { :git => 'https://github.com/guedesbgeorge/CEPSwift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.source_files = 'CEPSwift/Classes/**/*'
  s.dependency 'RxSwift'
  s.dependency 'RxTest'
end
