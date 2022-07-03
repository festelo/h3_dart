import 'package:h3_ffi/internal.dart';

import 'dynamic_library_resolver.dart';

extension H3CFlutterExtension on H3CFactory {
  H3C load() {
    return byDynamicLibary(resolveDynamicLibrary());
  }
}
