import 'dart:async';

import 'package:h3_ffi/h3_ffi.dart';
import 'package:h3_web/constants.dart';

import 'dynamic_library_resolver.dart';
import 'h3_factory.base.dart';

class H3Factory implements BaseH3Factory {
  const H3Factory();

  final _internal = const H3FfiFactory();

  @override
  FutureOr<H3> load({String libraryUrl = defaultH3JsUrl}) {
    return _internal.byDynamicLibary(resolveDynamicLibrary());
  }
}
