import 'dart:ffi';

import 'package:h3_common/src/h3.dart';
import 'package:h3_dart/src/base_h3_factory.dart';

class H3Factory implements BaseH3Factory {
  @override
  H3 byDynamicLibary(DynamicLibrary dynamicLibrary) {
    throw UnimplementedError();
  }

  @override
  H3 byPath(String libraryPath) {
    throw UnimplementedError();
  }

  @override
  H3 web() {
    throw UnimplementedError();
  }
}
