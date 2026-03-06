Pod::Spec.new do |s|
  s.name             = 'SenzuRouteKit'
  s.version          = '1.0.0'
  s.summary          = 'A production-oriented navigation framework for UIKit + SwiftUI apps.'
  s.description      = <<-DESC
SenzuRouteKit centralizes routing, SwiftUI hosting, and DI helpers for UIKit + SwiftUI projects.
It includes route registration, push/present flow management, and built-in Resolver-backed DI APIs.
  DESC
  s.homepage         = 'https://github.com/Chen-Charles-Ke/SenzuRouteKit'
  s.author           = { 'Charles Chen' => 'chencharleske@gmail.com' }
  s.license          = { :type => 'Proprietary', :text => 'Copyright (c) Charles Chen. All rights reserved.' }
  s.source           = { :git => 'https://github.com/Chen-Charles-Ke/SenzuRouteKit.git', :tag => s.version.to_s }

  s.platform         = :ios, '13.0'
  s.swift_version    = '5.9'

  s.source_files     = 'Sources/SenzuRouteKit/**/*.swift'

  s.dependency 'Resolver', '~> 1.5'
end
