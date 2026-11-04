@TestOn('browser')
library;

import 'package:h3_dart/h3_dart.dart';
import 'package:h3_web/h3_web.dart';
import 'package:test/test.dart';

// Runs without loading h3-js first: webAsync has to load it.
void main() {
  test('H3Factory.webAsync loads h3-js and returns H3Web', () async {
    expect(H3Web.isH3JsLoaded, isFalse);

    final h3 = await const H3Factory().webAsync();

    expect(h3, isA<H3Web>());
    expect(H3Web.isH3JsLoaded, isTrue);
    expect(h3.isValidCell(BigInt.parse('0x85283473fffffff')), isTrue);
  });
}
