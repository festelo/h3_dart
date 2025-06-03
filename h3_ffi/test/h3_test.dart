import 'package:h3_test/h3_test.dart';
import 'package:h3_ffi/h3_ffi.dart';

void main() {
  final h3 = H3FfiFactory().byPath('c/h3/build/test.common');

  testH3(
    h3,
    testOutOfBounds: false,
  );
}
