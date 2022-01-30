import 'dart:ffi';

import 'package:h3_flutter/h3_flutter.dart';
import 'package:h3_flutter/src/generated/generated_bindings.dart' as c;

extension GeoCoordToNativeMapperExtension on GeoCoord {
  /// Returns native representation of GeoCoord class
  Pointer<c.GeoCoord> toNative(Allocator allocator) {
    final pointer = allocator<c.GeoCoord>();
    fillNative(pointer.ref);
    return pointer;
  }

  void fillNative(c.GeoCoord ref) {
    ref.lat = h3.degsToRads(lat);
    ref.lon = h3.degsToRads(lon);
  }
}

extension GeoCoordFromNativeMapperExtension on c.GeoCoord {
  /// Returns [GeoCoord] representation of native GeoCoord class
  GeoCoord toPure() {
    return GeoCoord(
      lat: h3.radsToDegs(lat),
      lon: h3.radsToDegs(lon),
    );
  }
}

extension CoordIJToNativeMapperExtension on CoordIJ {
  /// Returns native representation of CoordIJ class
  Pointer<c.CoordIJ> toNative(Allocator allocator) {
    final pointer = allocator<c.CoordIJ>();
    pointer.ref.i = i;
    pointer.ref.j = j;
    return pointer;
  }
}

extension CoordIJFromNativeMapperExtension on c.CoordIJ {
  /// Returns [CoordIJ] representation of native CoordIJ class
  CoordIJ toPure() {
    return CoordIJ(
      i: i,
      j: j,
    );
  }
}
