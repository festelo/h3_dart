import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'generated/generated_bindings.dart' as c;
import 'models/geo_coord.dart';
import 'mappers/native.dart';

/// Provides access to H3 functions.
///
/// You should not construct the class directly, use [h3] singletone instead.
class H3 {
  H3(this._h3c);

  final c.H3C _h3c;

  /// Takes a given [coordinates] and [resolution] and returns hexagons that
  /// are contained by them.
  ///
  /// [resolution] must be in the range [0, 15].
  ///
  /// This implementation traces the GeoJSON geofence(s) in cartesian space with
  /// hexagons, tests them and their neighbors to be contained by the geofence(s),
  /// and then any newly found hexagons are used to test again until no new
  /// hexagons are found.
  ///
  /// ```dart
  /// final hexagons = h3.polyfill(
  ///   coordinates: const [
  ///     GeoCoord(lat: 37.813318999983238, lon: -122.4089866999972145),
  ///     GeoCoord(lat: 37.7866302000007224, lon: -122.3805436999997056),
  ///     GeoCoord(lat: 37.7198061999978478, lon: -122.3544736999993603),
  ///     GeoCoord(lat: 37.7076131999975672, lon: -122.5123436999983966),
  ///     GeoCoord(lat: 37.7835871999971715, lon: -122.5247187000021967),
  ///     GeoCoord(lat: 37.8151571999998453, lon: -122.4798767000009008),
  ///   ],
  ///   resolution: 9,
  /// )
  /// ```
  List<int> polyfill({
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

    final nbIndex = _h3c.maxPolyfillSize(polygon, resolution);

    final out = calloc<Uint64>(nbIndex);
    _h3c.polyfill(polygon, resolution, out);
    final list = out.asTypedList(nbIndex).toList();
    return list.where((e) => e != 0).toList();
  }

  /// Gives the cell boundary in lat/lon coordinates for the cell with index [h3Index]
  ///
  /// ```dart
  /// h3.h3ToGeoBoundary(0x85283473fffffff)
  /// h3.h3ToGeoBoundary(133)
  /// ```
  List<GeoCoord> h3ToGeoBoundary(int h3Index) {
    final geoBoundary = calloc<c.GeoBoundary>();
    _h3c.h3ToGeoBoundary(h3Index, geoBoundary);
    final res = <GeoCoord>[];
    for (var i = 0; i < geoBoundary.ref.numVerts; i++) {
      final vert = geoBoundary.ref.verts[i];
      res.add(GeoCoord(lon: radsToDegs(vert.lon), lat: radsToDegs(vert.lat)));
    }
    return res;
  }

  /// Converts radians to degrees
  double radsToDegs(double val) => _h3c.radsToDegs(val);

  /// Converts degrees to radians
  double degsToRads(double val) => _h3c.degsToRads(val);
}
