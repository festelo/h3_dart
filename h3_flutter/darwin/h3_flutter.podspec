#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint h3_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'h3_flutter'
  s.version          = '0.7.0'
  s.summary          = 'H3 Flutter plugin'
  s.description      = <<-DESC
A Flutter plugin providing FFI bindings to the H3 C library.
                       DESC
  s.homepage         = 'https://github.com/festelo/h3_flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Ilia Beregovskii' => 'festeloqq@gmail.com' }
  s.source           = { :path => '.' }

  # iOS: dynamic h3.framework, embedded into the app by CocoaPods, so H3
  # symbols stay visible to DynamicLibrary.process() with any pod linkage.
  s.ios.vendored_frameworks = 'Libs/h3.xcframework'
  s.ios.preserve_paths = 'Libs/h3.xcframework/**/*'
  s.osx.vendored_frameworks = 'Libs/h3_macos.xcframework'
  s.osx.preserve_paths = 'Libs/h3_macos.xcframework/**/*'
  s.source_files = 'include.c'

  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.13'

  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
  }

  s.ios.pod_target_xcconfig = {
    # Flutter.framework does not contain a i386 slice.
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
  }

  s.osx.pod_target_xcconfig = {
    'OTHER_LDFLAGS' => "-force_load $(PODS_TARGET_SRCROOT)/Libs/h3_macos.xcframework/macos-arm64_x86_64/libh3.a",
  }

end
