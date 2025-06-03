import 'dart:math';

import 'package:h3_common/h3_common.dart';
import 'package:test/test.dart';
import 'package:collection/collection.dart';

import 'models.dart';

void testH3(
  H3 h3, {
  required bool testOutOfBounds,
}) {
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

  test('isValidCell', () async {
    expect(
      h3.isValidCell(BigInt.parse('0x85283473fffffff')),
      true,
      reason: 'H3 index is considered an index',
    );
    expect(
      h3.isValidCell(BigInt.parse('0x821C37FFFFFFFFF')),
      true,
      reason: 'H3 index in upper case is considered an index',
    );
    expect(
      h3.isValidCell(BigInt.parse('0x085283473fffffff')),
      true,
      reason: 'H3 index with leading zero is considered an index',
    );
    expect(
      !h3.isValidCell(BigInt.parse('0xff283473fffffff')),
      true,
      reason: 'Hexidecimal string with incorrect bits is not valid',
    );
    for (var res = 0; res < 16; res++) {
      expect(
        h3.isValidCell(h3.geoToCell(const GeoCoord(lat: 37, lon: -122), res)),
        true,
        reason: 'H3 index is considered an index',
      );
    }
  });
  test('geoToCell', () async {
    expect(
      h3.geoToCell(const GeoCoord(lat: 37.3615593, lon: -122.0553238), 5),
      BigInt.parse('0x85283473fffffff'),
      reason: 'Got the expected H3 index back',
    );
    expect(
      h3.geoToCell(const GeoCoord(lat: 30.943387, lon: -164.991559), 5),
      BigInt.parse('0x8547732ffffffff'),
      reason: 'Properly handle 8 Fs',
    );
    expect(
      h3.geoToCell(
          const GeoCoord(lat: 46.04189431883772, lon: 71.52790329909925), 15),
      BigInt.parse('0x8f2000000000000'),
      reason: 'Properly handle leading zeros',
    );
    expect(
      h3.geoToCell(const GeoCoord(lat: 37.3615593, lon: -122.0553238 + 360), 5),
      BigInt.parse('0x85283473fffffff'),
      reason: 'world-wrapping lng accepted',
    );
    expect(
      h3.geoToCell(const GeoCoord(lat: 37.3615593, lon: -122.0553238 + 720), 5),
      BigInt.parse('0x85283473fffffff'),
      reason: '2 times world-wrapping lng accepted',
    );
    expect(
      h3.geoToCell(
        const GeoCoord(lat: 37.3615593 + 180, lon: -122.0553238 + 360),
        5,
      ),
      BigInt.parse('0x85283473fffffff'),
      reason: 'world-wrapping lat & lng accepted',
    );
    expect(
      h3.geoToCell(
        const GeoCoord(lat: 37.3615593 - 180, lon: -122.0553238 - 360),
        5,
      ),
      BigInt.parse('0x85283473fffffff'),
      reason: 'world-wrapping lat & lng accepted 2',
    );
    final incorrectNumbers = [
      double.infinity,
      double.negativeInfinity,
      double.nan
    ];

    for (final number in incorrectNumbers) {
      expect(
        () => h3.geoToCell(GeoCoord(lat: number, lon: -122.0553238), 5),
        throwsA(isA<H3Exception>()),
        reason: '$number lat throws',
      );
    }

    for (final number in incorrectNumbers) {
      expect(
        () => h3.geoToCell(GeoCoord(lat: 37.3615593, lon: number), 5),
        throwsA(isA<H3Exception>()),
        reason: '$number lon throws',
      );
    }
  });
  test('getResolution', () async {
    expect(
      () => h3.getResolution(BigInt.parse('-1')),
      throwsA(isA<H3Exception>()),
      reason: 'Throws error when an invalid index is passed',
    );
    for (var res = 0; res < 16; res++) {
      final h3Index = h3.geoToCell(
        const GeoCoord(lat: 37.3615593, lon: -122.0553238),
        res,
      );
      expect(
        h3.getResolution(h3Index),
        res,
        reason: 'Got the expected resolution back',
      );
    }
  });
  test('cellToGeo', () async {
    expect(
      ComparableGeoCoord.fromGeoCoord(
          h3.cellToGeo(BigInt.parse('0x85283473fffffff'))),
      ComparableGeoCoord.fromLatLon(
        lat: 37.34579337536848,
        lon: -121.97637597255124,
      ),
      reason: 'lat/lng matches expected',
    );
  });

  group('cellToBoundary', () {
    test('Regular', () async {
      expect(
        h3
            .cellToBoundary(BigInt.parse('0x85283473fffffff'))
            .map(ComparableGeoCoord.fromGeoCoord)
            .toList(),
        [
          ComparableGeoCoord.fromLatLon(
            lat: 37.271355866731895,
            lon: -121.91508032705622,
          ),
          ComparableGeoCoord.fromLatLon(
            lat: 37.353926450852256,
            lon: -121.86222328902491,
          ),
          ComparableGeoCoord.fromLatLon(
            lat: 37.42834118609435,
            lon: -121.9235499963016,
          ),
          ComparableGeoCoord.fromLatLon(
            lat: 37.42012867767778,
            lon: -122.0377349642703,
          ),
          ComparableGeoCoord.fromLatLon(
            lat: 37.33755608435298,
            lon: -122.09042892904395,
          ),
          ComparableGeoCoord.fromLatLon(
            lat: 37.26319797461824,
            lon: -122.02910130919,
          ),
        ],
        reason: 'Coordinates match expected',
      );
    });

    test('10-Vertex Pentagon', () async {
      expect(
        h3
            .cellToBoundary(BigInt.parse('0x81623ffffffffff'))
            .map(ComparableGeoCoord.fromGeoCoord)
            .toList(),
        [
          ComparableGeoCoord.fromLatLon(
            lat: 12.754829243237465,
            lon: 55.94007484027041,
          ),
          ComparableGeoCoord.fromLatLon(
            lat: 10.2969712998247,
            lon: 55.178175815407634,
          ),
          ComparableGeoCoord.fromLatLon(
            lat: 9.092686031788569,
            lon: 55.25056228923789,
          ),
          ComparableGeoCoord.fromLatLon(
            lat: 7.616228186063625,
            lon: 57.37516125699395,
          ),
          ComparableGeoCoord.fromLatLon(
            lat: 7.302087248609307,
            lon: 58.549882762724735,
          ),
          ComparableGeoCoord.fromLatLon(
            lat: 8.825639091130396,
            lon: 60.638711932789995,
          ),
          ComparableGeoCoord.fromLatLon(
            lat: 9.83036925628956,
            lon: 61.315435771664646,
          ),
          ComparableGeoCoord.fromLatLon(
            lat: 12.271971757766304,
            lon: 60.502253257733344,
          ),
          ComparableGeoCoord.fromLatLon(
            lat: 13.216340916028171,
            lon: 59.732575088573185,
          ),
          ComparableGeoCoord.fromLatLon(
            lat: 13.191260467897605,
            lon: 57.09422515125156,
          ),
        ],
        reason: 'Coordinates match expected',
      );
    });
  });

  group('gridDisk', () {
    test('ringSize = 1', () async {
      expect(
        const DeepCollectionEquality.unordered().equals(
          h3.gridDisk(BigInt.parse('0x8928308280fffff'), 1),
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
    test('ringSize = 2', () async {
      expect(
        const DeepCollectionEquality.unordered().equals(
          h3.gridDisk(BigInt.parse('0x8928308280fffff'), 2),
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
        () => h3.gridDisk(BigInt.parse('0x8928308280fffff'), -7),
        throwsA(isA<H3Exception>()),
      );
    });
    test(
      'Out of bounds',
      () async {
        expect(
          () => h3.gridDisk(BigInt.parse('0x8928308280fffff'), 10000000),
          throwsA(isA<H3Exception>()),
        );
      },
      skip: !testOutOfBounds,
    );
    test('Pentagon', () async {
      expect(
        const DeepCollectionEquality.unordered().equals(
          h3.gridDisk(BigInt.parse('0x821c07fffffffff'), 1),
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
      // this gridDisk ran into it.
      // Check it just in case
      expect(
        const DeepCollectionEquality.unordered().equals(
          h3.gridDisk(BigInt.parse('0x8928308324bffff'), 1),
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

  group('gridDiskDistances', () {
    test('ringSize = 1', () async {
      expect(
        const DeepCollectionEquality.unordered().equals(
          h3.gridDiskDistances(BigInt.parse('0x8928308280fffff'), 1),
          [
            [BigInt.parse('0x8928308280fffff')],
            [
              BigInt.parse('0x8928308280bffff'),
              BigInt.parse('0x89283082807ffff'),
              BigInt.parse('0x89283082877ffff'),
              BigInt.parse('0x89283082803ffff'),
              BigInt.parse('0x89283082873ffff'),
              BigInt.parse('0x8928308283bffff'),
            ],
          ],
        ),
        true,
      );
    });
    test('ringSize = 2', () async {
      expect(
        const DeepCollectionEquality.unordered().equals(
          h3.gridDiskDistances(BigInt.parse('0x8928308280fffff'), 2),
          [
            [BigInt.parse('0x8928308280fffff')],
            [
              BigInt.parse('0x8928308280bffff'),
              BigInt.parse('0x89283082807ffff'),
              BigInt.parse('0x89283082877ffff'),
              BigInt.parse('0x89283082803ffff'),
              BigInt.parse('0x89283082873ffff'),
              BigInt.parse('0x8928308283bffff'),
            ],
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
          ],
        ),
        true,
      );
    });
    test('ringSize = 0', () async {
      expect(
        const DeepCollectionEquality.unordered().equals(
          h3.gridDiskDistances(BigInt.parse('0x8928308280fffff'), 0),
          [
            [BigInt.parse('0x8928308280fffff')]
          ],
        ),
        true,
      );
    });
    test('Pentagon', () async {
      expect(
        const DeepCollectionEquality.unordered().equals(
          h3.gridDiskDistances(BigInt.parse('0x821c07fffffffff'), 1),
          [
            [BigInt.parse('0x821c07fffffffff')],
            [
              BigInt.parse('0x821c2ffffffffff'),
              BigInt.parse('0x821c27fffffffff'),
              BigInt.parse('0x821c17fffffffff'),
              BigInt.parse('0x821c1ffffffffff'),
              BigInt.parse('0x821c37fffffffff'),
            ]
          ],
        ),
        true,
      );
    });

    test(
      'Out of bounds',
      () async {
        expect(
          () =>
              h3.gridDiskDistances(BigInt.parse('0x8928308280fffff'), 1000000),
          throwsA(isA<H3Exception>()),
        );
      },
      skip: !testOutOfBounds,
    );
  });

  group('gridRingUnsafe', () {
    test('ringSize - 1', () async {
      expect(
        const DeepCollectionEquality.unordered().equals(
          h3.gridRingUnsafe(BigInt.parse('0x8928308280fffff'), 1),
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
    test('ringSize - 2', () async {
      expect(
        const DeepCollectionEquality.unordered().equals(
          h3.gridRingUnsafe(BigInt.parse('0x8928308280fffff'), 2),
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
    test('ringSize - 0', () async {
      expect(
        const DeepCollectionEquality().equals(
          h3.gridRingUnsafe(BigInt.parse('0x8928308280fffff'), 0),
          [BigInt.parse('0x8928308280fffff')],
        ),
        true,
        reason: 'Got origin in ring 0',
      );
    });
    test('Pentagon', () async {
      expect(
        () => h3.gridRingUnsafe(BigInt.parse('0x821c07fffffffff'), 2),
        throwsA(isA<H3Exception>()),
        reason: 'Throws with a pentagon origin',
      );
      expect(
        () => h3.gridRingUnsafe(BigInt.parse('0x821c2ffffffffff'), 1),
        throwsA(isA<H3Exception>()),
        reason: 'Throws with a pentagon in the ring itself',
      );
      expect(
        () => h3.gridRingUnsafe(BigInt.parse('0x821c2ffffffffff'), 5),
        throwsA(isA<H3Exception>()),
        reason: 'Throws with a pentagon inside the ring',
      );
    });
  });

  group('polygonToCells', () {
    test('Hexagon', () async {
      final hexagons = h3.polygonToCells(
        perimeter: const [
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
    test('Transmeridian', () async {
      final hexagons = h3.polygonToCells(
        perimeter: const [
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
      final hexagons = h3.polygonToCells(
        perimeter: const [],
        resolution: 9,
      );
      expect(hexagons.length, 0);
    });

    test('Bad Input', () async {
      expect(
        () => h3.polygonToCells(
          perimeter: const [
            GeoCoord(lat: 0.5729577951308232, lon: -179.4270422048692),
            GeoCoord(lat: 0.5729577951308232, lon: 179.4270422048692),
            GeoCoord(lat: -0.5729577951308232, lon: 179.4270422048692),
            GeoCoord(lat: -0.5729577951308232, lon: -179.4270422048692),
          ],
          resolution: -9,
        ),
        throwsA(isA<AssertionError>()),
        reason: 'Negative resolution throws',
      );

      expect(
        () => h3.polygonToCells(
          perimeter: const [
            GeoCoord(lat: 0.5729577951308232, lon: -179.4270422048692),
            GeoCoord(lat: 0.5729577951308232, lon: 179.4270422048692),
            GeoCoord(lat: -0.5729577951308232, lon: 179.4270422048692),
            GeoCoord(lat: -0.5729577951308232, lon: -179.4270422048692),
          ],
          resolution: 42,
        ),
        throwsA(isA<AssertionError>()),
        reason: 'Incorrect resolution throws',
      );
    });

    test(
      'Out of bounds output',
      () {
        expect(
          () => h3.polygonToCells(
            perimeter: const [
              GeoCoord(lat: 85, lon: 85),
              GeoCoord(lat: 85, lon: -85),
              GeoCoord(lat: -85, lon: -85),
              GeoCoord(lat: -85, lon: 85),
              GeoCoord(lat: 85, lon: 85),
            ],
            resolution: 15,
          ),
          throwsA(isA<H3Exception>()),
          reason: 'Throws if expected output is too large',
        );
      },
      skip: !testOutOfBounds,
    );

    test('With Hole', () async {
      final hexagons = h3.polygonToCells(
        perimeter: const [
          GeoCoord(lat: 37.813318999983238, lon: -122.4089866999972145),
          GeoCoord(lat: 37.7866302000007224, lon: -122.3805436999997056),
          GeoCoord(lat: 37.7198061999978478, lon: -122.3544736999993603),
          GeoCoord(lat: 37.7076131999975672, lon: -122.5123436999983966),
          GeoCoord(lat: 37.7835871999971715, lon: -122.5247187000021967),
          GeoCoord(lat: 37.8151571999998453, lon: -122.4798767000009008),
        ],
        holes: const [
          [
            GeoCoord(lat: 37.7869802, lon: -122.4471197),
            GeoCoord(lat: 37.7664102, lon: -122.4590777),
            GeoCoord(lat: 37.7710682, lon: -122.4137097),
          ]
        ],
        resolution: 9,
      );

      expect(hexagons.length, 1214);
    });

    test('With Two Holes', () async {
      final hexagons = h3.polygonToCells(
        perimeter: const [
          GeoCoord(lat: 37.813318999983238, lon: -122.4089866999972145),
          GeoCoord(lat: 37.7866302000007224, lon: -122.3805436999997056),
          GeoCoord(lat: 37.7198061999978478, lon: -122.3544736999993603),
          GeoCoord(lat: 37.7076131999975672, lon: -122.5123436999983966),
          GeoCoord(lat: 37.7835871999971715, lon: -122.5247187000021967),
          GeoCoord(lat: 37.8151571999998453, lon: -122.4798767000009008),
        ],
        holes: const [
          [
            GeoCoord(lat: 37.7869802, lon: -122.4471197),
            GeoCoord(lat: 37.7664102, lon: -122.4590777),
            GeoCoord(lat: 37.7710682, lon: -122.4137097),
          ],
          [
            GeoCoord(lat: 37.747976, lon: -122.490025),
            GeoCoord(lat: 37.73155, lon: -122.503758),
            GeoCoord(lat: 37.72544, lon: -122.452603),
          ],
        ],
        resolution: 9,
      );

      expect(hexagons.length, 1172);
    });

    test('BBox corners (https://github.com/uber/h3-js/issues/67)', () async {
      final east = -56.25,
          north = -33.13755119234615,
          south = -34.30714385628804,
          west = -57.65625;
      final hexagons = h3.polygonToCells(
        perimeter: [
          GeoCoord(lat: north, lon: east),
          GeoCoord(lat: north, lon: west),
          GeoCoord(lat: south, lon: west),
          GeoCoord(lat: south, lon: east),
        ],
        resolution: 7,
      );

      expect(hexagons.length, 4499);
    });
  });

  group('polygonToCellsExperimental', () {
    test('flag = containmentCenter', () async {
      final hexagons = h3.polygonToCellsExperimental(
        perimeter: const [
          GeoCoord(lat: 37.813318999983238, lon: -122.4089866999972145),
          GeoCoord(lat: 37.7866302000007224, lon: -122.3805436999997056),
          GeoCoord(lat: 37.7198061999978478, lon: -122.3544736999993603),
          GeoCoord(lat: 37.7076131999975672, lon: -122.5123436999983966),
          GeoCoord(lat: 37.7835871999971715, lon: -122.5247187000021967),
          GeoCoord(lat: 37.8151571999998453, lon: -122.4798767000009008),
        ],
        resolution: 9,
        flag: PolygonToCellFlags.containmentCenter,
      );
      expect(
        hexagons.length,
        1253,
      );
    });
    test('flag = containmentFull', () async {
      final hexagons = h3.polygonToCellsExperimental(
        perimeter: const [
          GeoCoord(lat: 37.813318999983238, lon: -122.4089866999972145),
          GeoCoord(lat: 37.7866302000007224, lon: -122.3805436999997056),
          GeoCoord(lat: 37.7198061999978478, lon: -122.3544736999993603),
          GeoCoord(lat: 37.7076131999975672, lon: -122.5123436999983966),
          GeoCoord(lat: 37.7835871999971715, lon: -122.5247187000021967),
          GeoCoord(lat: 37.8151571999998453, lon: -122.4798767000009008),
        ],
        resolution: 9,
        flag: PolygonToCellFlags.containmentFull,
      );
      expect(
        hexagons.length,
        1175,
      );
    });
    test('flag = containmentOverlapping', () async {
      final hexagons = h3.polygonToCellsExperimental(
        perimeter: const [
          GeoCoord(lat: 37.813318999983238, lon: -122.4089866999972145),
          GeoCoord(lat: 37.7866302000007224, lon: -122.3805436999997056),
          GeoCoord(lat: 37.7198061999978478, lon: -122.3544736999993603),
          GeoCoord(lat: 37.7076131999975672, lon: -122.5123436999983966),
          GeoCoord(lat: 37.7835871999971715, lon: -122.5247187000021967),
          GeoCoord(lat: 37.8151571999998453, lon: -122.4798767000009008),
        ],
        resolution: 9,
        flag: PolygonToCellFlags.containmentOverlapping,
      );
      expect(
        hexagons.length,
        1334,
      );
    });

    test('flag = containmentOverlappingBbox', () async {
      final hexagons = h3.polygonToCellsExperimental(
        perimeter: const [
          GeoCoord(lat: 37.813318999983238, lon: -122.4089866999972145),
          GeoCoord(lat: 37.7866302000007224, lon: -122.3805436999997056),
          GeoCoord(lat: 37.7198061999978478, lon: -122.3544736999993603),
          GeoCoord(lat: 37.7076131999975672, lon: -122.5123436999983966),
          GeoCoord(lat: 37.7835871999971715, lon: -122.5247187000021967),
          GeoCoord(lat: 37.8151571999998453, lon: -122.4798767000009008),
        ],
        resolution: 9,
        flag: PolygonToCellFlags.containmentOverlappingBbox,
      );
      expect(
        hexagons.length,
        1416,
      );
    });
    test('Transmeridian', () async {
      final hexagons = h3.polygonToCellsExperimental(
        perimeter: const [
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
      final hexagons = h3.polygonToCellsExperimental(
        perimeter: const [],
        resolution: 9,
      );
      expect(hexagons.length, 0);
    });

    test('Bad Input', () async {
      expect(
        () => h3.polygonToCellsExperimental(
          perimeter: const [
            GeoCoord(lat: 0.5729577951308232, lon: -179.4270422048692),
            GeoCoord(lat: 0.5729577951308232, lon: 179.4270422048692),
            GeoCoord(lat: -0.5729577951308232, lon: 179.4270422048692),
            GeoCoord(lat: -0.5729577951308232, lon: -179.4270422048692),
          ],
          resolution: -9,
        ),
        throwsA(isA<AssertionError>()),
        reason: 'Negative resolution throws',
      );

      expect(
        () => h3.polygonToCellsExperimental(
          perimeter: const [
            GeoCoord(lat: 0.5729577951308232, lon: -179.4270422048692),
            GeoCoord(lat: 0.5729577951308232, lon: 179.4270422048692),
            GeoCoord(lat: -0.5729577951308232, lon: 179.4270422048692),
            GeoCoord(lat: -0.5729577951308232, lon: -179.4270422048692),
          ],
          resolution: 42,
        ),
        throwsA(isA<AssertionError>()),
        reason: 'Incorrect resolution throws',
      );
    });

    test(
      'Out of bounds output',
      () {
        expect(
          () => h3.polygonToCellsExperimental(
            perimeter: const [
              GeoCoord(lat: 85, lon: 85),
              GeoCoord(lat: 85, lon: -85),
              GeoCoord(lat: -85, lon: -85),
              GeoCoord(lat: -85, lon: 85),
              GeoCoord(lat: 85, lon: 85),
            ],
            resolution: 15,
          ),
          throwsA(isA<H3Exception>()),
          reason: 'Throws if expected output is too large',
        );
      },
      skip: !testOutOfBounds,
    );

    test('With Hole', () async {
      final hexagons = h3.polygonToCellsExperimental(
        perimeter: const [
          GeoCoord(lat: 37.813318999983238, lon: -122.4089866999972145),
          GeoCoord(lat: 37.7866302000007224, lon: -122.3805436999997056),
          GeoCoord(lat: 37.7198061999978478, lon: -122.3544736999993603),
          GeoCoord(lat: 37.7076131999975672, lon: -122.5123436999983966),
          GeoCoord(lat: 37.7835871999971715, lon: -122.5247187000021967),
          GeoCoord(lat: 37.8151571999998453, lon: -122.4798767000009008),
        ],
        holes: const [
          [
            GeoCoord(lat: 37.7869802, lon: -122.4471197),
            GeoCoord(lat: 37.7664102, lon: -122.4590777),
            GeoCoord(lat: 37.7710682, lon: -122.4137097),
          ]
        ],
        resolution: 9,
      );

      expect(hexagons.length, 1214);
    });

    test('With Two Holes', () async {
      final hexagons = h3.polygonToCellsExperimental(
        perimeter: const [
          GeoCoord(lat: 37.813318999983238, lon: -122.4089866999972145),
          GeoCoord(lat: 37.7866302000007224, lon: -122.3805436999997056),
          GeoCoord(lat: 37.7198061999978478, lon: -122.3544736999993603),
          GeoCoord(lat: 37.7076131999975672, lon: -122.5123436999983966),
          GeoCoord(lat: 37.7835871999971715, lon: -122.5247187000021967),
          GeoCoord(lat: 37.8151571999998453, lon: -122.4798767000009008),
        ],
        holes: const [
          [
            GeoCoord(lat: 37.7869802, lon: -122.4471197),
            GeoCoord(lat: 37.7664102, lon: -122.4590777),
            GeoCoord(lat: 37.7710682, lon: -122.4137097),
          ],
          [
            GeoCoord(lat: 37.747976, lon: -122.490025),
            GeoCoord(lat: 37.73155, lon: -122.503758),
            GeoCoord(lat: 37.72544, lon: -122.452603),
          ],
        ],
        resolution: 9,
      );

      expect(hexagons.length, 1172);
    });

    test('BBox corners (https://github.com/uber/h3-js/issues/67)', () async {
      final east = -56.25,
          north = -33.13755119234615,
          south = -34.30714385628804,
          west = -57.65625;
      final hexagons = h3.polygonToCellsExperimental(
        perimeter: [
          GeoCoord(lat: north, lon: east),
          GeoCoord(lat: north, lon: west),
          GeoCoord(lat: south, lon: west),
          GeoCoord(lat: south, lon: east),
        ],
        resolution: 7,
      );

      expect(hexagons.length, 4499);
    });
  });

  group('cellsToMultiPolygon', () {
    void assertLoop(List<GeoCoord> loop, List<GeoCoord> expected) {
      var comparableLoop =
          loop.map((e) => ComparableGeoCoord.fromGeoCoord).toList();
      final comparableExpected =
          loop.map((e) => ComparableGeoCoord.fromGeoCoord).toList();

      // Find the start index
      int index = comparableLoop.indexOf(comparableExpected[0]);

      expect(index >= 0, true, reason: 'Found start index in loop');

      // Wrap the loop to the right start index
      comparableLoop = [
        ...comparableLoop.sublist(index),
        ...comparableLoop.sublist(0, index)
      ];

      expect(comparableLoop, equals(comparableExpected),
          reason: 'Got expected loop (independent of starting vertex)');
    }

    void assertPolygon(
        List<List<GeoCoord>> input, List<List<GeoCoord>> expected) {
      expect(input.length, equals(expected.length),
          reason: 'Polygon has expected number of loops');
      for (int i = 0; i < input.length; i++) {
        assertLoop(input[i], expected[i]);
      }
    }

    void assertMultiPolygon(
        List<List<List<GeoCoord>>> input, List<List<List<GeoCoord>>> expected) {
      expect(input.length, equals(expected.length),
          reason: 'MultiPolygon has expected number of polygons');
      for (int i = 0; i < input.length; i++) {
        assertPolygon(input[i], expected[i]);
      }
    }

    test('Empty', () async {
      final multiPolygon = h3.cellsToMultiPolygon([]);

      expect(
        multiPolygon,
        isEmpty,
        reason: 'no hexagons yields an empty array',
      );
    });
    test('Single', () async {
      final h3Index = BigInt.parse('0x89283082837ffff');
      final multiPolygon = h3.cellsToMultiPolygon([h3Index]);
      final vertices = h3.cellToBoundary(h3Index);

      expect(
        const DeepCollectionEquality().equals(
          multiPolygon,
          [
            [vertices]
          ],
        ),
        true,
      );
    });
    test('Contiguous 2', () async {
      final h3Indexes = [
        BigInt.parse('0x89283082837ffff'),
        BigInt.parse('0x89283082833ffff'),
      ];
      final multiPolygon = h3.cellsToMultiPolygon(h3Indexes);
      final vertices0 = h3.cellToBoundary(h3Indexes[0]);
      final vertices1 = h3.cellToBoundary(h3Indexes[1]);

      assertMultiPolygon(
        multiPolygon,
        [
          [
            [
              vertices1[0],
              vertices1[1],
              vertices1[2],
              vertices0[1],
              vertices0[2],
              vertices0[3],
              vertices0[4],
              vertices0[5],
              vertices1[4],
              vertices1[5]
            ]
          ]
        ],
      );
    });

    test('Non-contiguous 2', () async {
      final h3Indexes = [
        BigInt.parse('0x89283082837ffff'),
        BigInt.parse('0x8928308280fffff'),
      ];
      final multiPolygon = h3.cellsToMultiPolygon(h3Indexes);
      final vertices0 = h3.cellToBoundary(h3Indexes[0]);
      final vertices1 = h3.cellToBoundary(h3Indexes[1]);

      assertMultiPolygon(multiPolygon, [
        [vertices0],
        [vertices1]
      ]);
    });

    test('Hole', () async {
      final h3Indexes = [
        BigInt.parse('0x892830828c7ffff'),
        BigInt.parse('0x892830828d7ffff'),
        BigInt.parse('0x8928308289bffff'),
        BigInt.parse('0x89283082813ffff'),
        BigInt.parse('0x8928308288fffff'),
        BigInt.parse('0x89283082883ffff'),
      ];
      final multiPolygon = h3.cellsToMultiPolygon(h3Indexes);

      expect(multiPolygon.length, 1);
      expect(multiPolygon[0].length, 2);
      expect(multiPolygon[0][0].length, 6 * 3);
      expect(multiPolygon[0][1].length, 6);
    });

    test('kRing', () async {
      var h3Indexes = h3.gridDisk(BigInt.parse('0x8930062838bffff'), 2);
      var multiPolygon = h3.cellsToMultiPolygon(h3Indexes);

      expect(multiPolygon.length, 1);
      expect(multiPolygon[0].length, 1);
      expect(multiPolygon[0][0].length, 6 * (2 * 2 + 1));

      // Same k-ring in random order
      h3Indexes = [
        BigInt.parse('0x89300628393ffff'),
        BigInt.parse('0x89300628383ffff'),
        BigInt.parse('0x89300628397ffff'),
        BigInt.parse('0x89300628067ffff'),
        BigInt.parse('0x89300628387ffff'),
        BigInt.parse('0x893006283bbffff'),
        BigInt.parse('0x89300628313ffff'),
        BigInt.parse('0x893006283cfffff'),
        BigInt.parse('0x89300628303ffff'),
        BigInt.parse('0x89300628317ffff'),
        BigInt.parse('0x8930062839bffff'),
        BigInt.parse('0x8930062838bffff'),
        BigInt.parse('0x8930062806fffff'),
        BigInt.parse('0x8930062838fffff'),
        BigInt.parse('0x893006283d3ffff'),
        BigInt.parse('0x893006283c3ffff'),
        BigInt.parse('0x8930062831bffff'),
        BigInt.parse('0x893006283d7ffff'),
        BigInt.parse('0x893006283c7ffff'),
      ];
      multiPolygon = h3.cellsToMultiPolygon(h3Indexes);
      expect(multiPolygon.length, 1);
      expect(multiPolygon[0].length, 1);
      expect(multiPolygon[0][0].length, 6 * (2 * 2 + 1));

      h3Indexes = h3.gridDisk(BigInt.parse('0x8930062838bffff'), 6)..sort();
      multiPolygon = h3.cellsToMultiPolygon(h3Indexes);

      expect(multiPolygon[0].length, 1);
    });

    test('Nested Donuts', () async {
      final origin = BigInt.parse('0x892830828c7ffff');
      final h3Indexes = [
        ...h3.gridRingUnsafe(origin, 1),
        ...h3.gridRingUnsafe(origin, 3),
      ];
      final multiPolygon = h3.cellsToMultiPolygon(h3Indexes);

      expect(multiPolygon.length, 2);
      expect(multiPolygon[0].length, 2);
      expect(multiPolygon[0][0].length, 6 * 7);
      expect(multiPolygon[0][1].length, 6 * 5);
      expect(multiPolygon[1].length, 2);
      expect(multiPolygon[1][0].length, 6 * 3);
      expect(multiPolygon[1][1].length, 6);
    });
  });

  group(
    'compactCells and uncompactCells',
    () {
      test('Basic', () async {
        final hexagons = h3.polygonToCells(
          perimeter: [
            const GeoCoord(lat: 37.813318999983238, lon: -122.4089866999972145),
            const GeoCoord(
                lat: 37.7866302000007224, lon: -122.3805436999997056),
            const GeoCoord(
                lat: 37.7198061999978478, lon: -122.3544736999993603),
            const GeoCoord(
                lat: 37.7076131999975672, lon: -122.5123436999983966),
            const GeoCoord(
                lat: 37.7835871999971715, lon: -122.5247187000021967),
            const GeoCoord(
                lat: 37.8151571999998453, lon: -122.4798767000009008),
          ],
          resolution: 9,
        );
        final compactedHexagons = h3.compactCells(hexagons);
        expect(compactedHexagons.length, 209);
        final uncompactedHexagons = h3.uncompactCells(
          compactedHexagons,
          resolution: 9,
        );
        expect(uncompactedHexagons.length, 1253);
      });

      test('compactCells - Empty', () async {
        expect(h3.compactCells([]).length, 0);
      });

      test('uncompactCells - Empty', () async {
        expect(h3.uncompactCells([], resolution: 9).length, 0);
      });

      test('compactCells - Duplicates', () async {
        expect(
          () => h3
              .compactCells(List.filled(10, BigInt.parse('0x8500924bfffffff'))),
          throwsA(isA<H3Exception>()),
        );
      });

      test('uncompactCells - Invalid resolution', () async {
        expect(
          () => h3.uncompactCells(
            [h3.geoToCell(GeoCoord(lat: 37.3615593, lon: -122.0553238), 10)],
            resolution: 5,
          ),
          throwsA(isA<H3Exception>()),
        );
      });

      test('uncompactCells - Out of bounds', () async {
        expect(
          () => h3.uncompactCells(
            [BigInt.parse('0x8029fffffffffff')],
            resolution: 15,
          ),
          throwsA(isA<H3Exception>()),
        );
      });
    },
    skip: !testOutOfBounds,
  );

  test('isPentagon', () async {
    expect(
      h3.isPentagon(BigInt.parse('0x8928308280fffff')),
      false,
    );
    expect(
      h3.isPentagon(BigInt.parse('0x821c07fffffffff')),
      true,
    );
    expect(
      h3.isPentagon(BigInt.parse('0x0')),
      false,
    );
  });
  test('isResClassIII', () async {
    // Test all even indexes
    for (var i = 0; i < 15; i += 2) {
      final h3Index = h3.geoToCell(
        const GeoCoord(lat: 37.3615593, lon: -122.0553238),
        i,
      );
      expect(h3.isResClassIII(h3Index), false);
    }
    // Test all odd indexes
    for (var i = 1; i < 15; i += 2) {
      final h3Index = h3.geoToCell(
        const GeoCoord(lat: 37.3615593, lon: -122.0553238),
        i,
      );
      expect(h3.isResClassIII(h3Index), true);
    }
  });
  test('getIcosahedronFaces', () async {
    void testFace(String name, BigInt h3Index, int expected) {
      final faces = h3.getIcosahedronFaces(h3Index);

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

  test('getBaseCellNumber', () async {
    expect(h3.getBaseCellNumber(BigInt.parse('0x8928308280fffff')), 20);
  });

  group('cellToParent', () {
    test('Basic', () async {
      // NB: This test will not work with every hexagon, it has to be a location
      // that does not fall in the margin of error between the 7 children and
      // the parent's true boundaries at every resolution
      const lat = 37.81331899988944;
      const lng = -122.409290778685;
      for (var res = 1; res < 10; res++) {
        for (var step = 0; step < res; step++) {
          final child = h3.geoToCell(const GeoCoord(lat: lat, lon: lng), res);

          final comparisonParent =
              h3.geoToCell(const GeoCoord(lat: lat, lon: lng), res - step);

          final parent = h3.cellToParent(child, res - step);
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
        () => h3.cellToParent(h3Index, 10),
        throwsA(isA<H3Exception>()),
        reason: 'Finer resolution throws',
      );

      expect(
        () => h3.cellToParent(h3Index, -1),
        throwsA(isA<AssertionError>()),
        reason: 'Invalid resolution throws',
      );

      expect(
        () => h3.cellToParent(BigInt.from(0x0), 10),
        throwsA(isA<H3Exception>()),
        reason: 'Invalid index throws',
      );
    });
  });

  test('cellToChildren', () async {
    const lat = 37.81331899988944;
    const lng = -122.409290778685;
    final h3Index = h3.geoToCell(const GeoCoord(lat: lat, lon: lng), 7);

    expect(h3.cellToChildren(h3Index, 8).length, 7,
        reason: 'Immediate child count correct');

    expect(h3.cellToChildren(h3Index, 9).length, 49,
        reason: 'Grandchild count correct');

    expect(h3.cellToChildren(h3Index, 7), [h3Index],
        reason: 'Same resolution returns self');

    expect(
      () => h3.cellToChildren(h3Index, 6),
      throwsA(isA<H3Exception>()),
      reason: 'Coarser resolution throws',
    );

    expect(
      () => h3.cellToChildren(h3Index, -1),
      throwsA(isA<AssertionError>()),
      reason: 'Invalid resolution throws',
    );

    expect(
      h3.cellToChildren(BigInt.from(0x0), 1),
      [],
      reason: 'Invalid index returns empty array',
    );
  });

  group('cellToCenterChild', () {
    test('Basic', () async {
      final baseIndex = BigInt.parse('0x8029fffffffffff');
      final geo = h3.cellToGeo(baseIndex);
      for (var res = 0; res < 14; res++) {
        for (var childRes = res; childRes < 15; childRes++) {
          final parent = h3.geoToCell(geo, res);
          final comparisonChild = h3.geoToCell(geo, childRes);
          final child = h3.cellToCenterChild(parent, childRes);

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

      expect(
        () => h3.cellToCenterChild(h3Index, 5),
        throwsA(isA<H3Exception>()),
        reason: 'Coarser resolution throws',
      );

      expect(
        () => h3.cellToCenterChild(h3Index, -1),
        throwsA(isA<AssertionError>()),
        reason: 'Invalid resolution throws',
      );
    });
  });

  group('cellToChildPos', () {
    test('Basic', () async {
      final h3Index = BigInt.parse('0x88283080ddfffff');
      expect(
        h3.cellToChildPos(h3Index, 8),
        0,
        reason: 'Got expected value for same res',
      );
      expect(
        h3.cellToChildPos(h3Index, 7),
        6,
        reason: 'Got expected value for 1st-level parent',
      );
      expect(
        h3.cellToChildPos(h3Index, 6),
        41,
        reason: 'Got expected value for 2nd-level parent',
      );
    });

    test('Invalid resolutions', () async {
      final h3Index = BigInt.parse('0x88283080ddfffff');

      expect(
        () => h3.cellToChildPos(h3Index, 12),
        throwsA(isA<H3Exception>()),
        reason: 'Finer resolution throws',
      );

      expect(
        () => h3.cellToChildPos(h3Index, -1),
        throwsA(isA<AssertionError>()),
        reason: 'Invalid resolution throws',
      );
    });
  });

  group('childPosToCell', () {
    test('Basic', () async {
      final h3Index = BigInt.parse('0x88283080ddfffff');
      expect(
        h3.childPosToCell(6, h3.cellToParent(h3Index, 7), 8),
        h3Index,
        reason: 'Got expected value for 1st-level parent',
      );
      expect(
        h3.childPosToCell(41, h3.cellToParent(h3Index, 6), 8),
        h3Index,
        reason: 'Got expected value for 2nd-level parent',
      );
    });

    test('Error cases', () async {
      final h3Index = BigInt.parse('0x88283080ddfffff');

      expect(
        () => h3.childPosToCell(6, h3Index, 5),
        throwsA(isA<H3Exception>()),
        reason: 'Coarser resolution throws',
      );

      expect(
        () => h3.childPosToCell(6, h3Index, -1),
        throwsA(isA<AssertionError>()),
        reason: 'Invalid resolution throws',
      );

      expect(
        () => h3.childPosToCell(42, h3Index, 9),
        throwsA(isA<H3Exception>()),
        reason: 'Child pos out of range throws',
      );
    });
  });

  test('cellToChildPos / childPosToCell round-trip', () async {
    // These are somewhat arbitrary, but cover a few different parts of the globe
    const testLatLngs = [
      [37.81331899988944, -122.409290778685],
      [64.2868041, 8.7824902],
      [5.8815246, 54.3336044],
      [-41.4486737, 143.918175]
    ];

    for (final latLng in testLatLngs) {
      for (var res = 0; res < 16; res++) {
        final child =
            h3.geoToCell(GeoCoord(lat: latLng[0], lon: latLng[1]), res);
        final parent = h3.cellToParent(child, 0);
        final pos = h3.cellToChildPos(child, 0);
        final cell = h3.childPosToCell(pos, parent, res);
        expect(
          cell,
          child,
          reason: 'round-trip produced the same cell for res $res',
        );
      }
    }
  });

  test('childPosToCell / cellToChildrenSize', () async {
    // one hexagon, one pentagon
    final baseCells = [
      BigInt.parse('0x80bffffffffffff'),
      BigInt.parse('0x80a7fffffffffff')
    ];

    for (final h3Index in baseCells) {
      for (var res = 0; res < 16; res++) {
        final count = h3.cellToChildrenSize(h3Index, res);
        expect(
          count >= pow(6, res) && count <= pow(7, res),
          true,
          reason: 'count has the right order of magnitude',
        );
        final child = h3.childPosToCell(count - 1, h3Index, res);
        final pos = h3.cellToChildPos(child, 0);
        expect(
          pos,
          count - 1,
          reason: 'got expected round-trip',
        );

        expect(
          () => h3.childPosToCell(count, h3Index, res),
          throwsA(isA<H3Exception>()),
          reason: 'One more is out of range',
        );
      }
    }
  });

  test('cellToChildrenSize - errors', () async {
    final h3Index = BigInt.parse('0x88283080ddfffff');
    expect(
      () => h3.cellToChildrenSize(h3Index, 5),
      throwsA(isA<H3Exception>()),
      reason: 'Coarser resolution throws',
    );
    expect(
      () => h3.cellToChildrenSize(h3Index, -1),
      throwsA(isA<AssertionError>()),
      reason: 'Invalid resolution throws',
    );
    expect(
      () => h3.cellToChildrenSize(BigInt.parse('0x0'), 9),
      throwsA(isA<H3Exception>()),
      reason: 'Invalid cell throws',
    );
  });

  test('areNeighborCells', () async {
    final origin = BigInt.parse('0x891ea6d6533ffff');
    final adjacent = BigInt.parse('0x891ea6d65afffff');
    final notAdjacent = BigInt.parse('0x891ea6992dbffff');

    expect(
      h3.areNeighborCells(origin, adjacent),
      true,
      reason: 'Adjacent hexagons are neighbors',
    );

    expect(
      h3.areNeighborCells(adjacent, origin),
      true,
      reason: 'Adjacent hexagons are neighbors',
    );

    expect(
      h3.areNeighborCells(origin, notAdjacent),
      false,
      reason: 'Non-adjacent hexagons are not neighbors',
    );

    expect(
      h3.areNeighborCells(origin, origin),
      false,
      reason: 'A hexagon is not a neighbor to itself',
    );

    expect(
      () => h3.areNeighborCells(origin, BigInt.parse('-1')),
      throwsA(isA<H3Exception>()),
      reason: 'A hexagon is not a neighbor to an invalid index',
    );

    expect(
      () => h3.areNeighborCells(origin, BigInt.parse('42')),
      throwsA(isA<H3Exception>()),
      reason: 'A hexagon is not a neighbor to an invalid index',
    );

    expect(
      () => h3.areNeighborCells(BigInt.parse('-1'), BigInt.parse('-1')),
      throwsA(isA<H3Exception>()),
      reason: 'Two invalid indexes are not neighbors',
    );
  });

  test('cellsToDirectedEdge', () async {
    final origin = BigInt.parse('0x891ea6d6533ffff');
    final destination = BigInt.parse('0x891ea6d65afffff');
    final edge = BigInt.parse('0x1591ea6d6533ffff');
    final notAdjacent = BigInt.parse('0x891ea6992dbffff');

    expect(
      h3.cellsToDirectedEdge(origin, destination),
      edge,
      reason: 'Got expected edge for adjacent hexagons',
    );

    expect(
      () => h3.cellsToDirectedEdge(origin, notAdjacent),
      throwsA(isA<H3Exception>()),
      reason: 'Throws for non-adjacent hexagons',
    );

    expect(
      () => h3.cellsToDirectedEdge(origin, origin),
      throwsA(isA<H3Exception>()),
      reason: 'Throws for same hexagons',
    );

    expect(
      () => h3.cellsToDirectedEdge(origin, BigInt.parse('-1')),
      throwsA(isA<H3Exception>()),
      reason: 'Throws for invalid destination',
    );

    expect(
      () => h3.cellsToDirectedEdge(BigInt.parse('-1'), BigInt.parse('-1')),
      throwsA(isA<H3Exception>()),
      reason: 'Throws for invalid hexagons',
    );
  });

  test('getDirectedEdgeOrigin', () async {
    final origin = BigInt.parse('0x891ea6d6533ffff');
    final edge = BigInt.parse('0x1591ea6d6533ffff');

    expect(
      h3.getDirectedEdgeOrigin(edge),
      origin,
      reason: 'Got expected origin for edge',
    );

    expect(
      () => h3.getDirectedEdgeOrigin(origin),
      throwsA(isA<H3Exception>()),
      reason: 'Throws for non-edge hexagon',
    );

    expect(
      () => h3.getDirectedEdgeOrigin(BigInt.parse('-1')),
      throwsA(isA<H3Exception>()),
      reason: 'Throws for non-valid hexagon',
    );
  });

  test('getDirectedEdgeDestination', () async {
    final destination = BigInt.parse('0x891ea6d65afffff');
    final edge = BigInt.parse('0x1591ea6d6533ffff');

    expect(
      h3.getDirectedEdgeDestination(edge),
      destination,
      reason: 'Got expected origin for edge',
    );

    expect(
      () => h3.getDirectedEdgeDestination(destination),
      throwsA(isA<H3Exception>()),
      reason: 'Throws for non-edge hexagon',
    );

    expect(
      () => h3.getDirectedEdgeDestination(BigInt.parse('-1')),
      throwsA(isA<H3Exception>()),
      reason: 'Throws for non-valid hexagon',
    );
  });

  test('isValidDirectedEdge', () async {
    final origin = BigInt.parse('0x891ea6d6533ffff');
    final destination = BigInt.parse('0x891ea6d65afffff');

    expect(
      h3.isValidDirectedEdge(BigInt.parse('0x1591ea6d6533ffff')),
      true,
      reason: 'Edge index is valid',
    );

    expect(
      h3.isValidDirectedEdge(
        h3.cellsToDirectedEdge(origin, destination),
      ),
      true,
      reason: 'Output of cellsToDirectedEdge is valid',
    );

    expect(
      h3.isValidDirectedEdge(BigInt.parse('-1')),
      false,
      reason: '-1 is not valid',
    );
  });

  test('directedEdgeToCells', () async {
    final origin = BigInt.parse('0x891ea6d6533ffff');
    final destination = BigInt.parse('0x891ea6d65afffff');
    final edge = BigInt.parse('0x1591ea6d6533ffff');

    expect(
      h3.directedEdgeToCells(edge),
      (destination: destination, origin: origin),
      reason: 'Got expected origin, destination from edge',
    );

    expect(
      h3.directedEdgeToCells(h3.cellsToDirectedEdge(origin, destination)),
      (destination: destination, origin: origin),
      reason:
          'Got expected origin, destination from cellsToDirectedEdge output',
    );
  });

  group('originToDirectedEdges', () {
    test('Basic', () async {
      final origin = BigInt.parse('0x8928308280fffff');
      final edges = h3.originToDirectedEdges(origin);

      expect(
        edges.length,
        6,
        reason: 'got expected edge count',
      );

      final neighbours = h3.gridRingUnsafe(origin, 1);
      for (final neighbour in neighbours) {
        final edge = h3.cellsToDirectedEdge(origin, neighbour);
        expect(
          edges.contains(edge),
          true,
          reason: 'found edge to neighbor',
        );
      }
    });

    test('Pentagon', () async {
      final origin = BigInt.parse('0x81623ffffffffff');
      final edges = h3.originToDirectedEdges(origin);

      expect(
        edges.length,
        5,
        reason: 'got expected edge count',
      );

      final neighbours =
          h3.gridDisk(origin, 1).where((e) => e != origin).toList();

      for (final neighbour in neighbours) {
        final edge = h3.cellsToDirectedEdge(origin, neighbour);
        expect(
          edges.contains(edge),
          true,
          reason: 'found edge to neighbor',
        );
      }
    });
  });

  group('directedEdgeToBoundary', () {
    test('Basic', () async {
      final origin = BigInt.parse('0x85283473fffffff');
      final edges = h3.originToDirectedEdges(origin);

      // GeoBoundary of the origin
      final originBoundary = h3.cellToBoundary(origin);

      final expectedEdges = [
        [originBoundary[3], originBoundary[4]],
        [originBoundary[1], originBoundary[2]],
        [originBoundary[2], originBoundary[3]],
        [originBoundary[5], originBoundary[0]],
        [originBoundary[4], originBoundary[5]],
        [originBoundary[0], originBoundary[1]]
      ];

      for (var i = 0; i < edges.length; i++) {
        final latlngs = h3.directedEdgeToBoundary(edges[i]);
        expect(
          latlngs.map((g) => ComparableGeoCoord.fromGeoCoord(g)),
          expectedEdges[i].map((g) => ComparableGeoCoord.fromGeoCoord(g)),
          reason: 'Coordinates match expected for edge $i',
        );
      }
    });

    test('10-vertex pentagon', () async {
      final origin = BigInt.parse('0x81623ffffffffff');
      final edges = h3.originToDirectedEdges(origin);

      // GeoBoundary of the origin
      final originBoundary = h3.cellToBoundary(origin);

      final expectedEdges = [
        [originBoundary[2], originBoundary[3], originBoundary[4]],
        [originBoundary[4], originBoundary[5], originBoundary[6]],
        [originBoundary[8], originBoundary[9], originBoundary[0]],
        [originBoundary[6], originBoundary[7], originBoundary[8]],
        [originBoundary[0], originBoundary[1], originBoundary[2]]
      ];

      for (var i = 0; i < edges.length; i++) {
        final latlngs = h3.directedEdgeToBoundary(edges[i]);
        expect(
          latlngs.map((g) => ComparableGeoCoord.fromGeoCoord(g)),
          expectedEdges[i].map((g) => ComparableGeoCoord.fromGeoCoord(g)),
          reason: 'Coordinates match expected for edge $i',
        );
      }
    });
  });

  group('gridDistance', () {
    test('Basic', () async {
      final origin = h3.geoToCell(const GeoCoord(lat: 37.5, lon: -122), 9);
      for (var radius = 0; radius < 4; radius++) {
        final others = h3.gridRingUnsafe(origin, radius);
        for (var i = 0; i < others.length; i++) {
          expect(
            h3.gridDistance(origin, others[i]),
            radius,
            reason: 'Got distance $radius for ($origin, ${others[i]})',
          );
        }
      }
    });

    test('Failure', () async {
      final origin = h3.geoToCell(const GeoCoord(lat: 37.5, lon: -122), 9);
      final origin10 = h3.geoToCell(const GeoCoord(lat: 37.5, lon: -122), 10);
      final edge = BigInt.parse('0x1591ea6d6533ffff');
      final distantHex = h3.geoToCell(const GeoCoord(lat: -37.5, lon: 122), 9);

      expect(
        () => h3.gridDistance(origin, origin10),
        throwsA(isA<H3Exception>()),
        reason: 'Throws for distance between different resolutions',
      );
      expect(
        () => h3.gridDistance(origin, edge),
        throwsA(isA<H3Exception>()),
        reason: 'Throws for distance between hexagon and edge',
      );
      expect(
        () => h3.gridDistance(origin, distantHex),
        throwsA(isA<H3Exception>()),
        reason: 'Throws for distance between distant hexagons',
      );
    });
  });

  group('gridPathCells', () {
    test('Basic', () async {
      for (var res = 0; res < 12; res++) {
        final origin = h3.geoToCell(const GeoCoord(lat: 37.5, lon: -122), res);
        final destination =
            h3.geoToCell(const GeoCoord(lat: 25, lon: -120), res);
        final line = h3.gridPathCells(origin, destination);
        final distance = h3.gridDistance(origin, destination);
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
                    h3.areNeighborCells(
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
      final origin = h3.geoToCell(const GeoCoord(lat: 37.5, lon: -122), 9);
      final origin10 = h3.geoToCell(const GeoCoord(lat: 37.5, lon: -122), 10);

      expect(
        () => h3.gridPathCells(origin, origin10),
        throwsA(isA<H3Exception>()),
        reason: 'got expected error for different resolutions',
      );
    });
  });

  group('cellToLocalIj / localIjToCell', () {
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
          h3.cellToLocalIj(origin, h3Index),
          coord,
          reason: 'Got expected coordinates for $h3Index',
        );
        expect(
          h3.localIjToCell(origin, coord),
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
          h3.cellToLocalIj(origin, h3Index),
          coord,
          reason: 'Got expected coordinates for $h3Index',
        );
        expect(
          h3.localIjToCell(origin, coord),
          h3Index,
          reason: 'Got expected H3 index for $coord',
        );
      }
    });

    test('Failure', () async {
      // experimentalH3ToLocalIj

      expect(
        () => h3.cellToLocalIj(BigInt.parse('0x832830fffffffff'),
            BigInt.parse('0x822837fffffffff')),
        throwsA(isA<H3Exception>()),
        reason: 'Got expected error',
      );
      expect(
        () => h3.cellToLocalIj(BigInt.parse('0x822a17fffffffff'),
            BigInt.parse('0x822837fffffffff')),
        throwsA(isA<H3Exception>()),
        reason: 'Got expected error',
      );
      expect(
        () => h3.cellToLocalIj(BigInt.parse('0x8828308281fffff'),
            BigInt.parse('0x8841492553fffff')),
        throwsA(isA<H3Exception>()),
        reason: 'Got expected error for opposite sides of the world',
      );
      expect(
        () => h3.cellToLocalIj(BigInt.parse('0x81283ffffffffff'),
            BigInt.parse('0x811cbffffffffff')),
        throwsA(isA<H3Exception>()),
        reason: 'Got expected error',
      );
      expect(
        () => h3.cellToLocalIj(BigInt.parse('0x811d3ffffffffff'),
            BigInt.parse('0x8122bffffffffff')),
        throwsA(isA<H3Exception>()),
        reason: 'Got expected error',
      );

      // experimentalLocalIjToH3

      expect(
        () => h3.localIjToCell(
          BigInt.parse('0x8049fffffffffff'),
          const CoordIJ(i: 2, j: 0),
        ),
        throwsA(isA<H3Exception>()),
        reason: 'Got expected error when index is not defined',
      );
    });
  });

  group('getHexagonAreaAvg', () {
    test('Basic', () async {
      var last = 1e14;
      for (var res = 0; res < 16; res++) {
        final result = h3.getHexagonAreaAvg(res, H3MetricUnits.m);
        expect(
          result < last,
          true,
          reason: 'result < last result: $result, $last',
        );
        last = result;
      }

      last = 1e7;
      for (var res = 0; res < 16; res++) {
        final result = h3.getHexagonAreaAvg(res, H3MetricUnits.km);
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
        () => h3.getHexagonAreaAvg(42, H3MetricUnits.km),
        throwsA(isA<AssertionError>()),
        reason: 'throws on invalid resolution',
      );
    });
  });

  group('getHexagonEdgeLengthAvg', () {
    test('Basic', () async {
      var last = 1e7;
      for (var res = 0; res < 16; res++) {
        final result = h3.getHexagonEdgeLengthAvg(res, H3MetricUnits.m);
        expect(
          result < last,
          true,
          reason: 'result < last result: $result, $last',
        );
        last = result;
      }

      last = 1e4;
      for (var res = 0; res < 16; res++) {
        final result = h3.getHexagonEdgeLengthAvg(res, H3MetricUnits.km);
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
        () => h3.getHexagonEdgeLengthAvg(42, H3MetricUnits.km),
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
      final h3Index = h3.geoToCell(const GeoCoord(lat: 0, lon: 0), res);
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
          almostEqual(
              cellAreaKm2, h3.getHexagonAreaAvg(res, H3MetricUnits.km), 0.4),
          true,
          reason: 'Area is close to average area at res $res, km2',
        );
        expect(
          // This seems to be the lowest factor that works for other resolutions
          almostEqual(
              cellAreaM2, h3.getHexagonAreaAvg(res, H3MetricUnits.m), 0.4),
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

  test('edgeLength', () async {
    for (var res = 0; res < 16; res++) {
      final h3Index = h3.geoToCell(GeoCoord(lat: 0, lon: 0), res);
      final edges = h3.originToDirectedEdges(h3Index);
      for (final edge in edges) {
        final lengthKm = h3.edgeLength(edge, H3Units.km);
        expect(lengthKm > 0, true, reason: 'Has some length');
        expect(
          // res 0 has high distortion of average edge length due to high pentagon proportion
          res == 0 ||
              almostEqual(
                lengthKm,
                h3.getHexagonEdgeLengthAvg(res, H3MetricUnits.km),
                0.28,
              ),
          true,
          reason: 'Edge length is close to average edge length at res $res, km',
        );

        final lengthM = h3.edgeLength(edge, H3Units.m);
        expect(
          // res 0 has high distortion of average edge length due to high pentagon proportion
          res == 0 ||
              almostEqual(
                lengthM,
                h3.getHexagonEdgeLengthAvg(res, H3MetricUnits.m),
                0.28,
              ),
          true,
          reason: 'Edge length is close to average edge length at res $res, m',
        );
        expect(lengthM > lengthKm, true);
        expect(lengthKm > h3.edgeLength(edge, H3Units.rad), true);
      }
    }
  });

  test('greatCircleDistance', () async {
    expect(
      almostEqual(
        h3.greatCircleDistance(
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
        h3.greatCircleDistance(
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
      h3.greatCircleDistance(
        const GeoCoord(lat: 23, lon: 23),
        const GeoCoord(lat: 23, lon: 23),
        H3Units.rad,
      ),
      0,
      reason: 'Got expected angular distance for same point',
    );

    // Just rough tests for the other units
    final distKm = h3.greatCircleDistance(const GeoCoord(lat: 0, lon: 0),
        const GeoCoord(lat: 39, lon: -122), H3Units.km);

    expect(
      distKm > 12e3 && distKm < 13e3,
      true,
      reason: 'has some reasonable distance in Km',
    );

    final distM = h3.greatCircleDistance(
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

  test('getNumCells', () async {
    const expectedNumCells = [
      '122',
      '842',
      '5882',
      '41162',
      '288122',
      '2016842',
      '14117882',
      '98825162',
      '691776122',
      '4842432842',
      '33897029882',
      '237279209162',
      '1660954464122',
      '11626681248842',
      '81386768741882',
      '569707381193162',
    ];
    for (var res = 0; res < 16; res++) {
      expect(
        h3.getNumCells(res),
        BigInt.parse(expectedNumCells[res]),
      );
    }

    expect(
      () => h3.getNumCells(42),
      throwsA(isA<AssertionError>()),
      reason: 'throws on invalid resolution',
    );
  });

  test('getRes0Cells', () async {
    final indexes = h3.getRes0Cells();
    expect(indexes.length, 122, reason: 'Got expected count');
    expect(
      indexes.every(h3.isValidCell),
      true,
      reason: 'All indexes are valid',
    );
  });

  test('getPentagons', () async {
    for (var res = 0; res < 16; res++) {
      final indexes = h3.getPentagons(res);
      expect(
        indexes.length,
        12,
        reason: 'Got expected count',
      );
      expect(
        indexes.every(h3.isValidCell),
        true,
        reason: 'All indexes are valid',
      );
      expect(
        indexes.every(h3.isPentagon),
        true,
        reason: 'All indexes are pentagons',
      );
      expect(
        indexes.every((idx) => h3.getResolution(idx) == res),
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
      () => h3.getPentagons(42),
      throwsA(isA<AssertionError>()),
      reason: 'throws on invalid resolution',
    );
  });

  group('cellToVertex', () {
    test('Basic', () async {
      final origin = BigInt.parse('0x823d6ffffffffff');
      final verts = <BigInt>{};
      for (var i = 0; i < 6; i++) {
        final vert = h3.cellToVertex(origin, i);
        expect(h3.isValidVertex(vert), true);
        verts.add(vert);
      }
      expect(verts.length, 6, reason: 'vertexes are unique');
    });

    test('Invalid', () async {
      expect(
        () => h3.cellToVertex(BigInt.parse('0x823d6ffffffffff'), -1),
        throwsA(isA<AssertionError>()),
        reason: 'negative vertex number throws',
      );
      expect(
        () => h3.cellToVertex(BigInt.parse('0x823d6ffffffffff'), 6),
        throwsA(isA<H3Exception>()),
        reason: 'out of range vertex number throws',
      );
      expect(
        () => h3.cellToVertex(BigInt.parse('0x823007fffffffff'), 5),
        throwsA(isA<H3Exception>()),
        reason: 'out of range vertex number for pentagon throws',
      );
      expect(
        () => h3.cellToVertex(BigInt.parse('0xffffffffffffffff'), 5),
        throwsA(isA<H3Exception>()),
        reason: 'invalid cell throws',
      );
    });
  });

  group('isValidVertex', () {
    test('Basic', () async {
      expect(
        h3.isValidVertex(BigInt.parse('0xFFFFFFFFFFFFFFFF')),
        false,
        reason: 'all 1 is not a vertex',
      );
      expect(
        h3.isValidVertex(BigInt.parse('0x0')),
        false,
        reason: 'all 0 is not a vertex',
      );
      expect(
        h3.isValidVertex(BigInt.parse('0x823d6ffffffffff')),
        false,
        reason: 'cell is not a vertex',
      );
      expect(
        h3.isValidVertex(BigInt.parse('0x2222597fffffffff')),
        true,
        reason: 'vertex index is a vertex',
      );
    });
  });

  group('cellToVertexes', () {
    test('Basic', () async {
      final origin = BigInt.parse('0x823d6ffffffffff');
      final verts = h3.cellToVertexes(origin);
      expect(verts.length, 6, reason: 'vertexes have expected length');
      for (var i = 0; i < 6; i++) {
        final vert = h3.cellToVertex(origin, i);
        expect(
          verts.contains(vert),
          true,
          reason: 'cellToVertexes is exhaustive',
        );
        expect(
          h3.isValidVertex(vert),
          true,
          reason: 'cellToVertexes returns valid vertexes',
        );
      }
    });

    test('Pentagon', () async {
      final origin = BigInt.parse('0x823007fffffffff');
      final verts = h3.cellToVertexes(origin);
      expect(verts.length, 5, reason: 'vertexes have expected length');
      for (var i = 0; i < 5; i++) {
        final vert = h3.cellToVertex(origin, i);
        expect(
          verts.contains(vert),
          true,
          reason: 'cellToVertexes is exhaustive',
        );
        expect(
          h3.isValidVertex(vert),
          true,
          reason: 'cellToVertexes returns valid vertexes',
        );
      }
    });
  });

  group('vertexToGeo', () {
    test('Basic', () async {
      final origin = BigInt.parse('0x823d6ffffffffff');
      final bounds = h3.cellToBoundary(origin);
      for (var i = 0; i < 6; i++) {
        final vert = h3.cellToVertex(origin, i);
        final latlng = h3.vertexToGeo(vert);
        var found = false;
        for (final bound in bounds) {
          if (almostEqual(latlng.lat, bound.lat) &&
              almostEqual(latlng.lon, bound.lon)) {
            found = true;
            break;
          }
        }
        expect(found, true, reason: 'vertex latlng is present in cell bounds');
      }
    });

    test('Invalid', () async {
      expect(
        () => h3.vertexToGeo(BigInt.parse('0xffffffffffffffff')),
        throwsA(isA<H3Exception>()),
        reason: 'invalid vertex throws',
      );
    });
  });
}
