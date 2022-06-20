import 'dart:ffi';

import 'package:h3_dart/src/base_h3_factory.dart';
import 'package:h3_ffi/h3_ffi.dart';

class H3Factory implements BaseH3Factory {
  const H3Factory(this._h3ffiFactory);

  final H3FfiFactory _h3ffiFactory;

  @override
  H3 byDynamicLibary(DynamicLibrary dynamicLibrary) =>
      _h3ffiFactory.byDynamicLibary(dynamicLibrary);

  @override
  H3 byPath(String libraryPath) => _h3ffiFactory.byPath(libraryPath);

  @override
  H3 web() {
    throw UnimplementedError();
  }
}
