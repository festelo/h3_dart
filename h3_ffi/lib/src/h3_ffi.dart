import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:h3_common/h3_common.dart';
import 'package:h3_ffi/src/mappers/big_int.dart';

import 'generated/generated_bindings.dart' as c;
import 'mappers/native.dart';

/// Provides access to H3 functions through FFI.
///
/// You should not construct the class directly, use [H3Factory] instead.
class H3Ffi implements H3 {
  H3Ffi(this._h3c);

  final c.H3C _h3c;

  late final GeoCoordConverter _geoCoordConverter =
      GeoCoordConverter(H3AngleConverter(this));

  /// Determines if [h3Index] is a valid cell (hexagon or pentagon)
  @override
  bool h3IsValid(BigInt h3Index) {
    return _h3c.h3IsValid(h3Index.toInt()) == 1;
  }

  /// Determines if [h3Index] is a valid pentagon
  @override
  bool h3IsPentagon(BigInt h3Index) {
    return _h3c.h3IsPentagon(h3Index.toInt()) == 1;
  }

  /// Determines if [h3Index] is Class III (rotated versus
  /// the icosahedron and subject to shape distortion adding extra points on
  /// icosahedron edges, making them not true hexagons).
  @override
  bool h3IsResClassIII(BigInt h3Index) {
    return _h3c.h3IsResClassIII(h3Index.toInt()) == 1;
  }

  /// Returns the base cell "number" (0 to 121) of the provided H3 cell
  ///
  /// Note: Technically works on H3 edges, but will return base cell of the
  /// origin cell.
  @override
  int h3GetBaseCell(BigInt h3Index) {
    return _h3c.h3GetBaseCell(h3Index.toInt());
  }

  /// Find all icosahedron faces intersected by a given H3 index
  @override
  List<int> h3GetFaces(BigInt h3Index) {
    final h3IndexInt = h3Index.toInt();
    return using((arena) {
      final size = _h3c.maxFaceCount(h3IndexInt);
      final out = arena<Int32>(size);
      _h3c.h3GetFaces(h3IndexInt, out);
      return out.asTypedList(size).where((e) => e != -1).toList();
    });
  }

  /// Returns the resolution of the provided H3 index
  ///
  /// Works on both cells and unidirectional edges.
  @override
  int h3GetResolution(BigInt h3Index) {
    if (!h3IsValid(h3Index)) {
      throw H3Exception('H3Index is not valid.');
    }
    return _h3c.h3GetResolution(h3Index.toInt());
  }

  /// Find the H3 index of the resolution res cell containing the lat/lng
  @override
  BigInt geoToH3(GeoCoord geoCoord, int res) {
    assert(res >= 0 && res < 16, 'Resolution must be in [0, 15] range');
    return using((arena) {
      return _h3c
          .geoToH3(
            geoCoord.toRadians(_geoCoordConverter).toNative(arena),
            res,
          )
          .toBigInt();
    });
  }

  /// Find the lat/lon center point g of the cell h3
  @override
  GeoCoord h3ToGeo(BigInt h3Index) {
    return using((arena) {
      final geoCoordNative = arena<c.GeoCoord>();

      _h3c.h3ToGeo(h3Index.toInt(), geoCoordNative);
      return geoCoordNative.ref.toPure().toDegrees(_geoCoordConverter);
    });
  }

  /// Gives the cell boundary in lat/lon coordinates for the cell with index [h3Index]
  ///
  /// ```dart
  /// h3.h3ToGeoBoundary(0x85283473fffffff)
  /// h3.h3ToGeoBoundary(133)
  /// ```
  @override
  List<GeoCoord> h3ToGeoBoundary(BigInt h3Index) {
    return using((arena) {
      final geoBoundary = arena<c.GeoBoundary>();
      _h3c.h3ToGeoBoundary(h3Index.toInt(), geoBoundary);
      final res = <GeoCoord>[];
      for (var i = 0; i < geoBoundary.ref.numVerts; i++) {
        final vert = geoBoundary.ref.verts[i];
        res.add(GeoCoord(lon: radsToDegs(vert.lon), lat: radsToDegs(vert.lat)));
      }
      return res;
    });
  }

