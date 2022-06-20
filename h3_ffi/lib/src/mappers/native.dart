import 'dart:ffi';

import 'package:h3_common/h3_common.dart';
import 'package:h3_ffi/src/generated/generated_bindings.dart' as c;

extension GeoCoordToNativeMapperExtension on GeoCoordRadians {
  /// Returns native representation of GeoCoord class
  Pointer<c.GeoCoord> toNative(Allocator allocator) {
    final pointer = allocator<c.GeoCoord>();
    assignToNative(pointer.ref);
    return pointer;
  }

  void assignToNative(c.GeoCoord ref) {
    ref.lat = lat;
    ref.lon = lon;
  }
}

extension GeoCoordFromNativeMapperExtension on c.GeoCoord {
  /// Returns [GeoCoord] representation of native GeoCoord class
  GeoCoordRadians toPure() {
    return GeoCoordRadians(
      lat: lat,
      lon: lon,
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
