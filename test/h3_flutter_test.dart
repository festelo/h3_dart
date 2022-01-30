import 'dart:ffi';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:h3_flutter/h3_flutter.dart';
import 'package:h3_flutter/internal.dart';
import 'package:collection/collection.dart';

import 'utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final lib = DynamicLibrary.open('c/h3lib/build/libh3lib.dylib');
  setUpAll(() {
    initH3C(lib);
  });
  test('h3IsValid', () async {
    expect(
      h3.h3IsValid(0x85283473fffffff),
      true,
      reason: 'H3 index is considered an index',
    );
    expect(
      h3.h3IsValid(0x821C37FFFFFFFFF),
      true,
      reason: 'H3 index in upper case is considered an index',
    );
    expect(
      h3.h3IsValid(0x085283473fffffff),
      true,
      reason: 'H3 index with leading zero is considered an index',
    );
    expect(
      !h3.h3IsValid(0xff283473fffffff),
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
      0x85283473fffffff,
      reason: 'Got the expected H3 index back',
    );
    expect(
      h3.geoToH3(const GeoCoord(lat: 30.943387, lon: -164.991559), 5),
      0x8547732ffffffff,
      reason: 'Properly handle 8 Fs',
    );
    expect(
      h3.geoToH3(
          const GeoCoord(lat: 46.04189431883772, lon: 71.52790329909925), 15),
      0x8f2000000000000,
      reason: 'Properly handle leading zeros',
    );
    expect(
      h3.geoToH3(const GeoCoord(lat: 37.3615593, lon: -122.0553238 + 360), 5),
      0x85283473fffffff,
      reason: 'world-wrapping lng accepted',
    );
  });
  test('h3GetResolution', () async {
    expect(
      () => h3.h3GetResolution(-1),
      throwsA(isA<H3Exception>()),
      reason: 'Throws assertation error when an invalid index is passed',
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
      ComparableGeoCoord.fromGeoCoord(h3.h3ToGeo(0x85283473fffffff)),
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
          h3.kRing(0x8928308280fffff, 1),
          [
            0x8928308280fffff,
            0x8928308280bffff,
            0x89283082807ffff,
            0x89283082877ffff,
            0x89283082803ffff,
            0x89283082873ffff,
            0x8928308283bffff,
          ],
        ),
        true,
      );
    });
    test('k = 2', () async {
      expect(
        const DeepCollectionEquality.unordered().equals(
          h3.kRing(0x8928308280fffff, 2),
          [
            0x89283082813ffff,
            0x89283082817ffff,
            0x8928308281bffff,
            0x89283082863ffff,
            0x89283082823ffff,
            0x89283082873ffff,
            0x89283082877ffff,
            0x8928308287bffff,
            0x89283082833ffff,
            0x8928308282bffff,
            0x8928308283bffff,
            0x89283082857ffff,
            0x892830828abffff,
            0x89283082847ffff,
            0x89283082867ffff,
            0x89283082803ffff,
            0x89283082807ffff,
            0x8928308280bffff,
            0x8928308280fffff
          ],
        ),
        true,
      );
    });
    test('Bad Radius', () async {
      expect(
        const DeepCollectionEquality.unordered().equals(
          h3.kRing(0x8928308280fffff, -7),
          [0x8928308280fffff],
        ),
        true,
      );
    });
    test('Pentagon', () async {
      expect(
        const DeepCollectionEquality.unordered().equals(
          h3.kRing(0x821c07fffffffff, 1),
          [
            0x821c2ffffffffff,
            0x821c27fffffffff,
            0x821c07fffffffff,
            0x821c17fffffffff,
            0x821c1ffffffffff,
            0x821c37fffffffff,
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
          h3.kRing(0x8928308324bffff, 1),
          [
            0x8928308324bffff,
            0x892830989b3ffff,
            0x89283098987ffff,
            0x89283098997ffff,
            0x8928308325bffff,
            0x89283083243ffff,
            0x8928308324fffff,
          ],
        ),
        true,
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
      final coordinates = h3.h3ToGeoBoundary(0x85283473fffffff);
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
      final coordinates = h3.h3ToGeoBoundary(0x81623ffffffffff);
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
        throwsAssertionError,
      );
    });
  });
}