  /// Get the parent of the given [h3Index] hexagon at a particular [resolution]
  ///
  /// Returns 0 when result can't be calculated
  @override
  BigInt h3ToParent(BigInt h3Index, int resolution) {
    return _h3c.h3ToParent(h3Index.toInt(), resolution).toBigInt();
  }

  /// Get the children/descendents of the given [h3Index] hexagon at a particular [resolution]
  @override
  List<BigInt> h3ToChildren(BigInt h3Index, int resolution) {
    // Bad input in this case can potentially result in high computation volume
    // using the current C algorithm. Validate and return an empty array on failure.
    if (!h3IsValid(h3Index)) {
      return [];
    }
    final h3IndexInt = h3Index.toInt();
    final maxSize = _h3c.maxH3ToChildrenSize(h3IndexInt, resolution);
    return using((arena) {
      final out = arena<Uint64>(maxSize);
      _h3c.h3ToChildren(h3IndexInt, resolution, out);
      final list = out.asTypedList(maxSize).toList();
      return list.where((e) => e != 0).map((e) => e.toBigInt()).toList();
    });
  }

  /// Get the center child of the given [h3Index] hexagon at a particular [resolution]
  ///
  /// Returns 0 when result can't be calculated
  @override
  BigInt h3ToCenterChild(BigInt h3Index, int resolution) {
    return _h3c.h3ToCenterChild(h3Index.toInt(), resolution).toBigInt();
  }

  /// Maximum number of hexagons in k-ring
  @override
  List<BigInt> kRing(BigInt h3Index, int ringSize) {
    return using((arena) {
      final kIndex = _h3c.maxKringSize(ringSize);
      final out = arena<Uint64>(kIndex);
      _h3c.kRing(h3Index.toInt(), ringSize, out);
      final list = out.asTypedList(kIndex).toList();
      return list.where((e) => e != 0).map((e) => e.toBigInt()).toList();
    });
  }

  /// Hollow hexagon ring at some origin
  @override
  List<BigInt> hexRing(BigInt h3Index, int ringSize) {
    return using((arena) {
      final kIndex = ringSize == 0 ? 1 : 6 * ringSize;
      final out = arena<Uint64>(kIndex);
      final resultCode = _h3c.hexRing(h3Index.toInt(), ringSize, out);
      if (resultCode != 0) {
        throw H3Exception('Failed to get hexRing (encountered a pentagon?)');
      }
      final list = out.asTypedList(kIndex).toList();
      return list.where((e) => e != 0).map((e) => e.toBigInt()).toList();
    });
  }

