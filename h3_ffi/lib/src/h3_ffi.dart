import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:h3_common/h3_common.dart';
import 'package:h3_ffi/src/mappers/errors.dart';

import 'generated/generated_bindings.dart' as c;
import 'mappers/mappers.dart';

/// Provides access to H3 functions through FFI.
///
/// You should not construct the class directly, use [H3Factory] instead.
class H3Ffi implements H3 {
  H3Ffi(this._h3c);

  final c.H3C _h3c;

  late final GeoCoordConverter _geoCoordConverter =
      GeoCoordConverter(H3AngleConverter(this));

  @override
  bool isValidCell(H3Index h3Index) {
    return _h3c.isValidCell(h3Index.toNative()) == 1;
  }

  @override
  bool isPentagon(H3Index h3Index) {
    return _h3c.isPentagon(h3Index.toNative()) == 1;
  }

  @override
  bool isResClassIII(H3Index h3Index) {
    return _h3c.isResClassIII(h3Index.toNative()) == 1;
  }

  @override
  int getBaseCellNumber(H3Index h3Index) {
    return _h3c.getBaseCellNumber(h3Index.toNative());
  }

  @override
  List<int> getIcosahedronFaces(H3Index h3Index) {
    final h3IndexInt = h3Index.toNative();
    return using((arena) {
      final count = arena<Int>();
      throwIfError(_h3c.maxFaceCount(h3IndexInt, count));
      final out = arena<Int>();
      _h3c.getIcosahedronFaces(h3IndexInt, out);
      return out
          .cast<Int32>()
          .asTypedList(count.value)
          .where((e) => e != -1)
          .toList();
    });
  }

  @override
  int getResolution(H3Index h3Index) {
    if (!isValidCell(h3Index)) {
      throw H3Exception(
        H3ExceptionCode.internal,
        'H3Index is not valid.',
      );
    }
    return _h3c.getResolution(h3Index.toNative());
  }

  @override
  H3Index geoToCell(GeoCoord geoCoord, int res) {
    assert(res >= 0 && res < 16, 'Resolution must be in [0, 15] range');
    return using((arena) {
      final out = arena<Uint64>();
      throwIfError(
        _h3c.latLngToCell(
          geoCoord.toRadians(_geoCoordConverter).toNative(arena),
          res,
          out,
        ),
      );
      return out.toH3Index();
    });
  }

  @override
  GeoCoord cellToGeo(H3Index h3Index) {
    return using((arena) {
      final out = arena<c.LatLng>();
      throwIfError(_h3c.cellToLatLng(h3Index.toNative(), out));
      return out.ref.toDart().toDegrees(_geoCoordConverter);
    });
  }

  @override
  List<GeoCoord> cellToBoundary(H3Index h3Index) {
    return using((arena) {
      final geoBoundary = arena<c.CellBoundary>();
      throwIfError(_h3c.cellToBoundary(h3Index.toNative(), geoBoundary));
      final res = <GeoCoord>[];
      for (var i = 0; i < geoBoundary.ref.numVerts; i++) {
        final vert = geoBoundary.ref.verts[i];
        res.add(
          GeoCoord(
            lon: radsToDegs(vert.lng),
            lat: radsToDegs(vert.lat),
          ),
        );
      }
      return res;
    });
  }

  @override
  H3Index cellToParent(H3Index h3Index, int resolution) {
    assert(resolution >= 0 && resolution < 16,
        'Resolution must be in [0, 15] range');

    return using((arena) {
      final out = arena<Uint64>();
      throwIfError(_h3c.cellToParent(h3Index.toNative(), resolution, out));
      return out.toH3Index();
    });
  }

  @override
  List<H3Index> cellToChildren(H3Index h3Index, int resolution) {
    // Bad input in this case can potentially result in high computation volume
    // using the current C algorithm. Validate and return an empty array on failure.
    if (!isValidCell(h3Index)) {
      return [];
    }
    final h3IndexInt = h3Index.toNative();
    return using((arena) {
      final maxSize = arena<Int64>();
      throwIfError(_h3c.cellToChildrenSize(h3IndexInt, resolution, maxSize));
      final out = arena<Uint64>(maxSize.value);
      throwIfError(_h3c.cellToChildren(h3IndexInt, resolution, out));
      return out.asTypedList(maxSize.value).toH3IndexList();
    });
  }

