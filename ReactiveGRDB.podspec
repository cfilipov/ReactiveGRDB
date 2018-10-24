Pod::Spec.new do |s|
  s.name     = 'ReactiveGRDB'
  s.version  = '0.12.0'
  
  s.license  = { :type => 'MIT', :file => 'LICENSE' }
  s.summary  = 'ReactiveKit extensions for GRDB.swift.'
  s.homepage = 'https://github.com/cfilipov/ReactiveGRDB'
  s.author   = { 'Gwendal Roué' => 'gr@pierlis.com' }
  s.source   = { :git => 'https://github.com/cfilipov/ReactiveGRDB.git', :tag => "v#{s.version}" }
  s.module_name = 'ReactiveGRDB'
  
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.watchos.deployment_target = '2.0'
  
  s.dependency "ReactiveKit"
  s.default_subspec = 'default'
  
  s.subspec 'default' do |ss|
    ss.source_files = 'ReactiveGRDB/**/*.{h,swift}'
    ss.dependency "GRDB.swift", "~> 3.3.0"
  end
  
  s.subspec 'GRDBCipher' do |ss|
    ss.source_files = 'ReactiveGRDB/**/*.{h,swift}'
    ss.dependency "GRDBCipher", "~> 3.3.0"
    ss.xcconfig = {
      'OTHER_SWIFT_FLAGS' => '$(inherited) -DSQLITE_HAS_CODEC -DUSING_SQLCIPHER',
      'OTHER_CFLAGS' => '$(inherited) -DSQLITE_HAS_CODEC -DUSING_SQLCIPHER',
    }
  end
end
