import 'package:h3_common/h3_common.dart';
import 'package:h3_web/src/generated/types.dart' as h3_js;
import 'package:h3_web/src/mappers/big_int.dart';
import 'package:h3_web/src/mappers/units.dart';
import 'package:h3_web/src/mappers/js_error.dart';

class H3Web implements H3 {
  const H3Web();

  @override
  bool isValidCell(H3Index h3Index) {
    return h3_js.isValidCell(h3Index.toH3JS());
  }

  @override
  bool isPentagon(H3Index h3Index) {
    return h3_js.isPentagon(h3Index.toH3JS());
  }

  @override
  bool isResClassIII(H3Index h3Index) {
    return h3_js.isResClassIII(h3Index.toH3JS());
  }

  @override
  int getBaseCellNumber(H3Index h3Index) {
    return h3_js.getBaseCellNumber(h3Index.toH3JS()).toInt();
  }

  @override
  List<int> getIcosahedronFaces(H3Index h3Index) {
    return h3_js.getIcosahedronFaces(h3Index.toH3JS()).cast<int>();
  }

  @override
  int getResolution(H3Index h3Index) {
    if (!isValidCell(h3Index)) {
      throw AssertionError('H3Index is not valid.');
    }
    return h3_js.getResolution(h3Index.toH3JS()).toInt();
  }

