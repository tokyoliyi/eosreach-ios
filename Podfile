platform :ios, '11.0'
use_frameworks!

def pods
    pod 'RxSwift',    '~> 4.0'
    pod 'RxCocoa',    '~> 4.0'
    pod 'BigInt', '~> 3.1'
    pod 'R.swift', '5.0.0.alpha.1'
    pod 'Material', '~> 2.16'
    pod 'RealmSwift'
    pod 'EllipticCurveKeyPair', '2.0-beta1'
    pod 'SideMenu'
    pod 'Kingfisher', '~> 4.0'
    pod 'eosswift', '1.3'
end

target 'prod' do
  pods
end

target 'stub' do
  pods
end

target 'eosreachTests' do
  pods
  inherit! :search_paths
  pod 'RxBlocking', '~> 4.0'
  pod 'RxTest',     '~> 4.0'
  pod 'EarlGrey'
end
