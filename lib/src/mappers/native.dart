import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'package:h3_flutter/h3_flutter.dart';
import 'package:h3_flutter/src/generated/generated_bindings.dart' as c;

extension GeoCoordNativeMapperExtension on GeoCoord {
  /// Returns native representation of GeoCoord class
  Pointer<c.GeoCoord> toNative([Pointer<c.GeoCoord>? pointer]) {
    pointer ??= calloc<c.GeoCoord>();
    pointer.ref.lat = h3.degsToRads(lat);
    pointer.ref.lon = h3.degsToRads(lon);
    return pointer;
  }
}
