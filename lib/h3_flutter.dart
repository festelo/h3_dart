import 'dart:ffi';
import 'dart:io';

import 'generated/generated_bindings.dart';

final DynamicLibrary _h3Lib = Platform.isAndroid
    ? DynamicLibrary.open('libh3lib.so')
    : DynamicLibrary.process();

final h3 = H3(_h3Lib);
