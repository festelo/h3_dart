import 'dart:math';

import 'package:test/test.dart';
import 'package:h3_common/h3_common.dart';

void main() {
  test('CoordIJ', () async {
    CoordIJ buildA() => const CoordIJ(i: 13, j: 12);
    CoordIJ buildB() => const CoordIJ(i: 12, j: 13);
    testHashCode(buildA, buildB);
    testEquals(buildA, buildB);
    expect(
      buildA().toString(),
      'CoordIJ(i: 13, j: 12)',
      reason: 'CoordIJ.toString() works fine',
    );
  });

  test('GeoCoord', () async {
    const double latA = 13, lonA = 12;
    const double latB = 12, lonB = 13;
    const geoCoordConverter = GeoCoordConverter(NativeAngleConverter());

    GeoCoord buildA() => const GeoCoord(lat: latA, lon: lonA);
    GeoCoord buildB() => const GeoCoord(lat: latB, lon: lonB);
    testHashCode(buildA, buildB);
    testEquals(buildA, buildB);
    expect(
      buildA().toString(),
      allOf(contains(latA.toString()), contains(lonA.toString())),
      reason: 'GeoCoord.toString() works fine',
    );
    expect(
      // ignore: unrelated_type_equality_checks
      const GeoCoord(lat: latA, lon: latA) ==
          const GeoCoordRadians(lat: latA, lon: lonA),
      false,
      reason:
          'GeoCoord should not be equal to GeoCoordRadians if lat and lon are equal',
    );
    expect(
      // ignore: unrelated_type_equality_checks
      buildA() == buildA().toRadians(geoCoordConverter),
      false,
      reason: 'GeoCoord should never be equal to GeoCoordRadians for safety',
    );
    expect(
      const GeoCoord(lat: latA + 180, lon: lonA + 360),
      const GeoCoord(lat: latA, lon: lonA),
      reason: 'World-Wrapping +',
    );
    expect(
      const GeoCoord(lat: latA - 180, lon: lonA - 360),
      const GeoCoord(lat: latA, lon: lonA),
      reason: 'World-Wrapping -',
    );
  });

  test('GeoCoordRadians', () async {
    const latA = 0.3 * pi, lonA = 0.2 * pi;
    const latB = 0.2 * pi, lonB = 0.3 * pi;
    const geoCoordConverter = GeoCoordConverter(NativeAngleConverter());

    GeoCoordRadians buildA() => const GeoCoordRadians(lat: latA, lon: lonA);
    GeoCoordRadians buildB() =>
        const GeoCoordRadians(lat: latB * pi, lon: lonB);

    testHashCode(buildA, buildB);
    testEquals(buildA, buildB);

    expect(
      buildA().toString(),
      allOf(contains(latA.toString()), contains(latA.toString())),
      reason: 'GeoCoordRadians.toString() works fine',
    );
    expect(
      // ignore: unrelated_type_equality_checks
      const GeoCoordRadians(lat: latA, lon: latA) ==
          const GeoCoord(lat: latA, lon: lonA),
      false,
      reason:
          'GeoCoordRadians should not be equal to GeoCoord if lat and lon are equal',
    );
    expect(
      // ignore: unrelated_type_equality_checks
      buildA() == buildA().toDegrees(geoCoordConverter),
      false,
      reason: 'GeoCoordRadians should never be equal to GeoCoord for safety',
    );
    expect(
      const GeoCoordRadians(lat: latA + pi, lon: lonA + 2 * pi),
      const GeoCoordRadians(lat: latA, lon: lonA),
      reason: 'World-Wrapping +',
    );
    expect(
      const GeoCoordRadians(lat: latA - pi, lon: lonA - 2 * pi),
      const GeoCoordRadians(lat: latA, lon: lonA),
      reason: 'World-Wrapping -',
    );
  });

  test('H3Exception', () async {
    const testMessage = 'some message 123';
    expect(
      H3Exception(H3ExceptionCode.internal, testMessage).toString(),
      contains(testMessage),
      reason: 'H3Exception.toString() shows message',
    );

    for (final code in H3ExceptionCode.values) {
      if (code == H3ExceptionCode.internal) {
        continue;
      }

      final exception = H3Exception.fromCode(code);
      expect(
        exception.code,
        code,
        reason: 'H3Exception.fromCode(code) contains passed code',
      );
      expect(
        exception.message,
        isNotEmpty,
        reason: 'H3Exception.fromCode(code) has a message',
      );
    }

    expect(
      () => H3Exception.fromCode(H3ExceptionCode.internal),
      throwsA(isA<ArgumentError>()),
    );
  });
}

/// Test T.hashCode function
void testHashCode<T>(T Function() buildA, T Function() buildB) {
  expect(
    buildA().hashCode,
    buildA().hashCode,
    reason: 'hashCode is the same for the same $T',
  );

  expect(
    buildB().hashCode,
    isNot(buildA().hashCode),
    reason: 'hashCode is different for different $T',
  );
}

/// Test T.== operator
void testEquals<T>(T Function() buildA, T Function() buildB) {
  expect(
    buildA() == buildA(),
    true,
    reason: '== is true when $T are equal',
  );

  expect(
    buildA() == buildB(),
    false,
    reason: '== is false when $T are not equal',
  );
}
