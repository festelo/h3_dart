import 'dart:ffi';
import 'dart:io';

/// Resolves dynamic library for FFI depending on current platform.
DynamicLibrary resolveDynamicLibrary() {
  if (Platform.isLinux) {
    return DynamicLibrary.process();
  }
  if (Platform.isAndroid) {
    return DynamicLibrary.open('libh3lib.so');
  }
  return DynamicLibrary.process();
}
