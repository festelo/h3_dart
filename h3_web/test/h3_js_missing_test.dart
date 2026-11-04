// Runs without loading h3-js. Each test file runs on its own page, so h3-js
// is not on this one.
import 'package:h3_web/h3_web.dart';
import 'package:test/test.dart';

void main() {
  const h3 = H3Web();

  test('isH3JsLoaded is false', () {
    expect(H3Web.isH3JsLoaded, isFalse);
  });

  test('a call says how to load h3-js', () {
    expect(
      () => h3.isValidCell(BigInt.parse('0x85283473fffffff')),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          allOf(contains('h3-js is not loaded'), contains('<script')),
        ),
      ),
    );
  });
}
