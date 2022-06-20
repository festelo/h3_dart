import 'dart:ffi';
import 'package:h3_ffi/h3_ffi.dart';

abstract class BaseH3Factory {
  const BaseH3Factory();

  H3 byDynamicLibary(DynamicLibrary dynamicLibrary);

  H3 byPath(String libraryPath);

  H3 web();
}
