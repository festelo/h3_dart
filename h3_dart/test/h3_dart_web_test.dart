@TestOn('browser')
library h3_web.test.web;

import 'package:h3_web/h3_web.dart';
import 'package:test/test.dart';
import 'package:h3_dart/h3_dart.dart';

import 'h3_js_injector.dart';

void main() async {
  await inject('https://unpkg.com/h3-js@3.7.2');

  final h3Factory = const H3Factory();

  test('H3Factory tests', () async {
    expect(
      h3Factory.web(),
      isA<H3Web>(),
      reason: 'H3Factory.web returns H3Web instance on Web',
    );
    expect(
      () => h3Factory.process(),
      throwsA(isA<UnsupportedError>()),
      reason: 'H3Factory.process throws error',
    );
    expect(
      () => h3Factory.byPath('../h3_ffi/c/h3lib/build/h3.so'),
      throwsA(isA<UnsupportedError>()),
      reason: 'H3Factory.byPath throws error',
    );
  });
}
