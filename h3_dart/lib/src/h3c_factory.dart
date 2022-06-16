import 'dart:ffi';

import 'package:h3_dart/src/generated/generated_bindings.dart';

class H3CFactory {
  const H3CFactory();

  H3C byDynamicLibary(DynamicLibrary dynamicLibrary) {
    return H3C(dynamicLibrary);
  }

  H3C byPath(String libraryPath) {
    return byDynamicLibary(DynamicLibrary.open(libraryPath));
  }
}
