import 'h3.dart';

const featureCollection = 'FeatureCollection';
const feature = 'Feature';
const polygon = 'Polygon';

class Geojson2H3 {
  Geojson2H3(this._h3);

  final H3 _h3;

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
      'type': feature,
      'id': h3Index,
      'geometry': {
        'type': polygon,
        'coordinates': coordinates,
      },
      if (properties != null) 'properties': properties,
    };
  }

  Map<String, dynamic> h3SetToFeatureCollection(List<int> hexagons,
      {Map? properties}) {
    final features = hexagons
        .map(
          (e) => h3ToFeature(e, properties: properties),
        )
        .toList();
    return {
      'type': featureCollection,
      'features': features,
    };
  }
}
