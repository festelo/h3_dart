import 'dart:ffi';

import 'dart:io';

DynamicLibrary? _h3cLib;

DynamicLibrary get h3cLib {
  if (_h3cLib == null) {
    initH3C();
  }
  return _h3cLib!;
}

void initH3C([DynamicLibrary? library]) {
  if (library != null) {
    _h3cLib = library;
  } else {
    _h3cLib = Platform.isAndroid
        ? DynamicLibrary.open('libh3lib.so')
        : DynamicLibrary.process();
  }
}
