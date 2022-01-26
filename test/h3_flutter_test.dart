import 'dart:ffi';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:h3_flutter/h3_flutter.dart';
import 'package:h3_flutter/internal.dart';

import 'utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final lib = DynamicLibrary.open('c/h3lib/build/libh3lib.dylib');
  setUpAll(() {
    initH3C(lib);
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
      final hexagons = h3.polyfill(
        coordinates: const [
          GeoCoord(lat: 0.5729577951308232, lon: -179.4270422048692),
          GeoCoord(lat: 0.5729577951308232, lon: 179.4270422048692),
          GeoCoord(lat: -0.5729577951308232, lon: 179.4270422048692),
          GeoCoord(lat: -0.5729577951308232, lon: -179.4270422048692),
        ],
        resolution: -9,
      );
      expect(
        hexagons.length,
        0,
      );
    });
  });
}
