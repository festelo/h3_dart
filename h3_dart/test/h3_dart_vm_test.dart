@TestOn('vm')
library h3_dart.test.vm;

import 'dart:io';

import 'package:test/test.dart';
import 'package:h3_dart/h3_dart.dart';
import 'package:h3_ffi/h3_ffi.dart';

void main() async {
  final h3Factory = const H3Factory();

  test('H3Factory tests', () async {
    expect(
      () => h3Factory.web(),
      throwsA(isA<UnsupportedError>()),
      reason: 'H3Factory.web throws error',
    );

    if (!Platform.isWindows) {
      // Not available on Windows
      expect(
        h3Factory.process(),
        isA<H3Ffi>(),
        reason: 'H3Factory.process returns H3Ffi',
      );
    }

    expect(
      h3Factory.byPath('../h3_ffi/c/h3lib/build/h3.so'),
      isA<H3Ffi>(),
      reason: 'H3Factory.byPath returns H3Ffi',
    );
  });
}
