import 'dart:ffi';
import 'dart:io';

DynamicLibrary resolveDynamicLibrary() {
  if (Platform.isLinux) {
    return DynamicLibrary.process();
  }
  if (Platform.isAndroid) {
    return DynamicLibrary.open('libh3lib.so');
  }
  return DynamicLibrary.process();
}
