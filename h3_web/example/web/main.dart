import 'package:web/web.dart';

import 'package:h3_web/h3_web.dart';

void main() {
  const h3 = H3Web();
  final isValid = h3.isValidCell(BigInt.parse('0x85283473fffffff'));
  document.getElementById('output')?.textContent =
      '0x85283473fffffff is valid hex: $isValid';
}
