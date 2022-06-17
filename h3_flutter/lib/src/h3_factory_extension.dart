import 'package:h3_dart/h3_dart.dart';

import 'dynamic_library_resolver.dart';

extension H3FlutterExtension on H3Factory {
  H3 load() {
    return byDynamicLibary(resolveDynamicLibrary());
  }
}
