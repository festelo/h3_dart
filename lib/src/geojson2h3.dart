import 'h3.dart';

const _featureCollection = 'FeatureCollection';
const _feature = 'Feature';
const _polygon = 'Polygon';

/// Provides access to Geojson2H3 functions.
///
/// You should not construct the class directly, use [geojson2H3] singletone instead.
class Geojson2H3 {
  Geojson2H3(this._h3);

  final H3 _h3;

  /// Converts a single H3 hexagon with index [h3Index] to a `Polygon` feature
  ///
  /// It's possible to add optional feature [properties]
  Map h3ToFeature(int h3Index, {Map? properties}) {
    final boundary = _h3.h3ToGeoBoundary(h3Index);
    // Wrap in an array for a single-loop polygon
    final coordinates = [
      [
        for (final b in boundary) [b.lon, b.lat],
        [boundary.first.lon, boundary.first.lat],
      ],
    ];
    return {
      'type': _feature,
      'id': h3Index,
      'geometry': {
        'type': _polygon,
        'coordinates': coordinates,
      },
      if (properties != null) 'properties': properties,
    };
  }

  /// Convert a list of [hexagons] to a GeoJSON `FeatureCollection` with each hexagon
  /// in a separate `Polygon` feature with optional [properties].
  Map<String, dynamic> h3SetToFeatureCollection(List<int> hexagons,
      {Map? properties}) {
    final features = hexagons
        .map(
          (e) => h3ToFeature(e, properties: properties),
        )
        .toList();
    return {
      'type': _featureCollection,
      'features': features,
    };
  }
}
