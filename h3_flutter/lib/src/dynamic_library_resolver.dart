import 'dart:ffi';
import 'dart:io';

/// Resolves dynamic library for FFI depending on current platform.
DynamicLibrary resolveDynamicLibrary() {
  if (Platform.isLinux) {
    return DynamicLibrary.open('h3.so');
  }
  if (Platform.isAndroid) {
    return DynamicLibrary.open('h3.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('h3.dll');
  }
  return DynamicLibrary.process();
}
