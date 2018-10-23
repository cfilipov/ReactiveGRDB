use_frameworks!
workspace 'ReactiveGRDB.xcworkspace'

def common
    pod 'RxSwift', '~> 4.0'
    pod 'GRDB.swift', '~> 3.3.0'
end

target 'ReactiveGRDBiOS' do
  platform :ios, '8.0'
  common
end

target 'ReactiveGRDBmacOS' do
  platform :macos, '10.10'
  common
end

target 'ReactiveGRDBiOSTests' do
  platform :ios, '8.0'
  common
end

target 'ReactiveGRDBmacOSTests' do
  platform :macos, '10.10'
  common
end

target 'ReactiveGRDBDemo' do
  project 'Documentation/ReactiveGRDBDemo/ReactiveGRDBDemo.xcodeproj'
  platform :ios, '8.0'
  pod 'Differ', '~> 1.0'
  pod 'ReactiveGRDB', :path => '.'
end
