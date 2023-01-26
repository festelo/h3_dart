@TestOn('browser')
library h3_web.test.web.h3_test;

import 'dart:math';

import 'package:test/test.dart';
import 'package:h3_web/h3_web.dart';
import 'package:collection/collection.dart';

import 'common.dart';
import 'h3_js_injector.dart';

void main() async {
  await inject('https://unpkg.com/h3-js@3.7.2');

  final h3 = H3Web();

  test('h3IsValid', () async {
    expect(
      h3.h3IsValid(BigInt.parse('0x85283473fffffff')),
      true,
      reason: 'H3 index is considered an index',
    );
    expect(
      h3.h3IsValid(BigInt.parse('0x821C37FFFFFFFFF')),
      true,
      reason: 'H3 index in upper case is considered an index',
    );
    expect(
      h3.h3IsValid(BigInt.parse('0x085283473fffffff')),
      true,
      reason: 'H3 index with leading zero is considered an index',
    );
    expect(
      !h3.h3IsValid(BigInt.parse('0xff283473fffffff')),
      true,
      reason: 'Hexidecimal string with incorrect bits is not valid',
    );
    for (var res = 0; res < 16; res++) {
      expect(
        h3.h3IsValid(h3.geoToH3(const GeoCoord(lat: 37, lon: -122), res)),
        true,
        reason: 'H3 index is considered an index',
      );
    }
  });
  test('geoToH3', () async {
    expect(
      h3.geoToH3(const GeoCoord(lat: 37.3615593, lon: -122.0553238), 5),
      BigInt.parse('0x85283473fffffff'),
      reason: 'Got the expected H3 index back',
    );
    expect(
      h3.geoToH3(const GeoCoord(lat: 30.943387, lon: -164.991559), 5),
      BigInt.parse('0x8547732ffffffff'),
      reason: 'Properly handle 8 Fs',
    );
    expect(
      h3.geoToH3(
          const GeoCoord(lat: 46.04189431883772, lon: 71.52790329909925), 15),
      BigInt.parse('0x8f2000000000000'),
      reason: 'Properly handle leading zeros',
    );
    expect(
      h3.geoToH3(const GeoCoord(lat: 37.3615593, lon: -122.0553238 + 360), 5),
      BigInt.parse('0x85283473fffffff'),
      reason: 'world-wrapping lng accepted',
    );
    expect(
      h3.geoToH3(const GeoCoord(lat: 37.3615593, lon: -122.0553238 + 720), 5),
      BigInt.parse('0x85283473fffffff'),
      reason: '2 times world-wrapping lng accepted',
    );
    expect(
      h3.geoToH3(
        const GeoCoord(lat: 37.3615593 + 180, lon: -122.0553238 + 360),
        5,
      ),
      BigInt.parse('0x85283473fffffff'),
      reason: 'world-wrapping lat & lng accepted',
    );
    expect(
      h3.geoToH3(
        const GeoCoord(lat: 37.3615593 - 180, lon: -122.0553238 - 360),
        5,
      ),
      BigInt.parse('0x85283473fffffff'),
      reason: 'world-wrapping lat & lng accepted 2',
    );
  });
  test('h3GetResolution', () async {
    expect(
      () => h3.h3GetResolution(BigInt.parse('-1')),
      throwsA(isA<H3Exception>()),
      reason: 'Throws error when an invalid index is passed',
    );
    for (var res = 0; res < 16; res++) {
      final h3Index = h3.geoToH3(
        const GeoCoord(lat: 37.3615593, lon: -122.0553238),
        res,
      );
      expect(
        h3.h3GetResolution(h3Index),
        res,
        reason: 'Got the expected resolution back',
      );
    }
  });
  test('h3ToGeo', () async {
    expect(
      ComparableGeoCoord.fromGeoCoord(
          h3.h3ToGeo(BigInt.parse('0x85283473fffffff'))),
      ComparableGeoCoord.fromLatLon(
        lat: 37.34579337536848,
        lon: -121.97637597255124,
      ),
      reason: 'lat/lng matches expected',
    );
  });

  group('kRing', () {
    test('k = 1', () async {
      expect(
        const DeepCollectionEquality.unordered().equals(
          h3.kRing(BigInt.parse('0x8928308280fffff'), 1),
          [
            BigInt.parse('0x8928308280fffff'),
            BigInt.parse('0x8928308280bffff'),
            BigInt.parse('0x89283082807ffff'),
            BigInt.parse('0x89283082877ffff'),
            BigInt.parse('0x89283082803ffff'),
            BigInt.parse('0x89283082873ffff'),
            BigInt.parse('0x8928308283bffff'),
          ],
        ),
        true,
      );
    });
    test('k = 2', () async {
      expect(
        const DeepCollectionEquality.unordered().equals(
          h3.kRing(BigInt.parse('0x8928308280fffff'), 2),
          [
            BigInt.parse('0x89283082813ffff'),
            BigInt.parse('0x89283082817ffff'),
            BigInt.parse('0x8928308281bffff'),
            BigInt.parse('0x89283082863ffff'),
            BigInt.parse('0x89283082823ffff'),
            BigInt.parse('0x89283082873ffff'),
            BigInt.parse('0x89283082877ffff'),
            BigInt.parse('0x8928308287bffff'),
            BigInt.parse('0x89283082833ffff'),
            BigInt.parse('0x8928308282bffff'),
            BigInt.parse('0x8928308283bffff'),
            BigInt.parse('0x89283082857ffff'),
            BigInt.parse('0x892830828abffff'),
            BigInt.parse('0x89283082847ffff'),
            BigInt.parse('0x89283082867ffff'),
            BigInt.parse('0x89283082803ffff'),
            BigInt.parse('0x89283082807ffff'),
            BigInt.parse('0x8928308280bffff'),
            BigInt.parse('0x8928308280fffff')
          ],
        ),
        true,
      );
    });
    test('Bad Radius', () async {
      expect(
        const DeepCollectionEquality.unordered().equals(
          h3.kRing(BigInt.parse('0x8928308280fffff'), -7),
          [BigInt.parse('0x8928308280fffff')],
        ),
        true,
      );
    });
    test('Pentagon', () async {
      expect(
        const DeepCollectionEquality.unordered().equals(
          h3.kRing(BigInt.parse('0x821c07fffffffff'), 1),
          [
            BigInt.parse('0x821c2ffffffffff'),
            BigInt.parse('0x821c27fffffffff'),
            BigInt.parse('0x821c07fffffffff'),
            BigInt.parse('0x821c17fffffffff'),
            BigInt.parse('0x821c1ffffffffff'),
            BigInt.parse('0x821c37fffffffff'),
          ],
        ),
        true,
      );
    });
    test('Edge case', () async {
      // In H3-JS there was an issue reading particular 64-bit integers correctly,
      // this kRing ran into it.
      // Check it just in case
      expect(
        const DeepCollectionEquality.unordered().equals(
          h3.kRing(BigInt.parse('0x8928308324bffff'), 1),
          [
            BigInt.parse('0x8928308324bffff'),
            BigInt.parse('0x892830989b3ffff'),
            BigInt.parse('0x89283098987ffff'),
            BigInt.parse('0x89283098997ffff'),
            BigInt.parse('0x8928308325bffff'),
            BigInt.parse('0x89283083243ffff'),
            BigInt.parse('0x8928308324fffff'),
          ],
        ),
        true,
      );
    });
  });

  group('hexRing', () {
    test('ringSize = 1', () async {
      expect(
        const DeepCollectionEquality.unordered().equals(
          h3.hexRing(BigInt.parse('0x8928308280fffff'), 1),
          [
            BigInt.parse('0x8928308280bffff'),
            BigInt.parse('0x89283082807ffff'),
            BigInt.parse('0x89283082877ffff'),
            BigInt.parse('0x89283082803ffff'),
            BigInt.parse('0x89283082873ffff'),
            BigInt.parse('0x8928308283bffff'),
          ],
        ),
        true,
      );
    });
    test('ringSize = 2', () async {
      expect(
        const DeepCollectionEquality.unordered().equals(
          h3.hexRing(BigInt.parse('0x8928308280fffff'), 2),
          [
            BigInt.parse('0x89283082813ffff'),
            BigInt.parse('0x89283082817ffff'),
            BigInt.parse('0x8928308281bffff'),
            BigInt.parse('0x89283082863ffff'),
            BigInt.parse('0x89283082823ffff'),
            BigInt.parse('0x8928308287bffff'),
            BigInt.parse('0x89283082833ffff'),
            BigInt.parse('0x8928308282bffff'),
            BigInt.parse('0x89283082857ffff'),
            BigInt.parse('0x892830828abffff'),
            BigInt.parse('0x89283082847ffff'),
            BigInt.parse('0x89283082867ffff'),
          ],
        ),
        true,
      );
    });
    test('ringSize = 0', () async {
      expect(
        const DeepCollectionEquality.unordered().equals(
          h3.hexRing(BigInt.parse('0x8928308280fffff'), 0),
          [BigInt.parse('0x8928308280fffff')],
        ),
        true,
      );
    });
    test('Pentagon', () async {
      expect(
        () => h3.hexRing(BigInt.parse('0x821c07fffffffff'), 2),
        throwsA(isA<H3Exception>()),
        reason: 'Throws with a pentagon origin',
      );
      expect(
        () => h3.hexRing(BigInt.parse('0x821c2ffffffffff'), 1),
        throwsA(isA<H3Exception>()),
        reason: 'Throws with a pentagon in the ring itself',
      );
      expect(
        () => h3.hexRing(BigInt.parse('0x821c2ffffffffff'), 5),
        throwsA(isA<H3Exception>()),
        reason: 'Throws with a pentagon inside the ring',
      );
    });
  });
  test('radsToDegs', () async {
    expect(h3.radsToDegs(pi / 2), 90);
    expect(h3.radsToDegs(pi), 180);
    expect(h3.radsToDegs(pi * 2), 360);
    expect(h3.radsToDegs(pi * 4), 720);
  });
  test('degsToRads', () async {
    expect(h3.degsToRads(90), pi / 2);
    expect(h3.degsToRads(180), pi);
    expect(h3.degsToRads(360), pi * 2);
    expect(h3.degsToRads(720), pi * 4);
  });
  group('h3ToGeoBoundary', () {
    test('Hexagon', () async {
      final coordinates = h3.h3ToGeoBoundary(BigInt.parse('0x85283473fffffff'));
      const expectedCoordinates = [
        GeoCoord(lat: 37.271355866731895, lon: -121.91508032705622),
        GeoCoord(lat: 37.353926450852256, lon: -121.86222328902491),
        GeoCoord(lat: 37.42834118609435, lon: -121.9235499963016),
        GeoCoord(lat: 37.42012867767778, lon: -122.0377349642703),
        GeoCoord(lat: 37.33755608435298, lon: -122.09042892904395),
        GeoCoord(lat: 37.26319797461824, lon: -122.02910130919)
      ];
      expect(
        coordinates.map((e) => ComparableGeoCoord.fromGeoCoord(e)).toList(),
        expectedCoordinates
            .map((e) => ComparableGeoCoord.fromGeoCoord(e))
            .toList(),
      );
    });

    test('10-Vertex Pentagon', () async {
      final coordinates = h3.h3ToGeoBoundary(BigInt.parse('0x81623ffffffffff'));
      const expectedCoordinates = [
        GeoCoord(lat: 12.754829243237463, lon: 55.94007484027043),
        GeoCoord(lat: 10.2969712272183, lon: 55.17817579309866),
        GeoCoord(lat: 9.092686031788567, lon: 55.25056228923791),
        GeoCoord(lat: 7.616228142303126, lon: 57.375161319501046),
        GeoCoord(lat: 7.3020872486093165, lon: 58.549882762724735),
        GeoCoord(lat: 8.825639135958125, lon: 60.638711994711066),
        GeoCoord(lat: 9.83036925628956, lon: 61.315435771664625),
        GeoCoord(lat: 12.271971829831212, lon: 60.50225323351279),
        GeoCoord(lat: 13.216340916028164, lon: 59.73257508857316),
        GeoCoord(lat: 13.191260466758202, lon: 57.09422507335292),
      ];
      expect(
        coordinates.map((e) => ComparableGeoCoord.fromGeoCoord(e)).toList(),
        expectedCoordinates
            .map((e) => ComparableGeoCoord.fromGeoCoord(e))
            .toList(),
      );
    });
  });
  group('polyfill', () {
    test('Hexagon', () async {
      final hexagons = h3.polyfill(
        coordinates: const [
          GeoCoord(lat: 37.813318999983238, lon: -122.4089866999972145),
          GeoCoord(lat: 37.7866302000007224, lon: -122.3805436999997056),
          GeoCoord(lat: 37.7198061999978478, lon: -122.3544736999993603),
          GeoCoord(lat: 37.7076131999975672, lon: -122.5123436999983966),
          GeoCoord(lat: 37.7835871999971715, lon: -122.5247187000021967),
          GeoCoord(lat: 37.8151571999998453, lon: -122.4798767000009008),
        ],
        resolution: 9,
      );
      expect(
        hexagons.length,
        1253,
      );
    });

    test('Hexagon with holes', () async {
      final resolution = 5;
      // wkt: POLYGON ((35 10, 45 45, 15 40, 10 20, 35 10),(20 30, 35 35, 30 20, 20 30))
      final hexagons = h3.polyfill(
        coordinates: const [
          GeoCoord(lon: 35, lat: 10),
          GeoCoord(lon: 45, lat: 45),
          GeoCoord(lon: 15, lat: 40),
          GeoCoord(lon: 10, lat: 20),
          GeoCoord(lon: 35, lat: 10)
        ],
        holes: const [
          [
            GeoCoord(lon: 20, lat: 30),
            GeoCoord(lon: 35, lat: 35),
            GeoCoord(lon: 30, lat: 20),
            GeoCoord(lon: 20, lat: 30)
          ]
        ],
        resolution: resolution,
      );

      // point inside the hole 28.037109375000004 28.84467368077179 (this should be classified as outside)
      //point inside 18.45703125 21.616579336740614
      //point outside (far away) 52.55859375 23.48340065432562

      final insideHoleIndex = h3.geoToH3(
          GeoCoord(lon: 28.037109375000004, lat: 28.84467368077179),
          resolution);
      expect(hexagons.contains(insideHoleIndex), false);

      final insideIndex = h3.geoToH3(
          GeoCoord(lon: 18.45703125, lat: 21.616579336740614), resolution);
      expect(hexagons.contains(insideIndex), true);

      final outsideIndex = h3.geoToH3(
          GeoCoord(lon: 52.55859375, lat: 23.48340065432562), resolution);
      expect(hexagons.contains(outsideIndex), false);
    });

    test('Transmeridian', () async {
      final hexagons = h3.polyfill(
        coordinates: const [
          GeoCoord(lat: 0.5729577951308232, lon: -179.4270422048692),
          GeoCoord(lat: 0.5729577951308232, lon: 179.4270422048692),
          GeoCoord(lat: -0.5729577951308232, lon: 179.4270422048692),
          GeoCoord(lat: -0.5729577951308232, lon: -179.4270422048692),
        ],
        resolution: 7,
      );
      expect(
        hexagons.length,
        4238,
      );
    });

    test('Empty', () async {
      final hexagons = h3.polyfill(
        coordinates: const [],
        resolution: 9,
      );
      expect(
        hexagons.length,
        0,
      );
    });

    test('Negative resolution', () async {
      expect(
        () => h3.polyfill(
          coordinates: const [
            GeoCoord(lat: 0.5729577951308232, lon: -179.4270422048692),
            GeoCoord(lat: 0.5729577951308232, lon: 179.4270422048692),
            GeoCoord(lat: -0.5729577951308232, lon: 179.4270422048692),
            GeoCoord(lat: -0.5729577951308232, lon: -179.4270422048692),
          ],
          resolution: -9,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('compact and uncompact', () {
    test('Basic', () async {
      final hexagons = h3.polyfill(
        coordinates: [
          const GeoCoord(lat: 37.813318999983238, lon: -122.4089866999972145),
          const GeoCoord(lat: 37.7866302000007224, lon: -122.3805436999997056),
          const GeoCoord(lat: 37.7198061999978478, lon: -122.3544736999993603),
          const GeoCoord(lat: 37.7076131999975672, lon: -122.5123436999983966),
          const GeoCoord(lat: 37.7835871999971715, lon: -122.5247187000021967),
          const GeoCoord(lat: 37.8151571999998453, lon: -122.4798767000009008),
        ],
        resolution: 9,
      );
      final compactedHexagons = h3.compact(hexagons);
      expect(compactedHexagons.length, 209);
      final uncompactedHexagons = h3.uncompact(
        compactedHexagons,
        resolution: 9,
      );
      expect(uncompactedHexagons.length, 1253);
    });

    test('Compact - Empty', () async {
      expect(h3.compact([]).length, 0);
    });

    test('Uncompact - Empty', () async {
      expect(h3.uncompact([], resolution: 9).length, 0);
    });

    test('Ignore duplicates', () async {
      final hexagons = h3.polyfill(
        coordinates: [
          const GeoCoord(lat: 37.813318999983238, lon: -122.4089866999972145),
          const GeoCoord(lat: 37.813318999983238, lon: -122.4089866999972145),
          const GeoCoord(lat: 37.813318999983238, lon: -122.4089866999972145),
          const GeoCoord(lat: 37.7866302000007224, lon: -122.3805436999997056),
          const GeoCoord(lat: 37.7198061999978478, lon: -122.3544736999993603),
          const GeoCoord(lat: 37.7076131999975672, lon: -122.5123436999983966),
          const GeoCoord(lat: 37.7835871999971715, lon: -122.5247187000021967),
          const GeoCoord(lat: 37.8151571999998453, lon: -122.4798767000009008),
        ],
        resolution: 9,
      );
      final compactedHexagons = h3.compact(hexagons);
      expect(compactedHexagons.length, 209);
      final uncompactedHexagons = h3.uncompact(
        compactedHexagons,
        resolution: 9,
      );
      expect(uncompactedHexagons.length, 1253);
    });

    test('Uncompact - Invalid', () async {
      expect(
        () => h3.uncompact(
          [h3.geoToH3(const GeoCoord(lat: 37.3615593, lon: -122.0553238), 10)],
          resolution: 5,
        ),
        throwsA(isA<H3Exception>()),
      );
    });
  });
  test('h3IsPentagon', () async {
    expect(
      h3.h3IsPentagon(BigInt.parse('0x8928308280fffff')),
      false,
    );
    expect(
      h3.h3IsPentagon(BigInt.parse('0x821c07fffffffff')),
      true,
    );
    expect(
      h3.h3IsPentagon(BigInt.parse('0x0')),
      false,
    );
  });
  test('h3IsResClassIII', () async {
    // Test all even indexes
    for (var i = 0; i < 15; i += 2) {
      final h3Index = h3.geoToH3(
        const GeoCoord(lat: 37.3615593, lon: -122.0553238),
        i,
      );
      expect(h3.h3IsResClassIII(h3Index), false);
    }
    // Test all odd indexes
    for (var i = 1; i < 15; i += 2) {
      final h3Index = h3.geoToH3(
        const GeoCoord(lat: 37.3615593, lon: -122.0553238),
        i,
      );
      expect(h3.h3IsResClassIII(h3Index), true);
    }
  });
  test('h3GetFaces', () async {
    void testFace(String name, BigInt h3Index, int expected) {
      final faces = h3.h3GetFaces(h3Index);

      expect(
        faces.length,
        expected,
        reason: 'Got expected face count for $name',
      );
      expect(
        faces.toSet().length,
        expected,
        reason: 'Faces are unique for $name',
      );
      expect(
        faces.every((e) => e >= 0 && e < 20),
        true,
        reason: ' face indexes in expected range for $name',
      );
    }

    testFace('single face', BigInt.parse('0x85283473fffffff'), 1);
    testFace('edge adjacent', BigInt.parse('0x821c37fffffffff'), 1);
    testFace('edge crossing, distorted', BigInt.parse('0x831c06fffffffff'), 2);
    testFace('edge crossing, aligned', BigInt.parse('0x821ce7fffffffff'), 2);
    testFace('class II pentagon', BigInt.parse('0x84a6001ffffffff'), 5);
    testFace('class III pentagon', BigInt.parse('0x85a60003fffffff'), 5);
  });

  test('h3GetBaseCell', () async {
    expect(h3.h3GetBaseCell(BigInt.parse('0x8928308280fffff')), 20);
  });

  group('h3ToParent', () {
    test('Basic', () async {
      // NB: This test will not work with every hexagon, it has to be a location
      // that does not fall in the margin of error between the 7 children and
      // the parent's true boundaries at every resolution
      const lat = 37.81331899988944;
      const lng = -122.409290778685;
      for (var res = 1; res < 10; res++) {
        for (var step = 0; step < res; step++) {
          final child = h3.geoToH3(const GeoCoord(lat: lat, lon: lng), res);

          final comparisonParent =
              h3.geoToH3(const GeoCoord(lat: lat, lon: lng), res - step);

          final parent = h3.h3ToParent(child, res - step);
          expect(
            parent,
            comparisonParent,
            reason: 'Got expected parent for $res:${res - step}',
          );
        }
      }
    });
    test('Invalid', () async {
      final h3Index = BigInt.parse('0x8928308280fffff');

      expect(
        h3.h3ToParent(h3Index, 10),
        BigInt.zero,
        reason: 'Finer resolution returns zero',
      );

      expect(
        h3.h3ToParent(h3Index, -1),
        BigInt.zero,
        reason: 'Invalid resolution returns zero',
      );
    });
  });

  test('h3ToChildren', () async {
    const lat = 37.81331899988944;
    const lng = -122.409290778685;
    final h3Index = h3.geoToH3(const GeoCoord(lat: lat, lon: lng), 7);

    expect(h3.h3ToChildren(h3Index, 8).length, 7,
        reason: 'Immediate child count correct');

    expect(h3.h3ToChildren(h3Index, 9).length, 49,
        reason: 'Grandchild count correct');

    expect(h3.h3ToChildren(h3Index, 7), [h3Index],
        reason: 'Same resolution returns self');

    expect(h3.h3ToChildren(h3Index, 6), [],
        reason: 'Coarser resolution returns empty array');

    expect(h3.h3ToChildren(h3Index, -1), [],
        reason: 'Invalid resolution returns empty array');
  });

  group('h3ToCenterChild', () {
    test('Basic', () async {
      final baseIndex = BigInt.parse('0x8029fffffffffff');
      final geo = h3.h3ToGeo(baseIndex);
      for (var res = 0; res < 14; res++) {
        for (var childRes = res; childRes < 15; childRes++) {
          final parent = h3.geoToH3(geo, res);
          final comparisonChild = h3.geoToH3(geo, childRes);
          final child = h3.h3ToCenterChild(parent, childRes);

          expect(
            child,
            comparisonChild,
            reason: 'Got expected center child for $res:$childRes',
          );
        }
      }
    });
    test('Invalid', () async {
      final h3Index = BigInt.parse('0x8928308280fffff');

      expect(h3.h3ToCenterChild(h3Index, 5), BigInt.zero,
          reason: 'Coarser resolution returns zero');

      expect(h3.h3ToCenterChild(h3Index, -1), BigInt.zero,
          reason: 'Invalid resolution returns zero');
    });
  });

  test('h3IndexesAreNeighbors', () async {
    final origin = BigInt.parse('0x891ea6d6533ffff');
    final adjacent = BigInt.parse('0x891ea6d65afffff');
    final notAdjacent = BigInt.parse('0x891ea6992dbffff');

    expect(
      h3.h3IndexesAreNeighbors(origin, adjacent),
      true,
      reason: 'Adjacent hexagons are neighbors',
    );

    expect(
      h3.h3IndexesAreNeighbors(adjacent, origin),
      true,
      reason: 'Adjacent hexagons are neighbors',
    );

    expect(
      h3.h3IndexesAreNeighbors(origin, notAdjacent),
      false,
      reason: 'Non-adjacent hexagons are not neighbors',
    );

    expect(
      h3.h3IndexesAreNeighbors(origin, origin),
      false,
      reason: 'A hexagon is not a neighbor to itself',
    );

    expect(
      h3.h3IndexesAreNeighbors(origin, BigInt.parse('-1')),
      false,
      reason: 'A hexagon is not a neighbor to an invalid index',
    );

    expect(
      h3.h3IndexesAreNeighbors(origin, BigInt.parse('42')),
      false,
      reason: 'A hexagon is not a neighbor to an invalid index',
    );

    expect(
      h3.h3IndexesAreNeighbors(BigInt.parse('-1'), BigInt.parse('-1')),
      false,
      reason: 'Two invalid indexes are not neighbors',
    );
  });

  test('getH3UnidirectionalEdge', () async {
    final origin = BigInt.parse('0x891ea6d6533ffff');
    final destination = BigInt.parse('0x891ea6d65afffff');
    final edge = BigInt.parse('0x1591ea6d6533ffff');
    final notAdjacent = BigInt.parse('0x891ea6992dbffff');

    expect(
      h3.getH3UnidirectionalEdge(origin, destination),
      edge,
      reason: 'Got expected edge for adjacent hexagons',
    );

    expect(
      h3.getH3UnidirectionalEdge(origin, notAdjacent),
      BigInt.zero,
      reason: 'Got 0 for non-adjacent hexagons',
    );

    expect(
      h3.getH3UnidirectionalEdge(origin, origin),
      BigInt.zero,
      reason: 'Got 0 for same hexagons',
    );

    expect(
      h3.getH3UnidirectionalEdge(origin, BigInt.parse('-1')),
      BigInt.zero,
      reason: 'Got 0 for invalid destination',
    );

    expect(
      h3.getH3UnidirectionalEdge(BigInt.parse('-1'), BigInt.parse('-1')),
      BigInt.zero,
      reason: 'Got 0 for invalid hexagons',
    );
  });

  test('getOriginH3IndexFromUnidirectionalEdge', () async {
    final origin = BigInt.parse('0x891ea6d6533ffff');
    final edge = BigInt.parse('0x1591ea6d6533ffff');

    expect(
      h3.getOriginH3IndexFromUnidirectionalEdge(edge),
      origin,
      reason: 'Got expected origin for edge',
    );

    expect(
      h3.getOriginH3IndexFromUnidirectionalEdge(origin),
      BigInt.zero,
      reason: 'Got 0 for non-edge hexagon',
    );

    expect(
      h3.getOriginH3IndexFromUnidirectionalEdge(BigInt.parse('-1')),
      BigInt.zero,
      reason: 'Got 0 for non-valid hexagon',
    );
  });

  test('getDestinationH3IndexFromUnidirectionalEdge', () async {
    final destination = BigInt.parse('0x891ea6d65afffff');
    final edge = BigInt.parse('0x1591ea6d6533ffff');

    expect(
      h3.getDestinationH3IndexFromUnidirectionalEdge(edge),
      destination,
      reason: 'Got expected origin for edge',
    );

    expect(
      h3.getDestinationH3IndexFromUnidirectionalEdge(destination),
      BigInt.zero,
      reason: 'Got 0 for non-edge hexagon',
    );

    expect(
      h3.getDestinationH3IndexFromUnidirectionalEdge(BigInt.parse('-1')),
      BigInt.zero,
      reason: 'Got 0 for non-valid hexagon',
    );
  });

  test('h3UnidirectionalEdgeIsValid', () async {
    final origin = BigInt.parse('0x891ea6d6533ffff');
    final destination = BigInt.parse('0x891ea6d65afffff');

    expect(
      h3.h3UnidirectionalEdgeIsValid(BigInt.parse('0x1591ea6d6533ffff')),
      true,
      reason: 'Edge index is valid',
    );

    expect(
      h3.h3UnidirectionalEdgeIsValid(
        h3.getH3UnidirectionalEdge(origin, destination),
      ),
      true,
      reason: 'Output of getH3UnidirectionalEdge is valid',
    );

    expect(
      h3.h3UnidirectionalEdgeIsValid(BigInt.parse('-1')),
      false,
      reason: '-1 is not valid',
    );
  });

  test('getH3IndexesFromUnidirectionalEdge', () async {
    final origin = BigInt.parse('0x891ea6d6533ffff');
    final destination = BigInt.parse('0x891ea6d65afffff');
    final edge = BigInt.parse('0x1591ea6d6533ffff');

    expect(
      h3.getH3IndexesFromUnidirectionalEdge(edge),
      [origin, destination],
      reason: 'Got expected origin, destination from edge',
    );

    expect(
      h3.getH3IndexesFromUnidirectionalEdge(
          h3.getH3UnidirectionalEdge(origin, destination)),
      [origin, destination],
      reason:
          'Got expected origin, destination from getH3UnidirectionalEdge output',
    );
  });

  group('getH3UnidirectionalEdgesFromHexagon', () {
    test('Basic', () async {
      final origin = BigInt.parse('0x8928308280fffff');
      final edges = h3.getH3UnidirectionalEdgesFromHexagon(origin);

      expect(
        edges.length,
        6,
        reason: 'got expected edge count',
      );

      final neighbours = h3.hexRing(origin, 1);
      for (final neighbour in neighbours) {
        final edge = h3.getH3UnidirectionalEdge(origin, neighbour);
        expect(
          edges.contains(edge),
          true,
          reason: 'found edge to neighbor',
        );
      }
    });

    test('Pentagon', () async {
      final origin = BigInt.parse('0x81623ffffffffff');
      final edges = h3.getH3UnidirectionalEdgesFromHexagon(origin);

      expect(
        edges.length,
        5,
        reason: 'got expected edge count',
      );

      final neighbours = h3.kRing(origin, 1).where((e) => e != origin).toList();

      for (final neighbour in neighbours) {
        final edge = h3.getH3UnidirectionalEdge(origin, neighbour);
        expect(
          edges.contains(edge),
          true,
          reason: 'found edge to neighbor',
        );
      }
    });
  });

  group('getH3UnidirectionalEdgeBoundary', () {
    test('Basic', () async {
      final origin = BigInt.parse('0x85283473fffffff');
      final edges = h3.getH3UnidirectionalEdgesFromHexagon(origin);

      // GeoBoundary of the origin
      final originBoundary = h3.h3ToGeoBoundary(origin);

      final expectedEdges = [
        [originBoundary[3], originBoundary[4]],
        [originBoundary[1], originBoundary[2]],
        [originBoundary[2], originBoundary[3]],
        [originBoundary[5], originBoundary[0]],
        [originBoundary[4], originBoundary[5]],
        [originBoundary[0], originBoundary[1]]
      ];

      for (var i = 0; i < edges.length; i++) {
        final latlngs = h3.getH3UnidirectionalEdgeBoundary(edges[i]);
        expect(
          latlngs.map((g) => ComparableGeoCoord.fromGeoCoord(g)),
          expectedEdges[i].map((g) => ComparableGeoCoord.fromGeoCoord(g)),
          reason: 'Coordinates match expected for edge $i',
        );
      }
    });

    test('10-vertex pentagon', () async {
      final origin = BigInt.parse('0x81623ffffffffff');
      final edges = h3.getH3UnidirectionalEdgesFromHexagon(origin);

      // GeoBoundary of the origin
      final originBoundary = h3.h3ToGeoBoundary(origin);

      final expectedEdges = [
        [originBoundary[2], originBoundary[3], originBoundary[4]],
        [originBoundary[4], originBoundary[5], originBoundary[6]],
        [originBoundary[8], originBoundary[9], originBoundary[0]],
        [originBoundary[6], originBoundary[7], originBoundary[8]],
        [originBoundary[0], originBoundary[1], originBoundary[2]]
      ];

      for (var i = 0; i < edges.length; i++) {
        final latlngs = h3.getH3UnidirectionalEdgeBoundary(edges[i]);
        expect(
          latlngs.map((g) => ComparableGeoCoord.fromGeoCoord(g)),
          expectedEdges[i].map((g) => ComparableGeoCoord.fromGeoCoord(g)),
          reason: 'Coordinates match expected for edge $i',
        );
      }
    });
  });

  group('h3Distance', () {
    test('Basic', () async {
      final origin = h3.geoToH3(const GeoCoord(lat: 37.5, lon: -122), 9);
      for (var radius = 0; radius < 4; radius++) {
        final others = h3.hexRing(origin, radius);
        for (var i = 0; i < others.length; i++) {
          expect(h3.h3Distance(origin, others[i]), radius,
              reason: 'Got distance $radius for ($origin, ${others[i]})');
        }
      }
    });

    test('Failure', () async {
      final origin = h3.geoToH3(const GeoCoord(lat: 37.5, lon: -122), 9);
      final origin10 = h3.geoToH3(const GeoCoord(lat: 37.5, lon: -122), 10);
      final edge = BigInt.parse('0x1591ea6d6533ffff');
      final distantHex = h3.geoToH3(const GeoCoord(lat: -37.5, lon: 122), 9);

      expect(
        h3.h3Distance(origin, origin10),
        -1,
        reason: 'Returned -1 for distance between different resolutions',
      );
      expect(
        h3.h3Distance(origin, edge),
        -1,
        reason: 'Returned -1 for distance between hexagon and edge',
      );
      expect(
        h3.h3Distance(origin, distantHex),
        -1,
        reason: 'Returned -1 for distance between distant hexagons',
      );
    });
  });

  group('h3Line', () {
    test('Basic', () async {
      for (var res = 0; res < 12; res++) {
        final origin = h3.geoToH3(const GeoCoord(lat: 37.5, lon: -122), res);
        final destination = h3.geoToH3(const GeoCoord(lat: 25, lon: -120), res);
        final line = h3.h3Line(origin, destination);
        final distance = h3.h3Distance(origin, destination);
        expect(
          line.length,
          distance + 1,
          reason: 'distance matches expected: ${distance + 1}',
        );

        // property-based test for the line
        expect(
          line.asMap().entries.every(
                (e) =>
                    e.key == 0 ||
                    h3.h3IndexesAreNeighbors(
                      e.value,
                      line[e.key - 1],
                    ),
              ),
          true,
          reason: 'every index in the line is a neighbor of the previous',
        );
      }
    });

    test('Failure', () async {
      final origin = h3.geoToH3(const GeoCoord(lat: 37.5, lon: -122), 9);
      final origin10 = h3.geoToH3(const GeoCoord(lat: 37.5, lon: -122), 10);

      expect(
        () => h3.h3Line(origin, origin10),
        throwsA(isA<H3Exception>()),
        reason: 'got expected error for different resolutions',
      );
    });
  });

  group('experimentalH3ToLocalIj / experimentalLocalIjToH3', () {
    test('Basic', () async {
      final origin = BigInt.parse('0x8828308281fffff');
      final testValues = {
        origin: const CoordIJ(i: 392, j: 336),
        BigInt.parse('0x882830828dfffff'): const CoordIJ(i: 393, j: 337),
        BigInt.parse('0x8828308285fffff'): const CoordIJ(i: 392, j: 337),
        BigInt.parse('0x8828308287fffff'): const CoordIJ(i: 391, j: 336),
        BigInt.parse('0x8828308283fffff'): const CoordIJ(i: 391, j: 335),
        BigInt.parse('0x882830828bfffff'): const CoordIJ(i: 392, j: 335),
        BigInt.parse('0x8828308289fffff'): const CoordIJ(i: 393, j: 336),
      };
      for (final testValue in testValues.entries) {
        final h3Index = testValue.key;
        final coord = testValue.value;
        expect(
          h3.experimentalH3ToLocalIj(origin, h3Index),
          coord,
          reason: 'Got expected coordinates for $h3Index',
        );
        expect(
          h3.experimentalLocalIjToH3(origin, coord),
          h3Index,
          reason: 'Got expected H3 index for $coord',
        );
      }
    });
    test('Pentagon', () async {
      final origin = BigInt.parse('0x811c3ffffffffff');
      final testValues = {
        origin: const CoordIJ(i: 0, j: 0),
        BigInt.parse('0x811d3ffffffffff'): const CoordIJ(i: 1, j: 0),
        BigInt.parse('0x811cfffffffffff'): const CoordIJ(i: -1, j: 0),
      };

      for (final testValue in testValues.entries) {
        final h3Index = testValue.key;
        final coord = testValue.value;
        expect(
          h3.experimentalH3ToLocalIj(origin, h3Index),
          coord,
          reason: 'Got expected coordinates for $h3Index',
        );
        expect(
          h3.experimentalLocalIjToH3(origin, coord),
          h3Index,
          reason: 'Got expected H3 index for $coord',
        );
      }
    });

    test('Failure', () async {
      // experimentalH3ToLocalIj

      expect(
        () => h3.experimentalH3ToLocalIj(BigInt.parse('0x832830fffffffff'),
            BigInt.parse('0x822837fffffffff')),
        throwsA(isA<H3Exception>()),
        reason: 'Got expected error',
      );
      expect(
        () => h3.experimentalH3ToLocalIj(BigInt.parse('0x822a17fffffffff'),
            BigInt.parse('0x822837fffffffff')),
        throwsA(isA<H3Exception>()),
        reason: 'Got expected error',
      );
      expect(
        () => h3.experimentalH3ToLocalIj(BigInt.parse('0x8828308281fffff'),
            BigInt.parse('0x8841492553fffff')),
        throwsA(isA<H3Exception>()),
        reason: 'Got expected error for opposite sides of the world',
      );
      expect(
        () => h3.experimentalH3ToLocalIj(BigInt.parse('0x81283ffffffffff'),
            BigInt.parse('0x811cbffffffffff')),
        throwsA(isA<H3Exception>()),
        reason: 'Got expected error',
      );
      expect(
        () => h3.experimentalH3ToLocalIj(BigInt.parse('0x811d3ffffffffff'),
            BigInt.parse('0x8122bffffffffff')),
        throwsA(isA<H3Exception>()),
        reason: 'Got expected error',
      );

      // experimentalLocalIjToH3

      expect(
        () => h3.experimentalLocalIjToH3(
          BigInt.parse('0x8049fffffffffff'),
          const CoordIJ(i: 2, j: 0),
        ),
        throwsA(isA<H3Exception>()),
        reason: 'Got expected error when index is not defined',
      );
    });
  });

  group('hexArea', () {
    test('Basic', () async {
      var last = 1e14;
      for (var res = 0; res < 16; res++) {
        final result = h3.hexArea(res, H3AreaUnits.m2);
        expect(
          result < last,
          true,
          reason: 'result < last result: $result, $last',
        );
        last = result;
      }

      last = 1e7;
      for (var res = 0; res < 16; res++) {
        final result = h3.hexArea(res, H3AreaUnits.km2);
        expect(
          result < last,
          true,
          reason: 'result < last result: $result, $last',
        );
        last = result;
      }
    });
    test('Bad resolution', () async {
      expect(
        () => h3.hexArea(42, H3AreaUnits.km2),
        throwsA(isA<AssertionError>()),
        reason: 'throws on invalid resolution',
      );
    });
  });

  group('edgeLength', () {
    test('Basic', () async {
      var last = 1e7;
      for (var res = 0; res < 16; res++) {
        final result = h3.edgeLength(res, H3EdgeLengthUnits.m);
        expect(
          result < last,
          true,
          reason: 'result < last result: $result, $last',
        );
        last = result;
      }

      last = 1e4;
      for (var res = 0; res < 16; res++) {
        final result = h3.edgeLength(res, H3EdgeLengthUnits.km);
        expect(
          result < last,
          true,
          reason: 'result < last result: $result, $last',
        );
        last = result;
      }
    });
    test('Bad resolution', () async {
      expect(
        () => h3.edgeLength(42, H3EdgeLengthUnits.km),
        throwsA(isA<AssertionError>()),
        reason: 'throws on invalid resolution',
      );
    });
  });
  test('cellArea', () async {
    const expectedAreas = [
      2.562182162955496e+06,
      4.476842018179411e+05,
      6.596162242711056e+04,
      9.228872919002590e+03,
      1.318694490797110e+03,
      1.879593512281298e+02,
      2.687164354763186e+01,
      3.840848847060638e+00,
      5.486939641329893e-01,
      7.838600808637444e-02,
      1.119834221989390e-02,
      1.599777169186614e-03,
      2.285390931423380e-04,
      3.264850232091780e-05,
      4.664070326136774e-06,
      6.662957615868888e-07
    ];

    for (var res = 0; res < 16; res++) {
      final h3Index = h3.geoToH3(const GeoCoord(lat: 0, lon: 0), res);
      final cellAreaKm2 = h3.cellArea(h3Index, H3Units.km);
      expect(
        almostEqual(cellAreaKm2, expectedAreas[res]),
        true,
        reason: 'Area matches expected value at res $res',
      );
      final cellAreaM2 = h3.cellArea(h3Index, H3Units.m);
      if (res != 0) {
        // Property tests
        // res 0 has high distortion of average area due to high pentagon proportion
        expect(
          // This seems to be the lowest factor that works for other resolutions
          almostEqual(cellAreaKm2, h3.hexArea(res, H3AreaUnits.km2), 0.4),
          true,
          reason: 'Area is close to average area at res $res, km2',
        );
        expect(
          // This seems to be the lowest factor that works for other resolutions
          almostEqual(cellAreaM2, h3.hexArea(res, H3AreaUnits.m2), 0.4),
          true,
          reason: 'Area is close to average area at res $res, m2',
        );
      }

      expect(
        cellAreaM2 > cellAreaKm2,
        true,
        reason: 'm2 > Km2',
      );

      expect(
        cellAreaKm2 > h3.cellArea(h3Index, H3Units.rad),
        true,
        reason: 'Km2 > rads2',
      );
    }
  });

  test('pointDist', () async {
    expect(
      almostEqual(
        h3.pointDist(
          const GeoCoord(lat: -10, lon: 0),
          const GeoCoord(lat: 10, lon: 0),
          H3Units.rad,
        ),
        h3.degsToRads(20),
      ),
      true,
      reason: 'Got expected angular distance for latitude along the equator',
    );

    expect(
      almostEqual(
        h3.pointDist(
          const GeoCoord(lat: 0, lon: -10),
          const GeoCoord(lat: 0, lon: 10),
          H3Units.rad,
        ),
        h3.degsToRads(20),
      ),
      true,
      reason: 'Got expected angular distance for latitude along a meridian',
    );
    expect(
      h3.pointDist(
        const GeoCoord(lat: 23, lon: 23),
        const GeoCoord(lat: 23, lon: 23),
        H3Units.rad,
      ),
      0,
      reason: 'Got expected angular distance for same point',
    );

    // Just rough tests for the other units
    final distKm = h3.pointDist(const GeoCoord(lat: 0, lon: 0),
        const GeoCoord(lat: 39, lon: -122), H3Units.km);

    expect(
      distKm > 12e3 && distKm < 13e3,
      true,
      reason: 'has some reasonable distance in Km',
    );

    final distM = h3.pointDist(
      const GeoCoord(lat: 0, lon: 0),
      const GeoCoord(lat: 39, lon: -122),
      H3Units.m,
    );

    expect(
      distM > 12e6 && distM < 13e6,
      true,
      reason: 'has some reasonable distance in m',
    );
  });

  test('exactEdgeLength', () async {
    for (var res = 0; res < 16; res++) {
      final h3Index = h3.geoToH3(const GeoCoord(lat: 0, lon: 0), res);
      final edges = h3.getH3UnidirectionalEdgesFromHexagon(h3Index);
      for (var i = 0; i < edges.length; i++) {
        final edge = edges[i];
        final lengthKm = h3.exactEdgeLength(edge, H3Units.km);
        final lengthM = h3.exactEdgeLength(edge, H3Units.m);

        expect(lengthKm > 0, true, reason: 'Has some length');
        expect(lengthM > 0, true, reason: 'Has some length');
        expect(lengthKm * 1000, lengthM, reason: 'km * 1000 = m');

        if (res > 0) {
          // res 0 has high distortion of average edge length due to high pentagon proportion
          expect(
            almostEqual(
              lengthKm,
              h3.edgeLength(res, H3EdgeLengthUnits.km),
              0.2,
            ),
            true,
            reason:
                'Edge length is close to average edge length at res $res, km',
          );
          expect(
            almostEqual(
              lengthM,
              h3.edgeLength(res, H3EdgeLengthUnits.m),
              0.2,
            ),
            true,
            reason:
                'Edge length is close to average edge length at res $res, m',
          );
        }

        expect(
          lengthM > lengthKm,
          true,
          reason: 'm > Km',
        );

        expect(
          lengthKm > h3.exactEdgeLength(edge, H3Units.rad),
          true,
          reason: 'Km > rads',
        );
      }
    }
  });

  test('numHexagons', () async {
    var last = 0;
    for (var res = 0; res < 16; res++) {
      final result = h3.numHexagons(res);
      expect(
        result > last,
        true,
        reason: 'result > last result: $result, $last',
      );
      last = result;
    }

    expect(
      () => h3.numHexagons(42),
      throwsA(isA<AssertionError>()),
      reason: 'throws on invalid resolution',
    );
  });

  test('getRes0Indexes', () async {
    final indexes = h3.getRes0Indexes();
    expect(indexes.length, 122, reason: 'Got expected count');
    expect(indexes.every(h3.h3IsValid), true, reason: 'All indexes are valid');
  });

  test('getPentagonIndexes', () async {
    for (var res = 0; res < 16; res++) {
      final indexes = h3.getPentagonIndexes(res);
      expect(
        indexes.length,
        12,
        reason: 'Got expected count',
      );
      expect(
        indexes.every(h3.h3IsValid),
        true,
        reason: 'All indexes are valid',
      );
      expect(
        indexes.every(h3.h3IsPentagon),
        true,
        reason: 'All indexes are pentagons',
      );
      expect(
        indexes.every((idx) => h3.h3GetResolution(idx) == res),
        true,
        reason: 'All indexes have the right resolution',
      );
      expect(
        indexes.toSet().length,
        indexes.length,
        reason: 'All indexes are unique',
      );
    }

    expect(
      () => h3.getPentagonIndexes(42),
      throwsA(isA<AssertionError>()),
      reason: 'throws on invalid resolution',
    );
  });
}
