import 'dart:html';

import 'package:h3_web/h3_web.dart';

void main() {
  const h3 = H3Web();
  final isValid = h3.h3IsValid(BigInt.parse('0x85283473fffffff'));
  querySelector('#output')?.text = '0x85283473fffffff is valid hex: $isValid';
}
