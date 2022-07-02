import 'dart:html';

import 'package:h3_dart/h3_dart.dart';

void main() {
  const h3Factory = H3Factory();
  final h3 = h3Factory.web();
  final isValid = h3.h3IsValid(BigInt.parse('0x85283473fffffff'));
  querySelector('#output')?.text = '0x85283473fffffff is valid hex: $isValid';
}