  @override
  int cellToChildrenSize(H3Index h3Index, int resolution) {
    if (!isValidCell(h3Index)) {
      throw H3Exception.fromCode(H3ExceptionCode.cellInvalid);
    }

    final h3IndexInt = h3Index.toNative();
    return using((arena) {
      final maxSize = arena<Int64>();
      throwIfError(_h3c.cellToChildrenSize(h3IndexInt, resolution, maxSize));
      return maxSize.value;
    });
  }

  @override
  H3Index cellToCenterChild(H3Index h3Index, int resolution) {
    assert(resolution >= 0 && resolution < 16,
        'Resolution must be in [0, 15] range');
    return using((arena) {
      final maxSize = arena<Uint64>();
      throwIfError(
        _h3c.cellToCenterChild(h3Index.toNative(), resolution, maxSize),
      );
      return maxSize.toH3Index();
    });
  }

  @override
  int cellToChildPos(
    H3Index h3Index,
    int parentResolution,
  ) {
    assert(parentResolution >= 0 && parentResolution < 16,
        'Resolution must be in [0, 15] range');
    return using((arena) {
      final out = arena<Int64>();
      throwIfError(
        _h3c.cellToChildPos(h3Index.toNative(), parentResolution, out),
      );
      return out.value;
    });
  }

  @override
  H3Index childPosToCell(
    int childPosition,
    H3Index h3Index,
    int childResolution,
  ) {
    assert(childResolution >= 0 && childResolution < 16,
        'Resolution must be in [0, 15] range');
    return using((arena) {
      final out = arena<Uint64>();
      throwIfError(
        _h3c.childPosToCell(
          h3Index.toNative(),
          h3Index.toNative(),
          childResolution,
          out,
        ),
      );
      return out.toH3Index();
    });
  }

  @override
  List<H3Index> gridDisk(H3Index h3Index, int ringSize) {
    return using((arena) {
      final maxGridDiskSize = arena<Int64>();
      throwIfError(_h3c.maxGridDiskSize(ringSize, maxGridDiskSize));
      final out = arena<Uint64>(maxGridDiskSize.value);
      throwIfError(_h3c.gridDisk(h3Index.toNative(), ringSize, out));
      return out.asTypedList(maxGridDiskSize.value).toH3IndexList();
    });
  }

  @override
  List<List<H3Index>> gridDiskDistances(H3Index h3Index, int ringSize) {
    return using((arena) {
      final count = arena<Int64>();
      throwIfError(_h3c.maxGridDiskSize(ringSize, count));
      final kRings = arena<Uint64>(count.value);
      final distances = arena<Int>(count.value);
      throwIfError(
        _h3c.gridDiskDistances(
          h3Index.toNative(),
          ringSize,
          kRings,
          distances,
        ),
      );

      final out = List.generate(ringSize + 1, (_) => <H3Index>[]);
      for (var i = 0; i < count.value; i++) {
        final cell = (kRings + i).toH3Index();
        final index = (distances + i).value;
        if (cell != BigInt.zero) {
          out[index].add(cell);
        }
      }
      return out;
    });
  }

  @override
  List<H3Index> gridRingUnsafe(H3Index h3Index, int ringSize) {
    final maxCount = ringSize == 0 ? 1 : 6 * ringSize;
    return using((arena) {
      final out = arena<Uint64>(maxCount);
      throwIfError(_h3c.gridRingUnsafe(h3Index.toNative(), ringSize, out));
      return out.asTypedList(maxCount).toH3IndexList();
    });
  }

