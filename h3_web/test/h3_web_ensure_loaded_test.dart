@TestOn('browser')
library;

import 'package:h3_web/h3_web.dart';
import 'package:h3_web/src/js/h3_js.dart' show defaultH3JsUrl;
import 'package:test/test.dart';
import 'package:web/web.dart' as web;

// Runs without loading h3-js first. Each test file runs on its own page, and
// the tests below depend on the order: h3-js is loaded by the third test.
void main() {
  final cell = BigInt.parse('0x85283473fffffff');

  test('h3-js is not on the page at first', () {
    expect(H3Web.isH3JsLoaded, isFalse);
  });

  test('ensureLoaded throws when the script cannot be loaded', () async {
    await expectLater(
      H3Web.ensureLoaded(url: 'h3-js-does-not-exist.js'),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Failed to load h3-js'),
        ),
      ),
    );
    expect(H3Web.isH3JsLoaded, isFalse);
  });

  test('ensureLoaded loads h3-js, concurrent calls share one request',
      () async {
    await Future.wait([H3Web.ensureLoaded(), H3Web.ensureLoaded()]);

    expect(H3Web.isH3JsLoaded, isTrue);
    expect(const H3Web().isValidCell(cell), isTrue);
    expect(
      web.document.querySelectorAll('script[src="$defaultH3JsUrl"]').length,
      1,
    );
  });

  test('ensureLoaded does nothing when h3-js is already loaded', () async {
    await H3Web.ensureLoaded(url: 'h3-js-does-not-exist.js');

    expect(H3Web.isH3JsLoaded, isTrue);
  });
}
