extension StringToBigIntExt on String {
  BigInt toBigInt() => BigInt.parse(this, radix: 16);
}

extension BigIntToH3JS on BigInt {
  String toH3JS() => toRadixString(16);
}