  /// Takes a given [coordinates] and [resolution] and returns hexagons that
  /// are contained by them.
  ///
  /// [resolution] must be in the range [0, 15].
  ///
  /// This implementation traces the GeoJSON geofence(s) in cartesian space with
  /// hexagons, tests them and their neighbors to be contained by the geofence(s),
  /// and then any newly found hexagons are used to test again until no new
  /// hexagons are found.
  ///
  /// ```dart
  /// final hexagons = h3.polyfill(
  ///   coordinates: const [
  ///     GeoCoord(lat: 37.813318999983238, lon: -122.4089866999972145),
  ///     GeoCoord(lat: 37.7866302000007224, lon: -122.3805436999997056),
  ///     GeoCoord(lat: 37.7198061999978478, lon: -122.3544736999993603),
  ///     GeoCoord(lat: 37.7076131999975672, lon: -122.5123436999983966),
  ///     GeoCoord(lat: 37.7835871999971715, lon: -122.5247187000021967),
  ///     GeoCoord(lat: 37.8151571999998453, lon: -122.4798767000009008),
  ///   ],
  ///   resolution: 9,
  /// )
  /// ```
  @override
  List<BigInt> polyfill({
    required List<GeoCoord> coordinates,
    List<List<GeoCoord>> holes = const [],
    required int resolution,
  }) {
    assert(resolution >= 0 && resolution < 16,
        'Resolution must be in [0, 15] range');
    return using((arena) {
      //polygon outer boundary
      final nativeCoordinatesPointer = arena<c.GeoCoord>(coordinates.length);
      for (var i = 0; i < coordinates.length; i++) {
        final pointer = Pointer<c.GeoCoord>.fromAddress(
            nativeCoordinatesPointer.address + sizeOf<c.GeoCoord>() * i);
        coordinates[i]
            .toRadians(_geoCoordConverter)
            .assignToNative(pointer.ref);
      }

      final polygon = arena<c.GeoPolygon>();
      final outergeofence = arena<c.Geofence>();

      //outer boundary
      polygon.ref.geofence = outergeofence.ref;
      polygon.ref.geofence.verts = nativeCoordinatesPointer;
      polygon.ref.geofence.numVerts = coordinates.length;

      //polygon holes
      if (holes.isNotEmpty) {
        final holesgeofencePointer = arena<c.Geofence>(holes.length);
        for (var h = 0; h < holes.length; h++) {
          final holeCoords = holes[h];
          final singleHoleGFencePointer = Pointer<c.Geofence>.fromAddress(
              holesgeofencePointer.address + sizeOf<c.Geofence>() * h);

          final holeNativeCoordinatesPointer =
              arena<c.GeoCoord>(holeCoords.length);
          //assign the hole coord to holeptr
          for (var i = 0; i < holeCoords.length; i++) {
            final coordPointer = Pointer<c.GeoCoord>.fromAddress(
                holeNativeCoordinatesPointer.address +
                    sizeOf<c.GeoCoord>() * i);
            holeCoords[i]
                .toRadians(_geoCoordConverter)
                .assignToNative(coordPointer.ref);
          }

          singleHoleGFencePointer.ref.numVerts = holeCoords.length;
          singleHoleGFencePointer.ref.verts = holeNativeCoordinatesPointer;
        }

        polygon.ref.numHoles = holes.length;
        polygon.ref.holes = holesgeofencePointer;
      } else {
        polygon.ref.numHoles = 0;
        polygon.ref.holes = Pointer.fromAddress(0);
      }

      final nbIndex = _h3c.maxPolyfillSize(polygon, resolution);

      final out = arena<Uint64>(nbIndex);
      _h3c.polyfill(polygon, resolution, out);
      final list = out.asTypedList(nbIndex).toList();
      return list.where((e) => e != 0).map((e) => e.toBigInt()).toList();
    });
  }

  /// Compact a set of hexagons of the same resolution into a set of hexagons
  /// across multiple levels that represents the same area.
  @override
  List<BigInt> compact(List<BigInt> hexagons) {
    return using((arena) {
      hexagons = hexagons.toSet().toList(); // remove duplicates
      final hexagonsPointer = arena<Uint64>(hexagons.length);
      for (var i = 0; i < hexagons.length; i++) {
        final pointer = Pointer<Uint64>.fromAddress(
          hexagonsPointer.address + sizeOf<Uint64>() * i,
        );
        pointer.value = hexagons[i].toInt();
      }

      final out = arena<Uint64>(hexagons.length);
      final resultCode = _h3c.compact(hexagonsPointer, out, hexagons.length);
      if (resultCode != 0) {
        throw H3Exception(
          'Failed to compact, malformed input data',
        );
      }
      final list = out.asTypedList(hexagons.length).toList();
      return list.where((e) => e != 0).map((e) => e.toBigInt()).toList();
    });
  }

  /// Uncompact a compacted set of hexagons to hexagons of the same resolution
  @override
  List<BigInt> uncompact(
    List<BigInt> compactedHexagons, {
    required int resolution,
  }) {
    assert(resolution >= 0 && resolution < 16,
        'Resolution must be in [0, 15] range');

    return using((arena) {
      final compactedHexagonsPointer = arena<Uint64>(compactedHexagons.length);
      for (var i = 0; i < compactedHexagons.length; i++) {
        final pointer = Pointer<Uint64>.fromAddress(
          compactedHexagonsPointer.address + sizeOf<Uint64>() * i,
        );
        pointer.value = compactedHexagons[i].toInt();
      }

      final maxUncompactSize = _h3c.maxUncompactSize(
        compactedHexagonsPointer,
        compactedHexagons.length,
        resolution,
      );

      if (maxUncompactSize < 0) {
        throw H3Exception('Failed to uncompact');
      }

      final out = arena<Uint64>(maxUncompactSize);
      final resultCode = _h3c.uncompact(
        compactedHexagonsPointer,
        compactedHexagons.length,
        out,
        maxUncompactSize,
        resolution,
      );
      if (resultCode != 0) {
        throw H3Exception('Failed to uncompact');
      }

      final list = out.asTypedList(maxUncompactSize).toList();
      return list.where((e) => e != 0).map((e) => e.toBigInt()).toList();
    });
  }

