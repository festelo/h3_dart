import 'dart:ffi';

import 'package:h3_ffi/src/generated/generated_bindings.dart';

/// H3CFactory is used to build H3C instance
class H3CFactory {
  const H3CFactory();

  /// Loads [H3C] by DynamicLibrary
  /// ```dart
  /// final h3c = h3CFactory.byDynamicLibary();
  /// ```
  H3C byDynamicLibary(DynamicLibrary dynamicLibrary) {
    return H3C(dynamicLibrary);
  }

  /// Loads [H3C] by [libraryPath]
  /// ```dart
  /// final h3c = h3CFactory.byPath('../h3_ffi/c/h3lib/build/h3.so');
  /// ```
  H3C byPath(String libraryPath) {
    return byDynamicLibary(DynamicLibrary.open(libraryPath));
  }
}
