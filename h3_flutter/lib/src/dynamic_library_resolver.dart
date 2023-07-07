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
  if (Platform.isWindows) {
    return DynamicLibrary.open('h3lib.dll');
  }
  return DynamicLibrary.process();
}
