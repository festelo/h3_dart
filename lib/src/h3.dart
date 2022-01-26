import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'generated/generated_bindings.dart' as c;
import 'geo_coord.dart';

class H3 {
  H3(this._h3c);

  final c.H3C _h3c;

  int maxPolyfillSize({
    required List<GeoCoord> coordinates,
    required int resolution,
  }) {
    final nativeCoordinatesPointer = calloc<c.GeoCoord>(coordinates.length);
    for (var i = 0; i < coordinates.length; i++) {
      final pointer = Pointer<c.GeoCoord>.fromAddress(
        nativeCoordinatesPointer.address + sizeOf<c.GeoCoord>() * i,
      );
      coordinates[i].toNative(pointer);
    }

    final polygon = calloc<c.GeoPolygon>();
    final geofence = calloc<c.Geofence>();
    polygon.ref.geofence = geofence.ref;
    polygon.ref.geofence.verts = nativeCoordinatesPointer;
    polygon.ref.geofence.numVerts = coordinates.length;
    polygon.ref.numHoles = 0;
    polygon.ref.holes = Pointer.fromAddress(0);
    return _h3c.maxPolyfillSize(polygon, resolution);
  }

  List<int> polyfill({
    required List<GeoCoord> coordinates,
    required int resolution,
  }) {
    final nbIndex =
        maxPolyfillSize(coordinates: coordinates, resolution: resolution);

    final nativeCoordinatesPointer = calloc<c.GeoCoord>(coordinates.length);
    for (var i = 0; i < coordinates.length; i++) {
      final pointer = Pointer<c.GeoCoord>.fromAddress(
        nativeCoordinatesPointer.address + sizeOf<c.GeoCoord>() * i,
      );
      coordinates[i].toNative(pointer);
    }

    final polygon = calloc<c.GeoPolygon>();
    final geofence = calloc<c.Geofence>();
    polygon.ref.geofence = geofence.ref;
    polygon.ref.geofence.verts = nativeCoordinatesPointer;
    polygon.ref.geofence.numVerts = coordinates.length;
    polygon.ref.numHoles = 0;
    polygon.ref.holes = Pointer.fromAddress(0);

    final out = calloc<Uint64>(nbIndex);
    _h3c.polyfill(polygon, resolution, out);
    final list = out.asTypedList(nbIndex).toList();
    return list.where((e) => e != 0).toList();
  }

  List<GeoCoord> h3ToGeoBoundary(int h3Index) {
    final geoBoundary = calloc<c.GeoBoundary>();
    _h3c.h3ToGeoBoundary(h3Index, geoBoundary);
    final res = <GeoCoord>[];
    for (var i = 0; i < geoBoundary.ref.numVerts; i++) {
      final vert = geoBoundary.ref.verts[i];
      res.add(GeoCoord(radsToDegs(vert.lon), radsToDegs(vert.lat)));
    }
    return res;
  }

  double radsToDegs(double val) => _h3c.radsToDegs(val);
  double degsToRads(double val) => _h3c.degsToRads(val);
}
