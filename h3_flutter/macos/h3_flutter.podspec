#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint h3_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'h3_flutter'
  s.version          = '0.4.2'
  s.summary          = 'H3 Flutter plugin'
  s.description      = <<-DESC
H3 Flutter plugin
                       DESC
  s.homepage         = 'https://github.com/festelo/h3_flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Ilia Beregovskii' => 'festeloqq@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*.{m,c,swift}'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
