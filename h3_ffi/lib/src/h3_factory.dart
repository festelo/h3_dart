import 'dart:ffi';

import 'package:h3_common/h3_common.dart';
import 'package:h3_ffi/internal.dart';
import 'package:h3_ffi/src/h3_ffi.dart';
import 'package:path/path.dart' as p;

class H3FfiFactory {
  const H3FfiFactory({
    H3CFactory h3cFactory = const H3CFactory(),
  }) : _h3cFactory = h3cFactory;

  final H3CFactory _h3cFactory;

  H3 byDynamicLibary(DynamicLibrary dynamicLibrary) {
    return H3Ffi(_h3cFactory.byDynamicLibary(dynamicLibrary));
  }

  H3 byPath(String libraryPath) {
    libraryPath = p.canonicalize(libraryPath);
    return H3Ffi(_h3cFactory.byPath(libraryPath));
  }
}
