import 'package:h3_common/h3_common.dart';
import 'package:h3_web/src/generated/types.dart' as h3_js;
import 'package:h3_web/src/mappers/big_int.dart';
import 'package:h3_web/src/mappers/units.dart';
import 'package:h3_web/src/mappers/js_error.dart';

class H3Web implements H3 {
  const H3Web();

  @override
  bool h3IsValid(BigInt h3Index) {
    return h3_js.h3IsValid(bigIntToH3JS(h3Index));
  }

  @override
  bool h3IsPentagon(BigInt h3Index) {
    return h3_js.h3IsPentagon(bigIntToH3JS(h3Index));
  }

  @override
  bool h3IsResClassIII(BigInt h3Index) {
    return h3_js.h3IsResClassIII(bigIntToH3JS(h3Index));
  }

  @override
  int h3GetBaseCell(BigInt h3Index) {
    return h3_js.h3GetBaseCell(bigIntToH3JS(h3Index)).toInt();
  }

  @override
  List<int> h3GetFaces(BigInt h3Index) {
    return h3_js.h3GetFaces(bigIntToH3JS(h3Index)).cast<int>();
  }

  @override
  int h3GetResolution(BigInt h3Index) {
    if (!h3IsValid(h3Index)) {
      throw H3Exception('H3Index is not valid.');
    }
    return h3_js.h3GetResolution(bigIntToH3JS(h3Index)).toInt();
  }

  @override
  BigInt geoToH3(GeoCoord geoCoord, int res) {
    assert(res >= 0 && res < 16, 'Resolution must be in [0, 15] range');
    return h3_js.geoToH3(geoCoord.lat, geoCoord.lon, res).toBigInt();
  }

  @override
  GeoCoord h3ToGeo(BigInt h3Index) {
    final res = h3_js.h3ToGeo(bigIntToH3JS(h3Index));
    return GeoCoord(lat: res[0].toDouble(), lon: res[1].toDouble());
  }

  @override
  List<GeoCoord> h3ToGeoBoundary(BigInt h3Index) {
    final res = h3_js.h3ToGeoBoundary(bigIntToH3JS(h3Index));
    return res
        .map((e) => GeoCoord(lat: e[0].toDouble(), lon: e[1].toDouble()))
        .toList();
  }

  @override
  BigInt h3ToParent(BigInt h3Index, int resolution) {
    // ignore: unnecessary_nullable_for_final_variable_declarations
    final String? res = h3_js.h3ToParent(bigIntToH3JS(h3Index), resolution);
    if (res == null) {
      return BigInt.zero;
    }
    return res.toBigInt();
  }

  @override
  List<BigInt> h3ToChildren(BigInt h3Index, int resolution) {
    if (!h3IsValid(h3Index)) {
      return [];
    }
    return h3_js
        .h3ToChildren(bigIntToH3JS(h3Index), resolution)
        .map((e) => e.toBigInt())
        .toList();
  }

  @override
  BigInt h3ToCenterChild(BigInt h3Index, int resolution) {
    // ignore: unnecessary_nullable_for_final_variable_declarations
    final String? res = h3_js.h3ToCenterChild(
      bigIntToH3JS(h3Index),
      resolution,
    );
    if (res == null) {
      return BigInt.zero;
    }
    return res.toBigInt();
  }

  @override
  List<BigInt> kRing(BigInt h3Index, int ringSize) {
    return h3_js
        .kRing(bigIntToH3JS(h3Index), ringSize)
        .map((e) => e.toBigInt())
        .toList();
  }

  @override
  List<BigInt> hexRing(BigInt h3Index, int ringSize) {
    try {
      return h3_js
          .hexRing(bigIntToH3JS(h3Index), ringSize)
          .map((e) => e.toBigInt())
          .toList();
    } catch (e) {
      final message = getJsErrorMessage(e);
      if (message == 'Failed to get hexRing (encountered a pentagon?)') {
        throw H3Exception('Failed to get hexRing (encountered a pentagon?)');
      }
      rethrow;
    }
  }

