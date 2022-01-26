import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:h3_flutter/h3_flutter.dart';

import 'generated/generated_bindings.dart' as c;

class GeoCoord {
  GeoCoord(this.lon, this.lat);

  final double lat;
  final double lon;
}

extension GeoCoordNativeMapperExt on GeoCoord {
  Pointer<c.GeoCoord> toNative([Pointer<c.GeoCoord>? pointer]) {
    pointer ??= calloc<c.GeoCoord>();
    pointer.ref.lat = h3.degsToRads(lat);
    pointer.ref.lon = h3.degsToRads(lon);
    return pointer;
  }
}
