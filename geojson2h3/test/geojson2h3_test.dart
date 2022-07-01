import 'dart:convert';

import 'package:geojson2h3/geojson2h3.dart';
import 'package:h3_common/h3_common.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'geojson2h3_test.mocks.dart';

@GenerateMocks([H3])
void main() {
  final h3 = MockH3();
  final geojson2H3 = Geojson2H3(h3);

  when(h3.h3ToGeoBoundary(BigInt.from(0x89283082837ffff))).thenAnswer(
    (_) => [
      GeoCoord(lon: -122.42778275313196, lat: 37.77598951883772),
      GeoCoord(lon: -122.42671162907995, lat: 37.77767221484916),
      GeoCoord(lon: -122.42797132395157, lat: 37.7791765946462),
      GeoCoord(lon: -122.43030214180568, lat: 37.778998255103545),
      GeoCoord(lon: -122.4313731964829, lat: 37.77731555898802),
      GeoCoord(lon: -122.43011350268341, lat: 37.77581120251895),
    ],
  );
  when(h3.h3ToGeoBoundary(BigInt.from(0x89283085507ffff))).thenAnswer(
    (_) => [
      GeoCoord(lon: -122.4748582327671, lat: 37.85878356045377),
      GeoCoord(lon: -122.47378734444061, lat: 37.86046562198416),
      GeoCoord(lon: -122.47504834087832, lat: 37.86196795698973),
      GeoCoord(lon: -122.4773802244202, lat: 37.86178820718911),
      GeoCoord(lon: -122.47845104316994, lat: 37.860106145633125),
      GeoCoord(lon: -122.47719004795714, lat: 37.85860383390306),
    ],
  );

  when(h3.h3ToGeoBoundary(BigInt.from(0x892830855b3ffff))).thenAnswer(
    (_) => [
      GeoCoord(lon: -122.48147295617734, lat: 37.85187534491365),
      GeoCoord(lon: -122.48040229236013, lat: 37.85355749750207),
      GeoCoord(lon: -122.48166324644576, lat: 37.85505983954852),
      GeoCoord(lon: -122.4839948631053, lat: 37.85488000572599),
      GeoCoord(lon: -122.48506545734226, lat: 37.853197853121515),
      GeoCoord(lon: -122.48380450450256, lat: 37.851695534355315),
    ],
  );

  when(h3.h3ToGeoBoundary(BigInt.from(0x85283473fffffff))).thenAnswer(
    (_) => [
      GeoCoord(lon: -121.91508032705622, lat: 37.27135586673191),
      GeoCoord(lon: -121.86222328902491, lat: 37.353926450852256),
      GeoCoord(lon: -121.92354999630156, lat: 37.42834118609434),
      GeoCoord(lon: -122.03773496427027, lat: 37.42012867767778),
      GeoCoord(lon: -122.09042892904397, lat: 37.33755608435298),
      GeoCoord(lon: -122.02910130918998, lat: 37.26319797461824),
    ],
  );

  test('h3ToFeature', () async {
    final hexagon = BigInt.from(0x89283082837ffff);
    final coordinates = h3.h3ToGeoBoundary(hexagon);
    coordinates.add(coordinates.first); // close loop
    final feature = {
      'id': hexagon.toString(),
      'type': 'Feature',
      'properties': {},
      'geometry': {
        'type': 'Polygon',
        'coordinates': [
          [
            for (final coordinate in coordinates)
              [coordinate.lon, coordinate.lat]
          ],
        ],
      }
    };

    expect(
      geojson2H3.h3ToFeature(hexagon),
      feature,
      reason: 'h3ToFeature matches expected',
    );
  });
  test('h3SetToFeatureCollection', () async {
    final hexagons = [
      BigInt.from(0x89283085507ffff),
      BigInt.from(0x892830855b3ffff),
      BigInt.from(0x85283473fffffff)
    ];
    final properties = {
      BigInt.from(0x89283085507ffff): {'foo': 1},
      BigInt.from(0x892830855b3ffff): {'bar': 'baz'},
    };

    final result = geojson2H3.h3SetToFeatureCollection(
      hexagons,
      properties: (h3) => properties[h3],
    );

    expect(
      result['features'][0]['properties'],
      properties[hexagons[0]],
      reason: 'Properties match expected for hexagon',
    );

    expect(
      result['features'][1]['properties'],
      properties[hexagons[1]],
      reason: 'Properties match expected for hexagon',
    );

    expect(
      result['features'][2]['properties'],
      {},
      reason: 'Null property resolved to {}',
    );
  });
}
