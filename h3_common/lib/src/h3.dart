import 'package:h3_common/h3_common.dart';

/// Provides access to H3 functions.
abstract class H3 {
  /// Determines if [h3Index] is a valid cell (hexagon or pentagon)
  bool h3IsValid(BigInt h3Index);

  /// Determines if [h3Index] is a valid pentagon
  bool h3IsPentagon(BigInt h3Index);

  /// Determines if [h3Index] is Class III (rotated versus
  /// the icosahedron and subject to shape distortion adding extra points on
  /// icosahedron edges, making them not true hexagons).
  bool h3IsResClassIII(BigInt h3Index);

  /// Returns the base cell "number" (0 to 121) of the provided H3 cell
  ///
  /// Note: Technically works on H3 edges, but will return base cell of the
  /// origin cell.
  int h3GetBaseCell(BigInt h3Index);

  /// Find all icosahedron faces intersected by a given H3 index
  List<int> h3GetFaces(BigInt h3Index);

  /// Returns the resolution of the provided H3 index
  ///
  /// Works on both cells and unidirectional edges.
  int h3GetResolution(BigInt h3Index);

  /// Find the H3 index of the resolution res cell containing the lat/lng
  BigInt geoToH3(GeoCoord geoCoord, int res);

  /// Find the lat/lon center point g of the cell h3
  GeoCoord h3ToGeo(BigInt h3Index);

  /// Gives the cell boundary in lat/lon coordinates for the cell with index [h3Index]
  ///
  /// ```dart
  /// h3.h3ToGeoBoundary(0x85283473fffffff)
  /// h3.h3ToGeoBoundary(133)
  /// ```
  List<GeoCoord> h3ToGeoBoundary(BigInt h3Index);

  /// Get the parent of the given [h3Index] hexagon at a particular [resolution]
  ///
  /// Returns 0 when result can't be calculated
  BigInt h3ToParent(BigInt h3Index, int resolution);

  /// Get the children/descendents of the given [h3Index] hexagon at a particular [resolution]
  List<BigInt> h3ToChildren(BigInt h3Index, int resolution);

  /// Get the center child of the given [h3Index] hexagon at a particular [resolution]
  ///
  /// Returns 0 when result can't be calculated
  BigInt h3ToCenterChild(BigInt h3Index, int resolution);

  /// Maximum number of hexagons in k-ring
  List<BigInt> kRing(BigInt h3Index, int ringSize);

  /// Hollow hexagon ring at some origin
  List<BigInt> hexRing(BigInt h3Index, int ringSize);

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
  List<BigInt> polyfill({
    required List<GeoCoord> coordinates,
    required int resolution,
    List<List<GeoCoord>> holes,
  });

  /// Compact a set of hexagons of the same resolution into a set of hexagons
  /// across multiple levels that represents the same area.
  List<BigInt> compact(List<BigInt> hexagons);

  /// Uncompact a compacted set of hexagons to hexagons of the same resolution
  List<BigInt> uncompact(
    List<BigInt> compactedHexagons, {
    required int resolution,
  });

  /// Returns whether or not two H3 indexes are neighbors (share an edge)
  bool h3IndexesAreNeighbors(BigInt origin, BigInt destination);

  /// Get an H3 index representing a unidirectional edge for a given origin and
  /// destination
  ///
  /// Returns 0 when result can't be calculated
  BigInt getH3UnidirectionalEdge(BigInt origin, BigInt destination);

  /// Get the origin hexagon from an H3 index representing a unidirectional edge
  ///
  /// Returns 0 when result can't be calculated
  BigInt getOriginH3IndexFromUnidirectionalEdge(BigInt edgeIndex);

  /// Get the destination hexagon from an H3 index representing a unidirectional edge
  ///
  /// Returns 0 when result can't be calculated
  BigInt getDestinationH3IndexFromUnidirectionalEdge(BigInt edgeIndex);

  /// Returns whether or not the input is a valid unidirectional edge
  bool h3UnidirectionalEdgeIsValid(BigInt edgeIndex);

  /// Get the [origin, destination] pair represented by a unidirectional edge
  List<BigInt> getH3IndexesFromUnidirectionalEdge(BigInt edgeIndex);

  /// Get all of the unidirectional edges with the given H3 index as the origin
  /// (i.e. an edge to every neighbor)
  List<BigInt> getH3UnidirectionalEdgesFromHexagon(BigInt edgeIndex);

  /// Get the vertices of a given edge as an array of [lat, lng] points. Note
  /// that for edges that cross the edge of an icosahedron face, this may return
  /// 3 coordinates.
  List<GeoCoord> getH3UnidirectionalEdgeBoundary(BigInt edgeIndex);

  /// Get the grid distance between two hex indexes. This function may fail
  /// to find the distance between two indexes if they are very far apart or
  /// on opposite sides of a pentagon.
  ///
  /// Returns -1 when result can't be calculated
  int h3Distance(BigInt origin, BigInt destination);

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
  List<BigInt> h3Line(BigInt origin, BigInt destination);

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
  CoordIJ experimentalH3ToLocalIj(BigInt origin, BigInt destination);

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
  BigInt experimentalLocalIjToH3(BigInt origin, CoordIJ coordinates);

  /// Calculates great circle distance between two geo points.
  double pointDist(GeoCoord a, GeoCoord b, H3Units unit);

  /// Calculates exact area of a given cell in square [unit]s (e.g. m^2)
  double cellArea(BigInt h3Index, H3Units unit);

  /// Calculates exact length of a given unidirectional edge in [unit]s
  double exactEdgeLength(BigInt edgeIndex, H3Units unit);

  /// Calculates average hexagon area at a given resolution in [unit]s
  double hexArea(int res, H3AreaUnits unit);

  /// Calculates average hexagon edge length at a given resolution in [unit]s
  double edgeLength(int res, H3EdgeLengthUnits unit);

  /// Returns the total count of hexagons in the world at a given resolution.
  ///
  /// If the library compiled to JS - note that above
  /// resolution 8 the exact count cannot be represented in a JavaScript 32-bit number,
  /// so consumers should use caution when applying further operations to the output.
  int numHexagons(int res);

  /// Returns all H3 indexes at resolution 0. As every index at every resolution > 0 is
  /// the descendant of a res 0 index, this can be used with h3ToChildren to iterate
  /// over H3 indexes at any resolution.
  List<BigInt> getRes0Indexes();

  /// Get the twelve pentagon indexes at a given resolution.
  List<BigInt> getPentagonIndexes(int res);

  /// Converts radians to degrees
  double radsToDegs(double val);

  /// Converts degrees to radians
  double degsToRads(double val);
}
