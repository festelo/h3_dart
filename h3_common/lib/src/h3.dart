import 'package:h3_common/h3_common.dart';

/// Provides access to H3 functions.
abstract class H3 {
  /// Determines if [h3Index] is a valid cell (hexagon or pentagon)
  bool isValidCell(H3Index h3Index);

  /// Determines if [h3Index] is a valid pentagon
  bool isPentagon(H3Index h3Index);

  /// Determines if [h3Index] is Class III (rotated versus
  /// the icosahedron and subject to shape distortion adding extra points on
  /// icosahedron edges, making them not true hexagons).
  bool isResClassIII(H3Index h3Index);

  /// Returns the base cell "number" (0 to 121) of the provided H3 cell
  ///
  /// Note: Technically works on H3 edges, but will return base cell of the
  /// origin cell.
  int getBaseCellNumber(H3Index h3Index);

  /// Find all icosahedron faces intersected by a given H3 index
  List<int> getIcosahedronFaces(H3Index h3Index);

  /// Returns the resolution of the provided H3 index
  ///
  /// Works on both cells and unidirectional edges.
  int getResolution(H3Index h3Index);

  /// Find the H3 index of the resolution res cell containing the lat/lng
  H3Index geoToCell(GeoCoord geoCoord, int res);

  /// Find the lat/lon center point g of the cell h3
  GeoCoord cellToGeo(H3Index h3Index);

  /// Gives the cell boundary in lat/lon coordinates for the cell with index [h3Index]
  ///
  /// ```dart
  /// h3.cellToBoundary(0x85283473fffffff)
  /// h3.cellToBoundary(133)
  /// ```
  List<GeoCoord> cellToBoundary(H3Index h3Index);

  /// Get the parent of the given [h3Index] hexagon at a particular [resolution]
  ///
  /// Returns 0 when result can't be calculated
  H3Index cellToParent(H3Index h3Index, int resolution);

  /// Get the children/descendents of the given [h3Index] hexagon at a particular [resolution]
  List<H3Index> cellToChildren(H3Index h3Index, int resolution);

  /// Get the number of children for a cell at a given resolution
  int cellToChildrenSize(H3Index h3Index, int resolution);

  /// Get the center child of the given [h3Index] hexagon at a particular [resolution]
  ///
  /// Returns 0 when result can't be calculated
  H3Index cellToCenterChild(H3Index h3Index, int resolution);

  /// Get the position of the cell within an ordered list of all children of the
  /// cell's parent at the specified [parentResolution].
  int cellToChildPos(H3Index h3Index, int parentResolution);

  /// Get the child cell at a given position within an ordered list of all children
  /// at the specified [childResolution]
  H3Index childPosToCell(
    int childPosition,
    H3Index h3Index,
    int childResolution,
  );

  /// Get all hexagons in a k-ring around a given center. The order of the
  /// hexagons is undefined.
  List<H3Index> gridDisk(H3Index h3Index, int ringSize);

  /// Get all hexagons in a k-ring around a given center, in an array of arrays
  /// ordered by distance from the origin. The order of the hexagons within each ring is undefined.
  List<List<H3Index>> gridDiskDistances(H3Index h3Index, int ringSize);

  /// Get all hexagons in a hollow hexagonal ring centered at origin with sides of a given length.
  /// Unlike gridDisk, this function will throw an error if there is a pentagon anywhere in the ring.
  List<H3Index> gridRingUnsafe(H3Index h3Index, int ringSize);

  /// Get all hexagons with centers contained in a given polygon.
  List<H3Index> polygonToCells({
    required List<GeoCoord> perimeter,
    required int resolution,
    List<List<GeoCoord>> holes = const [],
  });

  /// Get all hexagons with centers contained in a given polygon.
  List<H3Index> polygonToCellsExperimental({
    required List<GeoCoord> perimeter,
    required int resolution,
    List<List<GeoCoord>> holes = const [],
  });

  /// Get the outlines of a set of H3 hexagons, returned in GeoJSON MultiPolygon
  /// format (a List of polygons, each with a List of loops, each a List of
  /// coordinates).
  ///
  /// It is the responsibility of the caller to ensure that all hexagons in the
  /// set have the same resolution and that the set contains no duplicates. Behavior
  /// is undefined if duplicates or multiple resolutions are present, and the
  /// algorithm may produce unexpected or invalid polygons.
  List<List<List<GeoCoord>>> cellsToMultiPolygon(List<H3Index> h3Indexes);