  @override
  List<BigInt> polyfill({
    required List<GeoCoord> coordinates,
    required int resolution,
  }) {
    assert(resolution >= 0 && resolution < 16,
        'Resolution must be in [0, 15] range');
    return h3_js
        .polyfill(coordinates.map((e) => [e.lat, e.lon]).toList(), resolution)
        .map((e) => e.toBigInt())
        .toList();
  }

  @override
  List<BigInt> compact(List<BigInt> hexagons) {
    return h3_js
        .compact(hexagons.map((e) => e.toRadixString(16)).toList())
        .map((e) => e.toBigInt())
        .toList();
  }

  @override
  List<BigInt> uncompact(
    List<BigInt> compactedHexagons, {
    required int resolution,
  }) {
    try {
      assert(resolution >= 0 && resolution < 16,
          'Resolution must be in [0, 15] range');

      return h3_js
          .uncompact(
            compactedHexagons.map((e) => e.toRadixString(16)).toList(),
            resolution,
          )
          .map((e) => e.toBigInt())
          .toList();
    } catch (e) {
      final message = getJsErrorMessage(e);
      if (message == 'Failed to uncompact (bad resolution?)') {
        throw H3Exception('Failed to uncompact (bad resolution?)');
      }
      rethrow;
    }
  }

  @override
  bool h3IndexesAreNeighbors(BigInt origin, BigInt destination) {
    return h3_js.h3IndexesAreNeighbors(
      origin.toRadixString(16),
      destination.toRadixString(16),
    );
  }

  @override
  BigInt getH3UnidirectionalEdge(BigInt origin, BigInt destination) {
    // ignore: unnecessary_nullable_for_final_variable_declarations
    final String? res = h3_js.getH3UnidirectionalEdge(
      origin.toRadixString(16),
      destination.toRadixString(16),
    );
    if (res == null) {
      return BigInt.zero;
    }
    return res.toBigInt();
  }

  @override
  BigInt getOriginH3IndexFromUnidirectionalEdge(BigInt edgeIndex) {
    // ignore: unnecessary_nullable_for_final_variable_declarations
    final String? res = h3_js
        .getOriginH3IndexFromUnidirectionalEdge(edgeIndex.toRadixString(16));
    if (res == null) {
      return BigInt.zero;
    }
    return res.toBigInt();
  }

  @override
  BigInt getDestinationH3IndexFromUnidirectionalEdge(BigInt edgeIndex) {
    // ignore: unnecessary_nullable_for_final_variable_declarations
    final String? res = h3_js.getDestinationH3IndexFromUnidirectionalEdge(
        edgeIndex.toRadixString(16));
    if (res == null) {
      return BigInt.zero;
    }
    return res.toBigInt();
  }

  @override
  bool h3UnidirectionalEdgeIsValid(BigInt edgeIndex) {
    return h3_js.h3UnidirectionalEdgeIsValid(edgeIndex.toRadixString(16));
  }

  @override
  List<BigInt> getH3IndexesFromUnidirectionalEdge(BigInt edgeIndex) {
    return h3_js
        .getH3IndexesFromUnidirectionalEdge(edgeIndex.toRadixString(16))
        .map((e) => e.toBigInt())
        .toList();
  }

  @override
  List<BigInt> getH3UnidirectionalEdgesFromHexagon(BigInt edgeIndex) {
    return h3_js
        .getH3UnidirectionalEdgesFromHexagon(edgeIndex.toRadixString(16))
        .map((e) => e.toBigInt())
        .toList();
  }

  @override
  List<GeoCoord> getH3UnidirectionalEdgeBoundary(BigInt edgeIndex) {
    return h3_js
        .getH3UnidirectionalEdgeBoundary(edgeIndex.toRadixString(16))
        .map((e) => GeoCoord(lat: e[0].toDouble(), lon: e[1].toDouble()))
        .toList();
  }

  @override
  int h3Distance(BigInt origin, BigInt destination) {
    return h3_js
        .h3Distance(origin.toRadixString(16), destination.toRadixString(16))
        .toInt();
  }

