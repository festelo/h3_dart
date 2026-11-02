// Checks the JS boundary itself: error codes, large results and value ranges.
// Run it on both compilers:
//   dart test -p chrome
//   dart test -p chrome -c dart2wasm
import 'package:h3_web/h3_web.dart';
import 'package:test/test.dart';

import 'h3_js_injector.dart';

Matcher throwsH3(H3ExceptionCode code) => throwsA(
      isA<H3Exception>().having((e) => e.code, 'code', code),
    );

void main() {
  const h3 = H3Web();
  final cell = BigInt.parse('0x85283473fffffff'); // resolution 5

  setUpAll(() async {
    await inject('https://unpkg.com/h3-js@4.2.1');
  });

  test('isH3JsLoaded is true once h3-js is on the page', () {
    expect(H3Web.isH3JsLoaded, isTrue);
  });

  group('h3-js errors become H3Exception with the H3 error code', () {
    test('latitude that is not a number', () {
      expect(
        () => h3.geoToCell(const GeoCoord(lat: double.nan, lon: 0), 5),
        throwsH3(H3ExceptionCode.latlngDomain),
      );
    });

    test('parent resolution finer than the cell', () {
      expect(
        () => h3.cellToParent(cell, 7),
        throwsH3(H3ExceptionCode.resolutionMismatch),
      );
    });

    test('child position for a coarser child resolution', () {
      expect(
        () => h3.childPosToCell(0, cell, 4),
        throwsH3(H3ExceptionCode.resolutionMismatch),
      );
    });

    test('neighbours at different resolutions', () {
      expect(
        () => h3.areNeighborCells(cell, h3.cellToCenterChild(cell, 6)),
        throwsH3(H3ExceptionCode.resolutionMismatch),
      );
    });

    test('ring that crosses a pentagon', () {
      final pentagon = h3.getPentagons(5).first;
      expect(
        () => h3.gridRingUnsafe(h3.gridDisk(pentagon, 1).last, 1),
        throwsH3(H3ExceptionCode.pentagon),
      );
    });
  });

  group('Dart errors pass through unchanged', () {
    // The catch blocks see these before h3-js is called. Under dart2wasm a
    // cast of a Dart object to JSObject throws a TypeError, which would hide
    // the real error.
    test('AssertionError', () {
      expect(() => h3.cellToParent(cell, 16), throwsA(isA<AssertionError>()));
    });

    test('H3Exception thrown by H3Web itself', () {
      expect(
        () => h3.getResolution(BigInt.zero),
        throwsH3(H3ExceptionCode.internal),
      );
    });
  });

  group('values cross the boundary without loss', () {
    test('64-bit indexes keep all bits', () {
      // Res 15 indexes use all 64 bits, more than a JS number can hold.
      final fine = h3.geoToCell(const GeoCoord(lat: 37.775, lon: -122.418), 15);
      expect(fine.bitLength, greaterThan(53));
      expect(h3.getResolution(fine), 15);
      expect(h3.cellToParent(fine, 5), h3.cellToParent(fine, 5));
      expect(h3.isValidCell(fine), isTrue);
      expect(h3.geoToCell(h3.cellToGeo(fine), 15), fine);
    });

    test('cell counts larger than 32 bits', () {
      expect(h3.getNumCells(15), BigInt.parse('569707381193162'));
      expect(h3.cellToChildrenSize(h3.getRes0Cells().first, 15),
          greaterThan(1 << 32));
    });

    test('doubles keep full precision', () {
      final center = h3.cellToGeo(cell);
      expect(h3.geoToCell(center, 5), cell);
      expect(h3.cellArea(cell, H3Units.km), closeTo(265.09, 0.01));
    });

    test('nested arrays from cellsToMultiPolygon', () {
      final disk = h3.gridDisk(cell, 2);
      final polygons = h3.cellsToMultiPolygon(disk);
      expect(polygons, hasLength(1), reason: 'a disk is one polygon');
      expect(polygons.single, hasLength(1), reason: 'and has no holes');
      expect(polygons.single.single, hasLength(30));
    });

    test('polygon with a hole', () {
      final outer = h3.cellToBoundary(h3.cellToParent(cell, 3));
      final hole = h3.cellToBoundary(cell);
      final withHole = h3.polygonToCells(
        perimeter: outer,
        holes: [hole],
        resolution: 6,
      );
      final withoutHole = h3.polygonToCells(perimeter: outer, resolution: 6);
      expect(withHole.length, lessThan(withoutHole.length));
      expect(withHole.toSet().intersection(h3.cellToChildren(cell, 6).toSet()),
          isEmpty);
    });
  });

  test('large results: 117,649 cells in and out', () {
    final base = h3.getRes0Cells().firstWhere((c) => !h3.isPentagon(c));
    final watch = Stopwatch()..start();

    final children = h3.cellToChildren(base, 6);
    expect(children, hasLength(117649)); // 7^6
    expect(children.toSet(), hasLength(117649));

    final compacted = h3.compactCells(children);
    expect(compacted, [base]);

    // Compare with Set methods: expect(set, set) is quadratic in matcher.
    final back = h3.uncompactCells(compacted, resolution: 6).toSet();
    expect(back.length, children.length);
    expect(back.containsAll(children), isTrue);

    watch.stop();
    printOnFailure('took ${watch.elapsedMilliseconds} ms');
    expect(watch.elapsed, lessThan(const Duration(seconds: 10)));
  });
}
