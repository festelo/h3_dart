import 'dart:ffi';

import 'package:h3_dart/h3_dart.dart';
import 'package:h3_dart/internal.dart';
import 'package:path/path.dart' as p;

class H3Factory {
  const H3Factory({
    H3CFactory h3cFactory = const H3CFactory(),
  }) : _h3cFactory = h3cFactory;

  final H3CFactory _h3cFactory;

  H3 byDynamicLibary(DynamicLibrary dynamicLibrary) {
    return H3(_h3cFactory.byDynamicLibary(dynamicLibrary));
  }

  H3 byPath(String libraryPath) {
    libraryPath = p.canonicalize(libraryPath);
    return H3(_h3cFactory.byPath(libraryPath));
  }
}