  @override
  List<H3Index> polygonToCells({
    required List<GeoCoord> perimeter,
    required int resolution,
    List<List<GeoCoord>> holes = const [],
  }) {
    assert(resolution >= 0 && resolution < 16,
        'Resolution must be in [0, 15] range');

    if (perimeter.isEmpty) {
      return [];
    }

    return using((arena) {
      final polygonPointer = arena<c.GeoPolygon>();
      polygonPointer.ref.assign(
        perimeter: perimeter,
        converter: _geoCoordConverter,
        allocator: arena,
      );

      final count = arena<Int64>();
      throwIfError(
        _h3c.maxPolygonToCellsSize(polygonPointer, resolution, 0, count),
      );

      final out = arena<Uint64>(count.value);
      throwIfError(_h3c.polygonToCells(polygonPointer, resolution, 0, out));

      return out.asTypedList(count.value).toH3IndexList();
    });
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

    if (perimeter.isEmpty) {
      return [];
    }

    return using((arena) {
      final polygonPointer = arena<c.GeoPolygon>();
      polygonPointer.ref.assign(
        perimeter: perimeter,
        converter: _geoCoordConverter,
        allocator: arena,
      );

      final count = arena<Int64>();
      throwIfError(
        _h3c.maxPolygonToCellsSizeExperimental(
          polygonPointer,
          resolution,
          0,
          count,
        ),
      );

      final out = arena<Uint64>(count.value);
      throwIfError(
        _h3c.polygonToCellsExperimental(
          polygonPointer,
          resolution,
          flag.index,
          count.value,
          out,
        ),
      );

      return out.asTypedList(count.value).toH3IndexList();
    });
  }

  @override
  List<List<List<GeoCoord>>> cellsToMultiPolygon(List<H3Index> h3Indexes) {
    return using((arena) {
      final h3IndexesPointer = arena<Uint64>(h3Indexes.length);
      for (var i = 0; i < h3Indexes.length; i++) {
        final h3IndexPointer = h3IndexesPointer + i;
        h3IndexPointer.value = h3Indexes[i].toNative();
      }

      final out = arena<c.LinkedGeoPolygon>();
      throwIfError(
        _h3c.cellsToLinkedMultiPolygon(
          h3IndexesPointer,
          h3Indexes.length,
          out,
        ),
      );

      final res = out.ref.toDart(converter: _geoCoordConverter);
      _h3c.destroyLinkedMultiPolygon(out);
      return res;
    });
  }

  @override
  List<H3Index> compactCells(List<H3Index> hexagons) {
    if (hexagons.isEmpty) {
      return [];
    }

    return using((arena) {
      final hexagonsPointer = arena<Uint64>(hexagons.length);
      for (var i = 0; i < hexagons.length; i++) {
        final pointer = hexagonsPointer + i;
        pointer.value = hexagons[i].toNative();
      }

      final out = arena<Uint64>(hexagons.length);
      throwIfError(_h3c.compactCells(hexagonsPointer, out, hexagons.length));
      return out.asTypedList(hexagons.length).toH3IndexList();
    });
  }

  @override
  List<H3Index> uncompactCells(
    List<H3Index> compactedHexagons, {
    required int resolution,
  }) {
    assert(resolution >= 0 && resolution < 16,
        'Resolution must be in [0, 15] range');

    return using((arena) {
      final compactedHexagonsPointer = arena<Uint64>(compactedHexagons.length);
      for (var i = 0; i < compactedHexagons.length; i++) {
        final pointer = compactedHexagonsPointer + i;
        pointer.value = compactedHexagons[i].toNative();
      }

      final maxUncompactSize = arena<Int64>();
      throwIfError(
        _h3c.uncompactCellsSize(
          compactedHexagonsPointer,
          compactedHexagons.length,
          resolution,
          maxUncompactSize,
        ),
      );

      final out = arena<Uint64>(maxUncompactSize.value);
      throwIfError(
        _h3c.uncompactCells(
          compactedHexagonsPointer,
          compactedHexagons.length,
          out,
          maxUncompactSize.value,
          resolution,
        ),
      );

      return out.asTypedList(maxUncompactSize.value).toH3IndexList();
    });
  }

  @override
  bool areNeighborCells(H3Index origin, H3Index destination) {
    return using((arena) {
      final out = arena<Int>();
      throwIfError(
        _h3c.areNeighborCells(
          origin.toNative(),
          destination.toNative(),
          out,
        ),
      );
      return out.value == 1;
    });
  }

  @override
  H3Index cellsToDirectedEdge(H3Index origin, H3Index destination) {
    return using((arena) {
      final out = arena<Uint64>();
      throwIfError(
        _h3c.cellsToDirectedEdge(
          origin.toNative(),
          destination.toNative(),
          out,
        ),
      );
      return out.toH3Index();
    });
  }

  @override
  H3Index getDirectedEdgeOrigin(H3Index edgeIndex) {
    return using((arena) {
      final out = arena<Uint64>();
      throwIfError(
        _h3c.getDirectedEdgeOrigin(
          edgeIndex.toNative(),
          out,
        ),
      );
      return out.toH3Index();
    });
  }

