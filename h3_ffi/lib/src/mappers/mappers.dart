import 'dart:ffi';
import 'dart:typed_data';

import 'package:h3_common/h3_common.dart';
import 'package:h3_ffi/src/generated/generated_bindings.dart' as c;

extension H3IndexToNativeMapperExtension on H3Index {
  int toNative() => toInt();
}

extension Uint64ToH3IndexMapperExtension on Pointer<Uint64> {
  H3Index toH3Index() {
    if (value >= 0) {
      return BigInt.from(value);
    } else {
      // value is negative, so add 2^64 to get the correct unsigned value
      return BigInt.from(value) + (BigInt.one << 64);
    }
  }
}

extension Uint64ListToH3IndexListMapperExtension on Uint64List {
  List<H3Index> toH3IndexList() {
    final bytes = buffer.asUint8List();
    final result = <BigInt>[];

    for (var i = 0; i < bytes.length; i += 8) {
      BigInt value = BigInt.zero;
      for (var j = 0; j < 8; j++) {
        value |= BigInt.from(bytes[i + j]) << (8 * j);
      }
      if (value == BigInt.zero) {
        continue;
      }
      result.add(value);
    }

    return result;
  }
}

extension GeoCoordToNativeMapperExtension on GeoCoordRadians {
  /// Returns native representation of GeoCoord class
  Pointer<c.LatLng> toNative(Allocator allocator) {
    final pointer = allocator<c.LatLng>();
    assignToNative(pointer.ref);
    return pointer;
  }

  void assignToNative(c.LatLng ref) {
    ref.lat = lat;
    ref.lng = lon;
  }
}

extension GeoCoordFromNativeMapperExtension on c.LatLng {
  /// Returns [GeoCoord] representation of native GeoCoord class
  GeoCoordRadians toDart() {
    return GeoCoordRadians(
      lat: lat,
      lon: lng,
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
  CoordIJ toDart() {
    return CoordIJ(
      i: i,
      j: j,
    );
  }
}

extension GeoPolygonToNativeMapperExtension on c.GeoPolygon {
  void assign({
    required List<GeoCoord> perimeter,
    List<List<GeoCoord>> holes = const [],
    required GeoCoordConverter converter,
    required Allocator allocator,
  }) {
    geoloop.assign(
      perimeter,
      converter: converter,
      allocator: allocator,
    );

    this.holes = allocator(holes.length);
    numHoles = holes.length;
    for (var i = 0; i < holes.length; i++) {
      final hole = this.holes + i;
      hole.ref.assign(
        holes[i],
        converter: converter,
        allocator: allocator,
      );
    }
  }
}

extension GeoLoopToNativeMapperExtension on c.GeoLoop {
  void assign(
    List<GeoCoord> loop, {
    required GeoCoordConverter converter,
    required Allocator allocator,
  }) {
    numVerts = loop.length;
    verts = allocator(loop.length);
    for (var i = 0; i < loop.length; i++) {
      final vert = verts + i;
      loop[i].toRadians(converter).assignToNative(vert.ref);
    }
  }
}

extension LinkedGeoPolygonToNativeMapperExtension on c.LinkedGeoPolygon {
  List<List<List<GeoCoord>>> toDart({
    required GeoCoordConverter converter,
  }) {
    final res = <List<List<GeoCoord>>>[];
    var polygon = this;

    for (var i = 0;; i++) {
      res.add(
        polygon.first.ref.toDart(
          converter: converter,
        ),
      );

      if (polygon.next == nullptr) {
        break;
      }
      polygon = polygon.next.ref;
    }
    return res;
  }
}

extension LinkedGeoLoopToNativeMapperExtension on c.LinkedGeoLoop {
  List<List<GeoCoord>> toDart({
    required GeoCoordConverter converter,
  }) {
    final res = <List<GeoCoord>>[];
    var loop = this;

    for (var i = 0;; i++) {
      res.add(loop.first.ref.toDart(converter: converter));

      if (loop.next == nullptr) {
        break;
      }
      loop = loop.next.ref;
    }
    return res;
  }
}

extension LinkedLatLngToNativeMapperExtension on c.LinkedLatLng {
  List<GeoCoord> toDart({
    required GeoCoordConverter converter,
  }) {
    final res = <GeoCoord>[];
    var latlng = this;

    for (var i = 0;; i++) {
      res.add(latlng.vertex.toDart().toDegrees(converter));

      if (latlng.next == nullptr) {
        break;
      }
      latlng = latlng.next.ref;
    }
    return res;
  }
}
