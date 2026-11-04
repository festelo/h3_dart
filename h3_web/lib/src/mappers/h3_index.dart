import 'dart:js_interop';

import 'package:h3_common/h3_common.dart';

extension StringToH3IndexExt on String {
  H3Index toH3Index() => H3Index.parse(this, radix: 16);
}

extension H3IndexToH3JS on H3Index {
  String toH3JS() => toRadixString(16);
}

extension H3IndexListToJS on Iterable<H3Index> {
  JSArray<JSString> toH3JS() => [for (final e in this) e.toH3JS().toJS].toJS;
}

extension JSStringArrayToH3Index on JSArray<JSString> {
  List<H3Index> toH3Indexes() => [for (final e in toDart) e.toDart.toH3Index()];
}