  @override
  H3Index getDirectedEdgeDestination(H3Index edgeIndex) {
    return using((arena) {
      final out = arena<Uint64>();
      throwIfError(
        _h3c.getDirectedEdgeDestination(
          edgeIndex.toNative(),
          out,
        ),
      );
      return out.toH3Index();
    });
  }

  @override
  bool isValidDirectedEdge(H3Index edgeIndex) {
    return _h3c.isValidDirectedEdge(edgeIndex.toNative()) == 1;
  }

  @override
  ({H3Index origin, H3Index destination}) directedEdgeToCells(
    H3Index edgeIndex,
  ) {
    return using((arena) {
      final out = arena<Uint64>(2);
      throwIfError(
        _h3c.directedEdgeToCells(
          edgeIndex.toNative(),
          out,
        ),
      );
      return (
        origin: out.toH3Index(),
        destination: (out + 1).toH3Index(),
      );
    });
  }

  @override
  List<H3Index> originToDirectedEdges(H3Index edgeIndex) {
    return using((arena) {
      final out = arena<Uint64>(6);
      throwIfError(
        _h3c.originToDirectedEdges(
          edgeIndex.toNative(),
          out,
        ),
      );
      return out.asTypedList(6).toH3IndexList();
    });
  }

  @override
  List<GeoCoord> directedEdgeToBoundary(H3Index edgeIndex) {
    return using((arena) {
      final out = arena<c.CellBoundary>();
      throwIfError(
        _h3c.directedEdgeToBoundary(
          edgeIndex.toNative(),
          out,
        ),
      );
      final coordinates = <GeoCoord>[];
      for (var i = 0; i < out.ref.numVerts; i++) {
        coordinates.add(
          out.ref.verts[i].toDart().toDegrees(_geoCoordConverter),
        );
      }
      return coordinates;
    });
  }

  @override
  int gridDistance(H3Index origin, H3Index destination) {
    return using((arena) {
      final out = arena<Int64>();
      throwIfError(
        _h3c.gridDistance(
          origin.toNative(),
          destination.toNative(),
          out,
        ),
      );
      return out.value;
    });
  }

  @override
  List<H3Index> gridPathCells(H3Index origin, H3Index destination) {
    final originInt = origin.toNative();
    final destinationInt = destination.toNative();
    return using((arena) {
      final size = arena<Int64>();
      throwIfError(
        _h3c.gridPathCellsSize(
          originInt,
          destinationInt,
          size,
        ),
      );
      final out = arena<Uint64>(size.value);
      throwIfError(_h3c.gridPathCells(originInt, destinationInt, out));
      return out.asTypedList(size.value).toH3IndexList();
    });
  }

  @override
  CoordIJ cellToLocalIj(H3Index origin, H3Index destination) {
    return using((arena) {
      final out = arena<c.CoordIJ>();
      throwIfError(
        _h3c.cellToLocalIj(
          origin.toNative(),
          destination.toNative(),
          0,
          out,
        ),
      );
      return out.ref.toDart();
    });
  }

  @override
  H3Index localIjToCell(H3Index origin, CoordIJ coordinates) {
    return using((arena) {
      final out = arena<Uint64>();
      throwIfError(
        _h3c.localIjToCell(
          origin.toNative(),
          coordinates.toNative(arena),
          0,
          out,
        ),
      );
      return out.toH3Index();
    });
  }

  @override
  double greatCircleDistance(GeoCoord a, GeoCoord b, H3Units unit) {
    return using((arena) {
      switch (unit) {
        case H3Units.m:
          return _h3c.greatCircleDistanceM(
            a.toRadians(_geoCoordConverter).toNative(arena),
            b.toRadians(_geoCoordConverter).toNative(arena),
          );
        case H3Units.km:
          return _h3c.greatCircleDistanceKm(
            a.toRadians(_geoCoordConverter).toNative(arena),
            b.toRadians(_geoCoordConverter).toNative(arena),
          );
        case H3Units.rad:
          return _h3c.greatCircleDistanceRads(
            a.toRadians(_geoCoordConverter).toNative(arena),
            b.toRadians(_geoCoordConverter).toNative(arena),
          );
      }
    });
  }