  /// Compact a list of hexagons of the same resolution into a set of hexagons
  /// across multiple levels that represents the same area.
  List<H3Index> compactCells(List<H3Index> h3Set);

  /// Uncompact a compacted list of hexagons to hexagons of the same resolution
  List<H3Index> uncompactCells(
    List<H3Index> h3Set, {
    required int resolution,
  });

  /// Returns whether or not two H3 indexes are neighbors (share an edge)
  bool areNeighborCells(H3Index origin, H3Index destination);

  /// Get an H3 index representing a unidirectional edge for a given [origin]
  /// and [destination]
  H3Index cellsToDirectedEdge(H3Index origin, H3Index destination);

  /// Get the origin hexagon from an H3 index representing a unidirectional edge
  H3Index getDirectedEdgeOrigin(H3Index edgeIndex);

  /// Get the destination hexagon from an H3 index representing a unidirectional edge
  H3Index getDirectedEdgeDestination(H3Index edgeIndex);

  /// Whether the input is a valid unidirectional edge
  bool isValidDirectedEdge(H3Index edgeIndex);

  /// Get the origin, destination pair represented by a unidirectional edge
  ({H3Index origin, H3Index destination}) directedEdgeToCells(
      H3Index edgeIndex);

  /// Get all of the unidirectional edges with the given H3 index as the origin
  /// (i.e. an edge to every neighbor)
  List<H3Index> originToDirectedEdges(H3Index h3Index);

  /// Get the vertices of a given edge as an array of [lat, lng] points.
  ///
  /// Note that for edges that cross the edge of an icosahedron face,
  /// this may return 3 coordinates.
  List<GeoCoord> directedEdgeToBoundary(H3Index edgeIndex);

  /// Get the grid distance between two hex indexes. This function may fail
  /// to find the distance between two indexes if they are very far apart or
  /// on opposite sides of a pentagon.
  int gridDistance(H3Index origin, H3Index destination);

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
  ///    that the line length will be `gridDistance(start, end) + 1` and that
  ///    every index in the line will be a neighbor of the preceding index.
  ///  - Lines are drawn in grid space, and may not correspond exactly to either
  ///    Cartesian lines or great arcs.
  List<H3Index> gridPathCells(H3Index origin, H3Index destination);

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
  CoordIJ cellToLocalIj(H3Index origin, H3Index destination);

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
  H3Index localIjToCell(H3Index origin, CoordIJ coordinates);

  /// Great circle distance between two geo points. This is not specific to H3,
  /// but is implemented in the library and provided here as a convenience.
  double greatCircleDistance(GeoCoord a, GeoCoord b, H3Units unit);

  /// Calculates exact area of a given cell in square [unit]s (e.g. m^2)
  double cellArea(H3Index h3Index, H3Units unit);

  /// Calculate length of a given unidirectional [edge]
  double edgeLength(H3Index edge, H3Units unit);

  /// Average hexagon area at a given [resolution]
  double getHexagonAreaAvg(int resolution, H3MetricUnits unit);

  /// Average hexagon edge length at a given [resolution]
  double getHexagonEdgeLengthAvg(int resolution, H3MetricUnits unit);

  /// Find the index for a vertex of a cell.
  H3Index cellToVertex(H3Index h3Index, int vertexNum);

  /// Find the indexes for all vertexes of a cell.
  List<H3Index> cellToVertexes(H3Index h3Index);

  /// Get the [GeoCoord] of a given vertex
  GeoCoord vertexToGeo(H3Index h3Index);

  /// Returns true if the input is a valid vertex index
  bool isValidVertex(H3Index h3Index);

  /// The total count of hexagons in the world at a given resolution
  BigInt getNumCells(int resolution);

  /// Returns all H3 indexes at resolution 0. As every index at every resolution > 0 is
  /// the descendant of a res 0 index, this can be used with [cellToChildren] to iterate
  /// over H3 indexes at any resolution.
  List<H3Index> getRes0Cells();

  /// Get the twelve pentagon indexes at a given resolution.
  List<H3Index> getPentagons(int res);

  /// Converts degrees to radians
  double degsToRads(double deg);

  /// Converts radians to degrees
  double radsToDegs(double rad);
}
