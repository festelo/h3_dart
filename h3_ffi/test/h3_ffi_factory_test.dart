import 'dart:ffi';
import 'package:test/test.dart';
import 'package:h3_ffi/h3_ffi.dart';
import 'package:path/path.dart' as p;

void main() {
  test('H3FfiFactory', () async {
    expect(
      H3FfiFactory().byDynamicLibary(
        DynamicLibrary.open(p.canonicalize('c/h3lib/build/h3.so')),
      ),
      isA<H3Ffi>(),
      reason: 'H3FfiFactory.byDynamicLibary returns H3Ffi instance',
    );

    expect(
      H3FfiFactory().byPath('c/h3lib/build/h3.so'),
      isA<H3Ffi>(),
      reason: 'H3FfiFactory.byPath returns H3Ffi instance',
    );
  });
}
