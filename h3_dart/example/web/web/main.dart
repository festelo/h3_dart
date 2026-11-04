import 'package:web/web.dart';

import 'package:h3_dart/h3_dart.dart';

Future<void> main() async {
  const h3Factory = H3Factory();
  final h3 = await h3Factory.webAsync();
  final isValid = h3.isValidCell(BigInt.parse('0x85283473fffffff'));
  document.querySelector('#output')?.textContent =
      '0x85283473fffffff is valid hex: $isValid';
}
