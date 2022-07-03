import 'dart:ffi';

import 'package:h3_ffi/h3_ffi.dart';

import 'h3_factory.base.dart';

class H3Factory implements BaseH3Factory {
  const H3Factory();

  final H3FfiFactory _internal = const H3FfiFactory();

  @override
  H3 process() => _internal.byDynamicLibary(DynamicLibrary.process());

  @override
  H3 byPath(String libraryPath) => _internal.byPath(libraryPath);

  @override
  H3 web() {
    throw UnsupportedError('H3Factory.web() is not supported under Dart VM');
  }
}