  @override
  H3Index geoToCell(GeoCoord geoCoord, int res) {
    assert(res >= 0 && res < 16, 'Resolution must be in [0, 15] range');
    try {
      return h3_js.latLngToCell(geoCoord.lat, geoCoord.lon, res).toBigInt();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  GeoCoord cellToGeo(H3Index h3Index) {
    final res = h3_js.cellToLatLng(h3Index.toH3JS());
    return GeoCoord(lat: res[0].toDouble(), lon: res[1].toDouble());
  }

  @override
  List<GeoCoord> cellToBoundary(H3Index h3Index) {
    return h3_js
        .cellToBoundary(h3Index.toH3JS())
        .cast<dynamic>()
        .map((e) => List<num>.from(e))
        .map((e) => GeoCoord(lat: e[0].toDouble(), lon: e[1].toDouble()))
        .toList();
  }

  @override
  H3Index cellToParent(H3Index h3Index, int resolution) {
    assert(resolution >= 0 && resolution < 16,
        'Resolution must be in [0, 15] range');
    try {
      // ignore: unnecessary_cast
      final res = h3_js.cellToParent(h3Index.toH3JS(), resolution) as String?;
      if (res == null) {
        throw H3Exception(
          H3ExceptionCode.internal,
          'Unexpected error happened, check the input',
        );
      }
      return res.toBigInt();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  List<H3Index> cellToChildren(H3Index h3Index, int resolution) {
    assert(resolution >= 0 && resolution < 16,
        'Resolution must be in [0, 15] range');
    try {
      return h3_js
          .cellToChildren(h3Index.toH3JS(), resolution)
          .cast<String>()
          .map((e) => e.toBigInt())
          .toList();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  int cellToChildrenSize(H3Index h3Index, int resolution) {
    assert(resolution >= 0 && resolution < 16,
        'Resolution must be in [0, 15] range');
    try {
      return h3_js.cellToChildrenSize(h3Index.toH3JS(), resolution).toInt();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  H3Index cellToCenterChild(H3Index h3Index, int resolution) {
    assert(resolution >= 0 && resolution < 16,
        'Resolution must be in [0, 15] range');
    try {
      // ignore: unnecessary_cast
      final res = h3_js.cellToCenterChild(
        h3Index.toH3JS(),
        resolution,
      ) as String?;
      if (res == null) {
        return BigInt.zero;
      }
      return res.toBigInt();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  int cellToChildPos(
    H3Index h3Index,
    int parentResolution,
  ) {
    assert(parentResolution >= 0 && parentResolution < 16,
        'Resolution must be in [0, 15] range');
    try {
      return h3_js.cellToChildPos(h3Index.toH3JS(), parentResolution).toInt();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  H3Index childPosToCell(
    int childPosition,
    H3Index h3Index,
    int childResolution,
  ) {
    assert(childResolution >= 0 && childResolution < 16,
        'Resolution must be in [0, 15] range');
    try {
      return h3_js
          .childPosToCell(childPosition, h3Index.toH3JS(), childResolution)
          .toBigInt();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  List<H3Index> gridDisk(H3Index h3Index, int ringSize) {
    try {
      return h3_js
          .gridDisk(h3Index.toH3JS(), ringSize)
          .cast<String>()
          .map((e) => e.toBigInt())
          .toList();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  List<List<H3Index>> gridDiskDistances(H3Index h3Index, int ringSize) {
    try {
      return h3_js
          .gridDiskDistances(h3Index.toH3JS(), ringSize)
          .cast<List>()
          .map((e) => e.cast<String>().map((e) => e.toBigInt()).toList())
          .toList();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  List<H3Index> gridRingUnsafe(H3Index h3Index, int ringSize) {
    try {
      return h3_js
          .gridRingUnsafe(h3Index.toH3JS(), ringSize)
          .cast<String>()
          .map((e) => e.toBigInt())
          .toList();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  List<H3Index> polygonToCells({
    required List<GeoCoord> perimeter,
    required int resolution,
    List<List<GeoCoord>> holes = const [],
  }) {
    assert(resolution >= 0 && resolution < 16,
        'Resolution must be in [0, 15] range');
    try {
      return h3_js
          .polygonToCells(
            [
              perimeter.map((e) => [e.lat, e.lon]).toList(),
              ...holes.map((arr) => arr.map((e) => [e.lat, e.lon]).toList()),
            ],
            resolution,
          )
          .cast<String>()
          .map((e) => e.toBigInt())
          .toList();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  List<H3Index> polygonToCellsExperimental({
    required List<GeoCoord> perimeter,
    required int resolution,
    List<List<GeoCoord>> holes = const [],
    PolygonToCellFlags flag = PolygonToCellFlags.containmentCenter,
  }) {
    assert(resolution >= 0 && resolution < 16,
        'Resolution must be in [0, 15] range');
    try {
      return h3_js
          .polygonToCellsExperimental(
            [
              perimeter.map((e) => [e.lat, e.lon]).toList(),
              ...holes.map((arr) => arr.map((e) => [e.lat, e.lon]).toList()),
            ],
            resolution,
            flag.name,
          )
          .cast<String>()
          .map((e) => e.toBigInt())
          .toList();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  List<List<List<GeoCoord>>> cellsToMultiPolygon(List<H3Index> h3Indexes) {
    return h3_js
        .cellsToMultiPolygon(h3Indexes.map((e) => e.toH3JS()).toList())
        .cast<List>()
        .map(
          (e) => e
              .cast<List>()
              .map(
                (e) => e
                    .map(
                      (e) => GeoCoord(
                        lat: (e[0] as num).toDouble(),
                        lon: (e[1] as num).toDouble(),
                      ),
                    )
                    .toList(),
              )
              .toList(),
        )
        .toList();
  }

  @override
  List<H3Index> compactCells(List<H3Index> hexagons) {
    try {
      return h3_js
          .compactCells(hexagons.map((e) => e.toH3JS()).toList())
          .cast<String>()
          .map((e) => e.toBigInt())
          .toList();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  List<BigInt> uncompactCells(
    List<BigInt> compactedHexagons, {
    required int resolution,
  }) {
    try {
      assert(resolution >= 0 && resolution < 16,
          'Resolution must be in [0, 15] range');

      return h3_js
          .uncompactCells(
            compactedHexagons.map((e) => e.toH3JS()).toList(),
            resolution,
          )
          .cast<String>()
          .map((e) => e.toBigInt())
          .toList();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  bool areNeighborCells(H3Index origin, H3Index destination) {
    try {
      return h3_js.areNeighborCells(
        origin.toH3JS(),
        destination.toH3JS(),
      );
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  BigInt cellsToDirectedEdge(BigInt origin, BigInt destination) {
    try {
      // ignore: unnecessary_cast
      final res = h3_js.cellsToDirectedEdge(
        origin.toH3JS(),
        destination.toH3JS(),
      ) as String?;
      if (res == null) {
        return BigInt.zero;
      }
      return res.toBigInt();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  H3Index getDirectedEdgeOrigin(H3Index edgeIndex) {
    try {
      // ignore: unnecessary_cast
      final res = h3_js.getDirectedEdgeOrigin(edgeIndex.toH3JS()) as String?;
      if (res == null) {
        return BigInt.zero;
      }
      return res.toBigInt();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  H3Index getDirectedEdgeDestination(H3Index edgeIndex) {
    try {
      // ignore: unnecessary_cast
      final res =
          h3_js.getDirectedEdgeDestination(edgeIndex.toH3JS()) as String?;
      if (res == null) {
        return BigInt.zero;
      }
      return res.toBigInt();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  bool isValidDirectedEdge(H3Index edgeIndex) {
    return h3_js.isValidDirectedEdge(edgeIndex.toH3JS());
  }

  @override
  ({H3Index origin, H3Index destination}) directedEdgeToCells(
    H3Index edgeIndex,
  ) {
    final res = h3_js
        .directedEdgeToCells(edgeIndex.toH3JS())
        .cast<String>()
        .map((e) => e.toBigInt())
        .toList();

    return (origin: res[0], destination: res[1]);
  }

  @override
  List<H3Index> originToDirectedEdges(BigInt edgeIndex) {
    return h3_js
        .originToDirectedEdges(edgeIndex.toH3JS())
        .cast<String>()
        .map((e) => e.toBigInt())
        .toList();
  }

  @override
  List<GeoCoord> directedEdgeToBoundary(BigInt edgeIndex) {
    return h3_js
        .directedEdgeToBoundary(edgeIndex.toH3JS())
        .cast<dynamic>()
        .map((e) => List<num>.from(e))
        .map((e) => GeoCoord(lat: e[0].toDouble(), lon: e[1].toDouble()))
        .toList();
  }

  @override
  int gridDistance(H3Index origin, H3Index destination) {
    try {
      return h3_js.gridDistance(origin.toH3JS(), destination.toH3JS()).toInt();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  List<H3Index> gridPathCells(H3Index origin, H3Index destination) {
    try {
      return h3_js
          .gridPathCells(origin.toH3JS(), destination.toH3JS())
          .cast<String>()
          .map((e) => e.toBigInt())
          .toList();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  CoordIJ cellToLocalIj(H3Index origin, H3Index destination) {
    try {
      final res = h3_js.cellToLocalIj(origin.toH3JS(), destination.toH3JS());
      return CoordIJ(
        i: res.i.toInt(),
        j: res.j.toInt(),
      );
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  H3Index localIjToCell(H3Index origin, CoordIJ coordinates) {
    try {
      return h3_js
          .localIjToCell(
            origin.toH3JS(),
            h3_js.CoordIJ(
              i: coordinates.i,
              j: coordinates.j,
            ),
          )
          .toBigInt();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  double greatCircleDistance(GeoCoord a, GeoCoord b, H3Units unit) {
    return h3_js.greatCircleDistance(
      [a.lat, a.lon],
      [b.lat, b.lon],
      unit.toH3JS(),
    ).toDouble();
  }

  @override
  double cellArea(BigInt h3Index, H3Units unit) {
    return h3_js
        .cellArea(
          h3Index.toH3JS(),
          unit.toH3JSSquare(),
        )
        .toDouble();
  }

  @override
  double edgeLength(H3Index edgeIndex, H3Units unit) {
    return h3_js
        .edgeLength(
          edgeIndex.toH3JS(),
          unit.toH3JS(),
        )
        .toDouble();
  }

  @override
  double getHexagonAreaAvg(int resolution, H3MetricUnits unit) {
    assert(
      resolution >= 0 && resolution < 16,
      'Resolution must be in [0, 15] range',
    );
    return h3_js
        .getHexagonAreaAvg(
          resolution,
          unit.toH3JSSquare(),
        )
        .toDouble();
  }

  @override
  double getHexagonEdgeLengthAvg(int res, H3MetricUnits unit) {
    assert(res >= 0 && res < 16, 'Resolution must be in [0, 15] range');
    return h3_js
        .getHexagonEdgeLengthAvg(
          res,
          unit.toH3JS(),
        )
        .toDouble();
  }

  @override
  H3Index cellToVertex(H3Index h3Index, int vertexNum) {
    assert(vertexNum >= 0);
    try {
      return h3_js.cellToVertex(h3Index.toH3JS(), vertexNum).toBigInt();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  List<H3Index> cellToVertexes(H3Index h3Index) {
    return h3_js
        .cellToVertexes(h3Index.toH3JS())
        .cast<String>()
        .map((e) => e.toBigInt())
        .toList();
  }

  @override
  GeoCoord vertexToGeo(H3Index h3Index) {
    try {
      final res = h3_js.vertexToLatLng(h3Index.toH3JS());
      return GeoCoord(
        lat: res[0].toDouble(),
        lon: res[1].toDouble(),
      );
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  bool isValidVertex(H3Index h3Index) {
    return h3_js.isValidVertex(h3Index.toH3JS());
  }

  @override
  BigInt getNumCells(int resolution) {
    assert(
      resolution >= 0 && resolution < 16,
      'Resolution must be in [0, 15] range',
    );
    return BigInt.from(h3_js.getNumCells(resolution));
  }

  @override
  List<H3Index> getRes0Cells() {
    return h3_js
        .getRes0Cells()
        .cast<String>()
        .map((e) => e.toBigInt())
        .toList();
  }

  @override
  List<H3Index> getPentagons(int res) {
    assert(res >= 0 && res < 16, 'Resolution must be in [0, 15] range');
    return h3_js
        .getPentagons(res)
        .cast<String>()
        .map((e) => e.toBigInt())
        .toList();
  }

  @override
  double degsToRads(double val) => h3_js.degsToRads(val).toDouble();

  @override
  double radsToDegs(double val) => h3_js.radsToDegs(val).toDouble();
}
