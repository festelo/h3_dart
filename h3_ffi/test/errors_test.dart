import 'package:h3_common/h3_common.dart';
import 'package:h3_ffi/src/mappers/errors.dart';
import 'package:test/test.dart';

Matcher throwsH3(H3ExceptionCode code) => throwsA(
      isA<H3Exception>().having((e) => e.code, 'code', code),
    );

void main() {
  group('throwIfError', () {
    test('does nothing on success', () {
      expect(() => throwIfError(0), returnsNormally);
    });

    test('maps H3 error codes', () {
      expect(() => throwIfError(5), throwsH3(H3ExceptionCode.cellInvalid));
      expect(() => throwIfError(15), throwsH3(H3ExceptionCode.optionInvalid));
      expect(() => throwIfError(16), throwsH3(H3ExceptionCode.indexInvalid));
      expect(() => throwIfError(17), throwsH3(H3ExceptionCode.baseCellDomain));
      expect(() => throwIfError(18), throwsH3(H3ExceptionCode.digitDomain));
      expect(() => throwIfError(19), throwsH3(H3ExceptionCode.deletedDigit));
    });

    test('unknown codes become an internal error', () {
      for (final code in [20, 1000, -1]) {
        expect(
          () => throwIfError(code),
          throwsH3(H3ExceptionCode.internal),
          reason: 'code $code',
        );
      }
    });
  });
}