  @override
  double cellArea(H3Index h3Index, H3Units unit) {
    return using((arena) {
      final out = arena<Double>();

      throwIfError(switch (unit) {
        H3Units.m => _h3c.cellAreaM2(h3Index.toNative(), out),
        H3Units.km => _h3c.cellAreaKm2(h3Index.toNative(), out),
        H3Units.rad => _h3c.cellAreaRads2(h3Index.toNative(), out),
      });

      return out.value;
    });
  }

  @override
  double edgeLength(H3Index edgeIndex, H3Units unit) {
    return using((arena) {
      final out = arena<Double>();

      throwIfError(switch (unit) {
        H3Units.m => _h3c.edgeLengthM(edgeIndex.toNative(), out),
        H3Units.km => _h3c.edgeLengthKm(edgeIndex.toNative(), out),
        H3Units.rad => _h3c.edgeLengthRads(edgeIndex.toNative(), out),
      });

      return out.value;
    });
  }

  @override
  double getHexagonAreaAvg(int resolution, H3MetricUnits unit) {
    assert(
      resolution >= 0 && resolution < 16,
      'Resolution must be in [0, 15] range',
    );
    return using((arena) {
      final out = arena<Double>();

      throwIfError(switch (unit) {
        H3MetricUnits.m => _h3c.getHexagonAreaAvgM2(resolution, out),
        H3MetricUnits.km => _h3c.getHexagonAreaAvgKm2(resolution, out),
      });

      return out.value;
    });
  }

  @override
  double getHexagonEdgeLengthAvg(int resolution, H3MetricUnits unit) {
    assert(
      resolution >= 0 && resolution < 16,
      'Resolution must be in [0, 15] range',
    );
    return using((arena) {
      final out = arena<Double>();

      throwIfError(switch (unit) {
        H3MetricUnits.m => _h3c.getHexagonEdgeLengthAvgM(resolution, out),
        H3MetricUnits.km => _h3c.getHexagonEdgeLengthAvgKm(resolution, out),
      });

      return out.value;
    });
  }

  @override
  H3Index cellToVertex(H3Index h3Index, int vertexNum) {
    assert(vertexNum >= 0);

    return using((arena) {
      final out = arena<Uint64>();
      throwIfError(_h3c.cellToVertex(h3Index.toNative(), vertexNum, out));
      return out.toH3Index();
    });
  }

  @override
  List<H3Index> cellToVertexes(H3Index h3Index) {
    return using((arena) {
      final out = arena<Uint64>(6);
      throwIfError(_h3c.cellToVertexes(h3Index.toNative(), out));
      return out.asTypedList(6).toH3IndexList();
    });
  }

  @override
  GeoCoord vertexToGeo(H3Index h3Index) {
    return using((arena) {
      final out = arena<c.LatLng>();
      throwIfError(_h3c.vertexToLatLng(h3Index.toNative(), out));
      return out.ref.toDart().toDegrees(_geoCoordConverter);
    });
  }

  @override
  bool isValidVertex(H3Index h3Index) {
    return _h3c.isValidVertex(h3Index.toNative()) == 1;
  }

  @override
  BigInt getNumCells(int resolution) {
    assert(
      resolution >= 0 && resolution < 16,
      'Resolution must be in [0, 15] range',
    );
    return using((arena) {
      final out = arena<Int64>();
      throwIfError(_h3c.getNumCells(resolution, out));
      return BigInt.from(out.value);
    });
  }

  @override
  List<H3Index> getRes0Cells() {
    return using((arena) {
      final count = _h3c.res0CellCount();
      final out = arena<Uint64>(count);
      throwIfError(_h3c.getRes0Cells(out));
      return out.asTypedList(count).toH3IndexList();
    });
  }

  @override
  List<H3Index> getPentagons(int resolution) {
    assert(
      resolution >= 0 && resolution < 16,
      'Resolution must be in [0, 15] range',
    );
    return using((arena) {
      final size = _h3c.pentagonCount();
      final out = arena<Uint64>(size);
      throwIfError(_h3c.getPentagons(resolution, out));
      return out.asTypedList(size).toH3IndexList();
    });
  }

  @override
  double radsToDegs(double val) => _h3c.radsToDegs(val);

  @override
  double degsToRads(double val) => _h3c.degsToRads(val);
}
