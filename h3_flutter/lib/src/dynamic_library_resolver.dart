import 'dart:ffi';
import 'dart:io';

DynamicLibrary resolveDynamicLibrary() {
  final library = Platform.isAndroid
      ? DynamicLibrary.open('libh3lib.so')
      : DynamicLibrary.process();
  return library;
}
