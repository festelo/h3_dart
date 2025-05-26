import 'package:h3_web/h3_web.dart';

extension StringToH3IndexExt on String {
  H3Index toH3Index() => H3Index.parse(this, radix: 16);
}

extension H3IndexToH3JS on H3Index {
  String toH3JS() => toRadixString(16);
}