  @override
  List<BigInt> h3Line(BigInt origin, BigInt destination) {
    try {
      return h3_js
          .h3Line(origin.toRadixString(16), destination.toRadixString(16))
          .map((e) => e.toBigInt())
          .toList();
    } catch (e) {
      final message = getJsErrorMessage(e);
      if (message == 'Line cannot be calculated') {
        throw H3Exception('Line cannot be calculated');
      }
      rethrow;
    }
  }

  @override
  CoordIJ experimentalH3ToLocalIj(BigInt origin, BigInt destination) {
    try {
      final res = h3_js.experimentalH3ToLocalIj(
          origin.toRadixString(16), destination.toRadixString(16));
      return CoordIJ(
        i: res.i.toInt(),
        j: res.j.toInt(),
      );
    } catch (e) {
      final message = getJsErrorMessage(e);
      if (message == 'Incompatible origin and index.') {
        throw H3Exception('Incompatible origin and index.');
      }
      if (message ==
          'Local IJ coordinates undefined for this origin and index pair. '
              'The index may be too far from the origin.') {
        throw H3Exception(
            'Local IJ coordinates undefined for this origin and index pair. '
            'The index may be too far from the origin.');
      }
      if (message == 'Encountered possible pentagon distortion') {
        throw H3Exception('Encountered possible pentagon distortion');
      }
      rethrow;
    }
  }

  @override
  BigInt experimentalLocalIjToH3(BigInt origin, CoordIJ coordinates) {
    try {
      return h3_js
          .experimentalLocalIjToH3(
            origin.toRadixString(16),
            h3_js.CoordIJ(
              i: coordinates.i,
              j: coordinates.j,
            ),
          )
          .toBigInt();
    } catch (e) {
      final message = getJsErrorMessage(e);
      if (message ==
          'Index not defined for this origin and IJ coordinates pair. '
              'IJ coordinates may be too far from origin, or '
              'a pentagon distortion was encountered.') {
        throw H3Exception(
          'Index not defined for this origin and IJ coordinates pair. '
          'IJ coordinates may be too far from origin, or '
          'a pentagon distortion was encountered.',
        );
      }
      rethrow;
    }
  }

  @override
  double pointDist(GeoCoord a, GeoCoord b, H3Units unit) {
    return h3_js.pointDist(
      [a.lat, a.lon],
      [b.lat, b.lon],
      unit.toH3JS(),
    ).toDouble();
  }

  @override
  double cellArea(BigInt h3Index, H3Units unit) {
    return h3_js
        .cellArea(
          bigIntToH3JS(h3Index),
          unit.toH3JSSquare(),
        )
        .toDouble();
  }

  @override
  double exactEdgeLength(BigInt edgeIndex, H3Units unit) {
    return h3_js
        .exactEdgeLength(
          edgeIndex.toRadixString(16),
          unit.toH3JS(),
        )
        .toDouble();
  }

  @override
  double hexArea(int res, H3AreaUnits unit) {
    assert(res >= 0 && res < 16, 'Resolution must be in [0, 15] range');
    return h3_js
        .hexArea(
          res,
          unit.toH3JS(),
        )
        .toDouble();
  }

  @override
  double edgeLength(int res, H3EdgeLengthUnits unit) {
    assert(res >= 0 && res < 16, 'Resolution must be in [0, 15] range');
    return h3_js
        .edgeLength(
          res,
          unit.toH3JS(),
        )
        .toDouble();
  }

  @override
  int numHexagons(int res) {
    assert(res >= 0 && res < 16, 'Resolution must be in [0, 15] range');
    return h3_js.numHexagons(res).toInt();
  }

  @override
  List<BigInt> getRes0Indexes() {
    return h3_js.getRes0Indexes().map((e) => e.toBigInt()).toList();
  }

  @override
  List<BigInt> getPentagonIndexes(int res) {
    assert(res >= 0 && res < 16, 'Resolution must be in [0, 15] range');
    return h3_js.getPentagonIndexes(res).map((e) => e.toBigInt()).toList();
  }

  @override
  double radsToDegs(double val) => h3_js.radsToDegs(val).toDouble();

  @override
  double degsToRads(double val) => h3_js.degsToRads(val).toDouble();
}
