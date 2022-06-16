import 'package:flutter_test/flutter_test.dart';
import 'package:h3_flutter/h3_flutter.dart';

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
    GeoCoord buildA() => const GeoCoord(lat: 13, lon: 12);
    GeoCoord buildB() => const GeoCoord(lat: 12, lon: 13);
    testHashCode(buildA, buildB);
    testEquals(buildA, buildB);
    expect(
      buildA().toString(),
      'GeoCoord(lon: 12.0, lat: 13.0)',
      reason: 'GeoCoord.toString() works fine',
    );
    expect(
      const GeoCoord(lat: 13 + 180, lon: 12 + 360),
      const GeoCoord(lat: 13, lon: 12),
      reason: 'World-Wrapping +',
    );
    expect(
      const GeoCoord(lat: 13 - 180, lon: 12 - 360),
      const GeoCoord(lat: 13, lon: 12),
      reason: 'World-Wrapping -',
    );
  });

  test('H3Exception', () async {
    const testMessage = 'some message 123';
    expect(
      H3Exception(testMessage).toString(),
      contains(testMessage),
      reason: 'H3Exception.toString() shows message',
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