  /// Returns whether or not two H3 indexes are neighbors (share an edge)
  @override
  bool h3IndexesAreNeighbors(BigInt origin, BigInt destination) {
    return _h3c.h3IndexesAreNeighbors(origin.toInt(), destination.toInt()) == 1;
  }

  /// Get an H3 index representing a unidirectional edge for a given origin and
  /// destination
  ///
  /// Returns 0 when result can't be calculated
  @override
  BigInt getH3UnidirectionalEdge(BigInt origin, BigInt destination) {
    return _h3c
        .getH3UnidirectionalEdge(origin.toInt(), destination.toInt())
        .toBigInt();
  }

  /// Get the origin hexagon from an H3 index representing a unidirectional edge
  ///
  /// Returns 0 when result can't be calculated
  @override
  BigInt getOriginH3IndexFromUnidirectionalEdge(BigInt edgeIndex) {
    return _h3c
        .getOriginH3IndexFromUnidirectionalEdge(edgeIndex.toInt())
        .toBigInt();
  }

  /// Get the destination hexagon from an H3 index representing a unidirectional edge
  ///
  /// Returns 0 when result can't be calculated
  @override
  BigInt getDestinationH3IndexFromUnidirectionalEdge(BigInt edgeIndex) {
    return _h3c
        .getDestinationH3IndexFromUnidirectionalEdge(edgeIndex.toInt())
        .toBigInt();
  }

  /// Returns whether or not the input is a valid unidirectional edge
  @override
  bool h3UnidirectionalEdgeIsValid(BigInt edgeIndex) {
    return _h3c.h3UnidirectionalEdgeIsValid(edgeIndex.toInt()) == 1;
  }

  /// Get the [origin, destination] pair represented by a unidirectional edge
  @override
  List<BigInt> getH3IndexesFromUnidirectionalEdge(BigInt edgeIndex) {
    return using((arena) {
      final out = arena<Uint64>(2);
      _h3c.getH3IndexesFromUnidirectionalEdge(edgeIndex.toInt(), out);
      return out.asTypedList(2).map((e) => e.toBigInt()).toList();
    });
  }

  /// Get all of the unidirectional edges with the given H3 index as the origin
  /// (i.e. an edge to every neighbor)
  @override
  List<BigInt> getH3UnidirectionalEdgesFromHexagon(BigInt edgeIndex) {
    return using((arena) {
      final out = arena<Uint64>(6);
      _h3c.getH3UnidirectionalEdgesFromHexagon(edgeIndex.toInt(), out);
      return out
          .asTypedList(6)
          .toList()
          .where((i) => i != 0)
          .map((e) => e.toBigInt())
          .toList();
    });
  }

  /// Get the vertices of a given edge as an array of [lat, lng] points. Note
  /// that for edges that cross the edge of an icosahedron face, this may return
  /// 3 coordinates.
  @override
  List<GeoCoord> getH3UnidirectionalEdgeBoundary(BigInt edgeIndex) {
    return using((arena) {
      final out = arena<c.GeoBoundary>();
      _h3c.getH3UnidirectionalEdgeBoundary(edgeIndex.toInt(), out);
      final coordinates = <GeoCoord>[];
      for (var i = 0; i < out.ref.numVerts; i++) {
        coordinates
            .add(out.ref.verts[i].toPure().toDegrees(_geoCoordConverter));
      }
      return coordinates;
    });
  }

