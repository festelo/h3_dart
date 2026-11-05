import 'package:test/test.dart';
import 'package:h3_web/h3_web.dart';
import 'package:h3_test/h3_test.dart';

import 'h3_js_injector.dart';

void main() async {
  final h3 = H3Web();

  setUpAll(() async {
    await inject(defaultH3JsUrl);
  });

  testH3(
    h3,
    testOutOfBounds: true,
  );
}
