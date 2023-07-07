import 'dart:ffi';

import 'package:h3_common/h3_common.dart';
import 'package:h3_ffi/internal.dart';
import 'package:h3_ffi/src/h3_ffi.dart';
import 'package:path/path.dart' as p;

/// H3FfiFactory is used to build H3Ffo instance
class H3FfiFactory {
  const H3FfiFactory({
    H3CFactory h3cFactory = const H3CFactory(),
  }) : _h3cFactory = h3cFactory;

  final H3CFactory _h3cFactory;

  /// Loads H3 using [dynamicLibrary]
  /// ```dart
  /// final h3 = h3Factory.process(
  ///   DynamicLibrary.open('../h3_ffi/c/h3lib/build/h3.so'),
  /// );
  /// h3.degsToRads(123);
  /// ```
  H3 byDynamicLibary(DynamicLibrary dynamicLibrary) {
    return H3Ffi(_h3cFactory.byDynamicLibary(dynamicLibrary));
  }

  /// Loads H3 by [libraryPath]
  /// ```dart
  /// final h3 = h3Factory.process('../h3_ffi/c/h3lib/build/h3.so');
  /// h3.degsToRads(123);
  /// ```
  H3 byPath(String libraryPath) {
    libraryPath = p.canonicalize(libraryPath);
    return H3Ffi(_h3cFactory.byPath(libraryPath));
  }
}