  /// Get the grid distance between two hex indexes. This function may fail
  /// to find the distance between two indexes if they are very far apart or
  /// on opposite sides of a pentagon.
  ///
  /// Returns -1 when result can't be calculated
  @override
  int h3Distance(BigInt origin, BigInt destination) {
    return _h3c.h3Distance(origin.toInt(), destination.toInt());
  }

  /// Given two H3 indexes, return the line of indexes between them (inclusive).
  ///
  /// This function may fail to find the line between two indexes, for
  /// example if they are very far apart. It may also fail when finding
  /// distances for indexes on opposite sides of a pentagon.
  ///
  /// Notes:
  ///
  ///  - The specific output of this function should not be considered stable
  ///    across library versions. The only guarantees the library provides are
  ///    that the line length will be `h3Distance(start, end) + 1` and that
  ///    every index in the line will be a neighbor of the preceding index.
  ///  - Lines are drawn in grid space, and may not correspond exactly to either
  ///    Cartesian lines or great arcs.
  @override
  List<BigInt> h3Line(BigInt origin, BigInt destination) {
    final originInt = origin.toInt();
    final destinationInt = destination.toInt();
    return using((arena) {
      final size = _h3c.h3LineSize(originInt, destinationInt);
      if (size < 0) throw H3Exception('Line cannot be calculated');
      final out = arena<Uint64>(size);
      final resultCode = _h3c.h3Line(originInt, destinationInt, out);
      if (resultCode != 0) throw H3Exception('Line cannot be calculated');
      final list = out.asTypedList(size).toList();
      return list.where((e) => e != 0).map((e) => e.toBigInt()).toList();
    });
  }

  /// Produces IJ coordinates for an H3 index anchored by an origin.
  ///
  /// - The coordinate space used by this function may have deleted
  /// regions or warping due to pentagonal distortion.
  /// - Coordinates are only comparable if they come from the same
  /// origin index.
  /// - Failure may occur if the index is too far away from the origin
  /// or if the index is on the other side of a pentagon.
  /// - This function is experimental, and its output is not guaranteed
  /// to be compatible across different versions of H3.
  @override
  CoordIJ experimentalH3ToLocalIj(BigInt origin, BigInt destination) {
    return using((arena) {
      final out = arena<c.CoordIJ>();
      final resultCode = _h3c.experimentalH3ToLocalIj(
        origin.toInt(),
        destination.toInt(),
        out,
      );

      // Switch statement and error codes cribbed from h3-js's implementation.
      switch (resultCode) {
        case 0:
          return out.ref.toPure();
        case 1:
          throw H3Exception('Incompatible origin and index.');
        case 2:
          throw H3Exception(
              'Local IJ coordinates undefined for this origin and index pair. '
              'The index may be too far from the origin.');
        case 3:
        case 4:
        case 5:
          throw H3Exception('Encountered possible pentagon distortion');
        default:
          throw H3Exception(
              'Local IJ coordinates undefined for this origin and index pair. '
              'The index may be too far from the origin.');
      }
    });
  }

  /// Produces an H3 index for IJ coordinates anchored by an origin.
  ///
  /// - The coordinate space used by this function may have deleted
  /// regions or warping due to pentagonal distortion.
  /// - Coordinates are only comparable if they come from the same
  /// origin index.
  /// - Failure may occur if the index is too far away from the origin
  /// or if the index is on the other side of a pentagon.
  /// - This function is experimental, and its output is not guaranteed
  /// to be compatible across different versions of H3.
  @override
  BigInt experimentalLocalIjToH3(BigInt origin, CoordIJ coordinates) {
    return using((arena) {
      final out = arena<Uint64>();
      final resultCode = _h3c.experimentalLocalIjToH3(
        origin.toInt(),
        coordinates.toNative(arena),
        out,
      );
      if (resultCode != 0) {
        throw H3Exception(
          'Index not defined for this origin and IJ coordinates pair. '
          'IJ coordinates may be too far from origin, or '
          'a pentagon distortion was encountered.',
        );
      }
      return out.value.toBigInt();
    });
  }

