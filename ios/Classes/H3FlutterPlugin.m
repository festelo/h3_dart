#import "H3FlutterPlugin.h"
#if __has_include(<h3_flutter/h3_flutter-Swift.h>)
#import <h3_flutter/h3_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "h3_flutter-Swift.h"
#endif

@implementation H3FlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftH3FlutterPlugin registerWithRegistrar:registrar];
}
@end
