@TestOn('browser')
library;

import 'package:h3_web/h3_web.dart';
import 'package:test/test.dart';
import 'package:h3_dart/h3_dart.dart';

import 'h3_js_injector.dart';

void main() async {
  await inject(defaultH3JsUrl);

  final h3Factory = const H3Factory();

  test('H3Factory tests', () async {
    expect(
      h3Factory.process(),
      isA<H3Web>(),
      reason: 'H3Factory.process returns H3Web instance on Web',
    );
    expect(
      () => h3Factory.byPath('../h3_ffi/c/h3/build/test.common'),
      throwsA(isA<UnsupportedError>()),
      reason: 'H3Factory.byPath throws error',
    );
  });
}
