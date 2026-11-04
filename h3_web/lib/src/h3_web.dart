import 'dart:js_interop';

import 'package:h3_common/h3_common.dart';
import 'package:h3_web/src/js/h3_js.dart';
import 'package:h3_web/src/mappers/coords.dart';
import 'package:h3_web/src/mappers/h3_index.dart';
import 'package:h3_web/src/mappers/units.dart';
import 'package:h3_web/src/mappers/errors.dart';

/// H3 for the web, built on [h3-js](https://github.com/uber/h3-js).
///
/// Works when the app is compiled with dart2js and with dart2wasm
/// (`flutter build web --wasm`). h3-js must be loaded on the page first;
/// see [isH3JsLoaded].
class H3Web implements H3 {
  const H3Web();

  /// Whether h3-js is loaded on the page.
  ///
  /// Every other method throws a [StateError] while this is `false`.
  static bool get isH3JsLoaded => isH3JsLoadedOnPage;

  @override
  bool isValidCell(H3Index h3Index) {
    return h3js.isValidCell(h3Index.toH3JS());
  }

  @override
  bool isValidIndex(H3Index h3Index) {
    return h3js.isValidIndex(h3Index.toH3JS());
  }

  @override
  bool isPentagon(H3Index h3Index) {
    return h3js.isPentagon(h3Index.toH3JS());
  }

  @override
  bool isResClassIII(H3Index h3Index) {
    return h3js.isResClassIII(h3Index.toH3JS());
  }

  @override
  int getBaseCellNumber(H3Index h3Index) {
    return h3js.getBaseCellNumber(h3Index.toH3JS());
  }

