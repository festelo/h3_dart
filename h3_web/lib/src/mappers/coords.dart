import 'dart:js_interop';

import 'package:h3_common/h3_common.dart';
import 'package:h3_web/src/js/h3_js.dart';

extension GeoCoordToJS on GeoCoord {
  JSCoordPair toH3JS() => [lat.toJS, lon.toJS].toJS;
}

extension GeoCoordListToJS on Iterable<GeoCoord> {
  JSLoop toH3JS() => [for (final e in this) e.toH3JS()].toJS;
}

extension JSCoordPairToGeoCoord on JSCoordPair {
  GeoCoord toGeoCoord() {
    final pair = toDart;
    return GeoCoord(lat: pair[0].toDartDouble, lon: pair[1].toDartDouble);
  }
}

extension JSLoopToGeoCoords on JSLoop {
  List<GeoCoord> toGeoCoords() => [for (final e in toDart) e.toGeoCoord()];
}

/// Builds the h3-js polygon input: the perimeter first, then each hole.
JSArray<JSLoop> polygonToH3JS(
  List<GeoCoord> perimeter,
  List<List<GeoCoord>> holes,
) =>
    [perimeter.toH3JS(), for (final hole in holes) hole.toH3JS()].toJS;
