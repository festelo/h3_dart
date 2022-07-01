extension StringToBigIntExt on String {
  BigInt toBigInt() => BigInt.parse(this, radix: 16);
}

// For some reasons don't work well when the method defined as an extention
String bigIntToH3JS(BigInt bigInt) {
  return bigInt.toRadixString(16);
}
