import 'package:test/test.dart';
import 'package:h3_web/h3_web.dart';
import 'package:h3_test/h3_test.dart';

import 'h3_js_injector.dart';

void main() async {
  final h3 = H3Web();

  setUpAll(() async {
    await inject('https://unpkg.com/h3-js@4.2.1');
  });

  testH3(
    h3,
    testOutOfBounds: true,
  );
}