  /// Calculates great circle distance between two geo points.
  @override
  double pointDist(GeoCoord a, GeoCoord b, H3Units unit) {
    return using((arena) {
      switch (unit) {
        case H3Units.m:
          return _h3c.pointDistM(
            a.toRadians(_geoCoordConverter).toNative(arena),
            b.toRadians(_geoCoordConverter).toNative(arena),
          );
        case H3Units.km:
          return _h3c.pointDistKm(
            a.toRadians(_geoCoordConverter).toNative(arena),
            b.toRadians(_geoCoordConverter).toNative(arena),
          );
        case H3Units.rad:
          return _h3c.pointDistRads(
            a.toRadians(_geoCoordConverter).toNative(arena),
            b.toRadians(_geoCoordConverter).toNative(arena),
          );
      }
    });
  }

  /// Calculates exact area of a given cell in square [unit]s (e.g. m^2)
  @override
  double cellArea(BigInt h3Index, H3Units unit) {
    switch (unit) {
      case H3Units.m:
        return _h3c.cellAreaM2(h3Index.toInt());
      case H3Units.km:
        return _h3c.cellAreaKm2(h3Index.toInt());
      case H3Units.rad:
        return _h3c.cellAreaRads2(h3Index.toInt());
    }
  }

  /// Calculates exact length of a given unidirectional edge in [unit]s
  @override
  double exactEdgeLength(BigInt edgeIndex, H3Units unit) {
    switch (unit) {
      case H3Units.m:
        return _h3c.exactEdgeLengthM(edgeIndex.toInt());
      case H3Units.km:
        return _h3c.exactEdgeLengthKm(edgeIndex.toInt());
      case H3Units.rad:
        return _h3c.exactEdgeLengthRads(edgeIndex.toInt());
    }
  }

  /// Calculates average hexagon area at a given resolution in [unit]s
  @override
  double hexArea(int res, H3AreaUnits unit) {
    assert(res >= 0 && res < 16, 'Resolution must be in [0, 15] range');
    switch (unit) {
      case H3AreaUnits.m2:
        return _h3c.hexAreaM2(res);
      case H3AreaUnits.km2:
        return _h3c.hexAreaKm2(res);
    }
  }

  /// Calculates average hexagon edge length at a given resolution in [unit]s
  @override
  double edgeLength(int res, H3EdgeLengthUnits unit) {
    assert(res >= 0 && res < 16, 'Resolution must be in [0, 15] range');
    switch (unit) {
      case H3EdgeLengthUnits.m:
        return _h3c.edgeLengthM(res);
      case H3EdgeLengthUnits.km:
        return _h3c.edgeLengthKm(res);
    }
  }

  /// Returns the total count of hexagons in the world at a given resolution.
  ///
  /// If the library compiled to JS - note that above
  /// resolution 8 the exact count cannot be represented in a JavaScript 32-bit number,
  /// so consumers should use caution when applying further operations to the output.
  @override
  int numHexagons(int res) {
    assert(res >= 0 && res < 16, 'Resolution must be in [0, 15] range');
    return _h3c.numHexagons(res);
  }

  /// Returns all H3 indexes at resolution 0. As every index at every resolution > 0 is
  /// the descendant of a res 0 index, this can be used with h3ToChildren to iterate
  /// over H3 indexes at any resolution.
  @override
  List<BigInt> getRes0Indexes() {
    return using((arena) {
      final size = _h3c.res0IndexCount();
      final out = arena<Uint64>(size);
      _h3c.getRes0Indexes(out);
      return out.asTypedList(size).map((e) => e.toBigInt()).toList();
    });
  }

  /// Get the twelve pentagon indexes at a given resolution.
  @override
  List<BigInt> getPentagonIndexes(int res) {
    assert(res >= 0 && res < 16, 'Resolution must be in [0, 15] range');
    return using((arena) {
      final size = _h3c.pentagonIndexCount();
      final out = arena<Uint64>(size);
      _h3c.getPentagonIndexes(res, out);
      return out.asTypedList(size).map((e) => e.toBigInt()).toList();
    });
  }

  /// Converts radians to degrees
  @override
  double radsToDegs(double val) => _h3c.radsToDegs(val);

  /// Converts degrees to radians
  @override
  double degsToRads(double val) => _h3c.degsToRads(val);
}
