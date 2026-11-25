import 'package:h3_ffi/h3_ffi.dart';

void main() {
  final h3 = H3FfiFactory().byPath('../../h3_ffi/c/h3/build/lib/libh3.dylib');

  final isValid = h3.isValidCell(BigInt.parse('0x85283473fffffff'));
  print('0x85283473fffffff is valid hex: $isValid');
}