  @override
  int getIndexDigit(H3Index h3Index, int digit) {
    try {
      return h3js.getIndexDigit(h3Index.toH3JS(), digit);
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  H3Index constructCell(
    int baseCellNumber,
    List<int> digits, {
    int? resolution,
  }) {
    try {
      return h3js
          .constructCell(
            baseCellNumber,
            [for (final digit in digits) digit.toJS].toJS,
            resolution ?? digits.length,
          )
          .toH3Index();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  List<int> getIcosahedronFaces(H3Index h3Index) {
    return [
      for (final face in h3js.getIcosahedronFaces(h3Index.toH3JS()).toDart)
        face.toDartInt,
    ];
  }

  @override
  int getResolution(H3Index h3Index) {
    if (!isValidCell(h3Index)) {
      throw H3Exception(
        H3ExceptionCode.internal,
        'H3Index is not valid.',
      );
    }
    return h3js.getResolution(h3Index.toH3JS());
  }

  @override
  H3Index geoToCell(GeoCoord geoCoord, int res) {
    assert(res >= 0 && res < 16, 'Resolution must be in [0, 15] range');
    try {
      return h3js.latLngToCell(geoCoord.lat, geoCoord.lon, res).toH3Index();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  GeoCoord cellToGeo(H3Index h3Index) {
    return h3js.cellToLatLng(h3Index.toH3JS()).toGeoCoord();
  }

  @override
  List<GeoCoord> cellToBoundary(H3Index h3Index) {
    return h3js.cellToBoundary(h3Index.toH3JS()).toGeoCoords();
  }

  @override
  H3Index cellToParent(H3Index h3Index, int resolution) {
    assert(resolution >= 0 && resolution < 16,
        'Resolution must be in [0, 15] range');
    try {
      final res = h3js.cellToParent(h3Index.toH3JS(), resolution);
      if (res == null) {
        throw H3Exception(
          H3ExceptionCode.internal,
          'Unexpected error happened, check the input',
        );
      }
      return res.toH3Index();
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
      return h3js.cellToChildren(h3Index.toH3JS(), resolution).toH3Indexes();
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
      return h3js.cellToChildrenSize(h3Index.toH3JS(), resolution).toInt();
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
      final res = h3js.cellToCenterChild(h3Index.toH3JS(), resolution);
      if (res == null) {
        return BigInt.zero;
      }
      return res.toH3Index();
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
      return h3js.cellToChildPos(h3Index.toH3JS(), parentResolution).toInt();
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
      return h3js
          .childPosToCell(childPosition, h3Index.toH3JS(), childResolution)
          .toH3Index();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  List<H3Index> gridDisk(H3Index h3Index, int ringSize) {
    try {
      return h3js.gridDisk(h3Index.toH3JS(), ringSize).toH3Indexes();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  List<List<H3Index>> gridDiskDistances(H3Index h3Index, int ringSize) {
    try {
      return [
        for (final ring
            in h3js.gridDiskDistances(h3Index.toH3JS(), ringSize).toDart)
          ring.toH3Indexes(),
      ];
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  List<H3Index> gridRing(H3Index h3Index, int ringSize) {
    try {
      return h3js.gridRing(h3Index.toH3JS(), ringSize).toH3Indexes();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  List<H3Index> gridRingUnsafe(H3Index h3Index, int ringSize) {
    try {
      return h3js.gridRingUnsafe(h3Index.toH3JS(), ringSize).toH3Indexes();
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
      return h3js
          .polygonToCells(polygonToH3JS(perimeter, holes), resolution)
          .toH3Indexes();
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
      return h3js
          .polygonToCellsExperimental(
            polygonToH3JS(perimeter, holes),
            resolution,
            flag.name,
          )
          .toH3Indexes();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  List<List<List<GeoCoord>>> cellsToMultiPolygon(List<H3Index> h3Indexes) {
    return [
      for (final polygon in h3js.cellsToMultiPolygon(h3Indexes.toH3JS()).toDart)
        [for (final loop in polygon.toDart) loop.toGeoCoords()],
    ];
  }

  @override
  List<H3Index> compactCells(List<H3Index> hexagons) {
    try {
      return h3js.compactCells(hexagons.toH3JS()).toH3Indexes();
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

      return h3js
          .uncompactCells(compactedHexagons.toH3JS(), resolution)
          .toH3Indexes();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  bool areNeighborCells(H3Index origin, H3Index destination) {
    try {
      return h3js.areNeighborCells(
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
      final res = h3js.cellsToDirectedEdge(
        origin.toH3JS(),
        destination.toH3JS(),
      );
      if (res == null) {
        return BigInt.zero;
      }
      return res.toH3Index();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  H3Index getDirectedEdgeOrigin(H3Index edgeIndex) {
    try {
      final res = h3js.getDirectedEdgeOrigin(edgeIndex.toH3JS());
      if (res == null) {
        return BigInt.zero;
      }
      return res.toH3Index();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  H3Index getDirectedEdgeDestination(H3Index edgeIndex) {
    try {
      final res = h3js.getDirectedEdgeDestination(edgeIndex.toH3JS());
      if (res == null) {
        return BigInt.zero;
      }
      return res.toH3Index();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  bool isValidDirectedEdge(H3Index edgeIndex) {
    return h3js.isValidDirectedEdge(edgeIndex.toH3JS());
  }

  @override
  H3Index reverseDirectedEdge(H3Index edgeIndex) {
    try {
      return h3js.reverseDirectedEdge(edgeIndex.toH3JS()).toH3Index();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  ({H3Index origin, H3Index destination}) directedEdgeToCells(
    H3Index edgeIndex,
  ) {
    final res = h3js.directedEdgeToCells(edgeIndex.toH3JS()).toH3Indexes();
    return (origin: res[0], destination: res[1]);
  }

  @override
  List<H3Index> originToDirectedEdges(BigInt edgeIndex) {
    return h3js.originToDirectedEdges(edgeIndex.toH3JS()).toH3Indexes();
  }

  @override
  List<GeoCoord> directedEdgeToBoundary(BigInt edgeIndex) {
    return h3js.directedEdgeToBoundary(edgeIndex.toH3JS()).toGeoCoords();
  }

  @override
  int gridDistance(H3Index origin, H3Index destination) {
    try {
      return h3js.gridDistance(origin.toH3JS(), destination.toH3JS());
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  List<H3Index> gridPathCells(H3Index origin, H3Index destination) {
    try {
      return h3js
          .gridPathCells(origin.toH3JS(), destination.toH3JS())
          .toH3Indexes();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  CoordIJ cellToLocalIj(H3Index origin, H3Index destination) {
    try {
      final res = h3js.cellToLocalIj(origin.toH3JS(), destination.toH3JS());
      return CoordIJ(i: res.i, j: res.j);
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  H3Index localIjToCell(H3Index origin, CoordIJ coordinates) {
    try {
      return h3js
          .localIjToCell(
            origin.toH3JS(),
            JSCoordIJ(i: coordinates.i, j: coordinates.j),
          )
          .toH3Index();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  double greatCircleDistance(GeoCoord a, GeoCoord b, H3Units unit) {
    return h3js.greatCircleDistance(a.toH3JS(), b.toH3JS(), unit.toH3JS());
  }

  @override
  double cellArea(BigInt h3Index, H3Units unit) {
    return h3js.cellArea(h3Index.toH3JS(), unit.toH3JSSquare());
  }

  @override
  double edgeLength(H3Index edgeIndex, H3Units unit) {
    return h3js.edgeLength(edgeIndex.toH3JS(), unit.toH3JS());
  }

  @override
  double getHexagonAreaAvg(int resolution, H3MetricUnits unit) {
    assert(
      resolution >= 0 && resolution < 16,
      'Resolution must be in [0, 15] range',
    );
    return h3js.getHexagonAreaAvg(resolution, unit.toH3JSSquare());
  }

  @override
  double getHexagonEdgeLengthAvg(int res, H3MetricUnits unit) {
    assert(res >= 0 && res < 16, 'Resolution must be in [0, 15] range');
    return h3js.getHexagonEdgeLengthAvg(res, unit.toH3JS());
  }

  @override
  H3Index cellToVertex(H3Index h3Index, int vertexNum) {
    assert(vertexNum >= 0);
    try {
      return h3js.cellToVertex(h3Index.toH3JS(), vertexNum).toH3Index();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  List<H3Index> cellToVertexes(H3Index h3Index) {
    return h3js.cellToVertexes(h3Index.toH3JS()).toH3Indexes();
  }

  @override
  GeoCoord vertexToGeo(H3Index h3Index) {
    try {
      return h3js.vertexToLatLng(h3Index.toH3JS()).toGeoCoord();
    } catch (e) {
      wrapAndThrowJsException(e);
      rethrow;
    }
  }

  @override
  bool isValidVertex(H3Index h3Index) {
    return h3js.isValidVertex(h3Index.toH3JS());
  }

  @override
  BigInt getNumCells(int resolution) {
    assert(
      resolution >= 0 && resolution < 16,
      'Resolution must be in [0, 15] range',
    );
    return BigInt.from(h3js.getNumCells(resolution));
  }

  @override
  List<H3Index> getRes0Cells() {
    return h3js.getRes0Cells().toH3Indexes();
  }

  @override
  List<H3Index> getPentagons(int resolution) {
    assert(
      resolution >= 0 && resolution < 16,
      'Resolution must be in [0, 15] range',
    );
    return h3js.getPentagons(resolution).toH3Indexes();
  }

  @override
  double degsToRads(double val) => h3js.degsToRads(val);

  @override
  double radsToDegs(double val) => h3js.radsToDegs(val);
}
