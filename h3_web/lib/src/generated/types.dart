@JS()
library types;

import "package:js/js.dart";

// Module h3
/// Convert an H3 index (64-bit hexidecimal string) into a "split long" - a pair of 32-bit ints
@JS("h3.h3IndexToSplitLong")
external List<num> /*Tuple of <num,num>*/ h3IndexToSplitLong(
    dynamic /*String|List<num>*/ h3Index);

/// Get a H3 index string from a split long (pair of 32-bit ints)
@JS("h3.splitLongToH3Index")
external String splitLongToH3Index(num lower, num upper);

/// Whether a given string represents a valid H3 index
/// @static
@JS("h3.isValidCell")
external bool isValidCell(dynamic /*String|List<num>*/ h3Index);

/// Whether the given H3 index is a pentagon
/// @static
@JS("h3.isPentagon")
external bool isPentagon(dynamic /*String|List<num>*/ h3Index);

/// Whether the given H3 index is in a Class III resolution (rotated versus
/// the icosahedron and subject to shape distortion adding extra points on
/// icosahedron edges, making them not true hexagons).
/// @static
@JS("h3.isResClassIII")
external bool isResClassIII(dynamic /*String|List<num>*/ h3Index);

/// Get the number of the base cell for a given H3 index
/// @static
@JS("h3.getBaseCellNumber")
external num getBaseCellNumber(dynamic /*String|List<num>*/ h3Index);

/// Get the indices of all icosahedron faces intersected by a given H3 index
/// @static
@JS("h3.getIcosahedronFaces")
external List<num> getIcosahedronFaces(dynamic /*String|List<num>*/ h3Index);

/// Returns the resolution of an H3 index
/// @static
@JS("h3.getResolution")
external num getResolution(dynamic /*String|List<num>*/ h3Index);

/// Get the hexagon containing a lat,lon point
/// @static
@JS("h3.latLngToCell")
external String latLngToCell(num lat, num lng, num res);

/// Get the lat,lon center of a given hexagon
/// @static
@JS("h3.cellToLatLng")
external List<num> /*Tuple of <num,num>*/ cellToLatLng(
    dynamic /*String|List<num>*/ h3Index);

/// Get the vertices of a given hexagon (or pentagon), as an array of [lat, lng]
/// points. For pentagons and hexagons on the edge of an icosahedron face, this
/// function may return up to 10 vertices.
/// @static
@JS("h3.cellToBoundary")
external List<List<num> /*Tuple of <num,num>*/ > cellToBoundary(
    dynamic /*String|List<num>*/ h3Index,
    [bool formatAsGeoJson]);

/// Get the parent of the given hexagon at a particular resolution
/// @static
@JS("h3.cellToParent")
external String cellToParent(dynamic /*String|List<num>*/ h3Index, num res);

/// Get the children/descendents of the given hexagon at a particular resolution
/// @static
@JS("h3.cellToChildren")
external List<String> cellToChildren(
    dynamic /*String|List<num>*/ h3Index, num res);

/// Get the number of children for a cell at a given resolution
/// @static
@JS("h3.cellToChildrenSize")
external num cellToChildrenSize(dynamic /*String|List<num>*/ h3Index, num res);

/// Get the center child of the given hexagon at a particular resolution
/// @static
@JS("h3.cellToCenterChild")
external String cellToCenterChild(
    dynamic /*String|List<num>*/ h3Index, num res);

/// Get the position of the cell within an ordered list of all children of the
/// cell's parent at the specified resolution.
/// @static
@JS("h3.cellToChildPos")
external num cellToChildPos(
    dynamic /*String|List<num>*/ h3Index, num parentRes);

/// Get the child cell at a given position within an ordered list of all children
/// at the specified resolution
/// @static
@JS("h3.childPosToCell")
external String childPosToCell(
    num childPos, dynamic /*String|List<num>*/ h3Index, num childRes);

/// Get all hexagons in a k-ring around a given center. The order of the hexagons is undefined.
/// @static
@JS("h3.gridDisk")
external List<String> gridDisk(
    dynamic /*String|List<num>*/ h3Index, num ringSize);

/// Get all hexagons in a k-ring around a given center, in an array of arrays
/// ordered by distance from the origin. The order of the hexagons within each ring is undefined.
/// @static
@JS("h3.gridDiskDistances")
external List<List<String>> gridDiskDistances(
    dynamic /*String|List<num>*/ h3Index, num ringSize);

/// Get all hexagons in a hollow hexagonal ring centered at origin with sides of a given length.
/// Unlike gridDisk, this function will throw an error if there is a pentagon anywhere in the ring.
/// @static
@JS("h3.gridRingUnsafe")
external List<String> gridRingUnsafe(
    dynamic /*String|List<num>*/ h3Index, num ringSize);

/// Get all hexagons with centers contained in a given polygon. The polygon
/// is specified with GeoJson semantics as an array of loops. Each loop is
/// an array of [lat, lng] pairs (or [lng, lat] if isGeoJson is specified).
/// The first loop is the perimeter of the polygon, and subsequent loops are
/// expected to be holes.
/// @static
/// Array of loops, or a single loop
/// pairs instead of [lat, lng]
@JS("h3.polygonToCells")
external List<String> polygonToCells(
    List<List<dynamic>> /*List<List<num>>|List<List<List<num>>>*/ coordinates,
    num res,
    [bool isGeoJson]);

/// Get all hexagons with centers contained in a given polygon. The polygon
/// is specified with GeoJson semantics as an array of loops. Each loop is
/// an array of [lat, lng] pairs (or [lng, lat] if isGeoJson is specified).
/// The first loop is the perimeter of the polygon, and subsequent loops are
/// expected to be holes.
/// @static
/// Array of loops, or a single loop
/// pairs instead of [lat, lng]
@JS("h3.polygonToCellsExperimental")
external List<String> polygonToCellsExperimental(
    List<List<dynamic>> /*List<List<num>>|List<List<List<num>>>*/ coordinates,
    num res,
    String flags,
    [bool isGeoJson]);

/// Get the outlines of a set of H3 hexagons, returned in GeoJSON MultiPolygon
/// format (an array of polygons, each with an array of loops, each an array of
/// coordinates). Coordinates are returned as [lat, lng] pairs unless GeoJSON
/// is requested.
/// It is the responsibility of the caller to ensure that all hexagons in the
/// set have the same resolution and that the set contains no duplicates. Behavior
/// is undefined if duplicates or multiple resolutions are present, and the
/// algorithm may produce unexpected or invalid polygons.
/// @static
@JS("h3.cellsToMultiPolygon")
external List<List<List<List<num> /*Tuple of <num,num>*/ >>>
    cellsToMultiPolygon(List<dynamic /*String|List<num>*/ > h3Indexes,
        [bool formatAsGeoJson]);

/// Compact a set of hexagons of the same resolution into a set of hexagons across
/// multiple levels that represents the same area.
/// @static
@JS("h3.compactCells")
external List<String> compactCells(List<dynamic /*String|List<num>*/ > h3Set);

/// Uncompact a compacted set of hexagons to hexagons of the same resolution
/// @static
@JS("h3.uncompactCells")
external List<String> uncompactCells(
    List<dynamic /*String|List<num>*/ > compactedSet, num res);

/// Whether two H3 indexes are neighbors (share an edge)
/// @static
@JS("h3.areNeighborCells")
external bool areNeighborCells(dynamic /*String|List<num>*/ origin,
    dynamic /*String|List<num>*/ destination);

/// Get an H3 index representing a unidirectional edge for a given origin and destination
/// @static
@JS("h3.cellsToDirectedEdge")
external String cellsToDirectedEdge(dynamic /*String|List<num>*/ origin,
    dynamic /*String|List<num>*/ destination);

/// Get the origin hexagon from an H3 index representing a unidirectional edge
/// @static
@JS("h3.getDirectedEdgeOrigin")
external String getDirectedEdgeOrigin(dynamic /*String|List<num>*/ edgeIndex);

/// Get the destination hexagon from an H3 index representing a unidirectional edge
/// @static
@JS("h3.getDirectedEdgeDestination")
external String getDirectedEdgeDestination(
    dynamic /*String|List<num>*/ edgeIndex);

/// Whether the input is a valid unidirectional edge
/// @static
@JS("h3.isValidDirectedEdge")
external bool isValidDirectedEdge(dynamic /*String|List<num>*/ edgeIndex);

/// Get the [origin, destination] pair represented by a unidirectional edge
/// @static
@JS("h3.directedEdgeToCells")
external List<String> directedEdgeToCells(
    dynamic /*String|List<num>*/ edgeIndex);

/// Get all of the unidirectional edges with the given H3 index as the origin (i.e. an edge to
/// every neighbor)
/// @static
@JS("h3.originToDirectedEdges")
external List<String> originToDirectedEdges(
    dynamic /*String|List<num>*/ h3Index);

/// Get the vertices of a given edge as an array of [lat, lng] points. Note that for edges that
/// cross the edge of an icosahedron face, this may return 3 coordinates.
/// @static
@JS("h3.directedEdgeToBoundary")
external List<List<num> /*Tuple of <num,num>*/ > directedEdgeToBoundary(
    dynamic /*String|List<num>*/ edgeIndex,
    [bool formatAsGeoJson]);

/// Get the grid distance between two hex indexes. This function may fail
/// to find the distance between two indexes if they are very far apart or
/// on opposite sides of a pentagon.
/// @static
@JS("h3.gridDistance")
external num gridDistance(dynamic /*String|List<num>*/ origin,
    dynamic /*String|List<num>*/ destination);

/// Given two H3 indexes, return the line of indexes between them (inclusive).
/// This function may fail to find the line between two indexes, for
/// example if they are very far apart. It may also fail when finding
/// distances for indexes on opposite sides of a pentagon.
/// Notes:
/// - The specific output of this function should not be considered stable
/// across library versions. The only guarantees the library provides are
/// that the line length will be `h3Distance(start, end) + 1` and that
/// every index in the line will be a neighbor of the preceding index.
/// - Lines are drawn in grid space, and may not correspond exactly to either
/// Cartesian lines or great arcs.
/// @static
@JS("h3.gridPathCells")
external List<String> gridPathCells(dynamic /*String|List<num>*/ origin,
    dynamic /*String|List<num>*/ destination);

/// Produces IJ coordinates for an H3 index anchored by an origin.
/// - The coordinate space used by this function may have deleted
/// regions or warping due to pentagonal distortion.
/// - Coordinates are only comparable if they come from the same
/// origin index.
/// - Failure may occur if the index is too far away from the origin
/// or if the index is on the other side of a pentagon.
/// - This function is experimental, and its output is not guaranteed
/// to be compatible across different versions of H3.
/// @static
@JS("h3.cellToLocalIj")
external CoordIJ cellToLocalIj(dynamic /*String|List<num>*/ origin,
    dynamic /*String|List<num>*/ destination);

/// Produces an H3 index for IJ coordinates anchored by an origin.
/// - The coordinate space used by this function may have deleted
/// regions or warping due to pentagonal distortion.
/// - Coordinates are only comparable if they come from the same
/// origin index.
/// - Failure may occur if the index is too far away from the origin
/// or if the index is on the other side of a pentagon.
/// - This function is experimental, and its output is not guaranteed
/// to be compatible across different versions of H3.
/// @static
@JS("h3.localIjToCell")
external String localIjToCell(
    dynamic /*String|List<num>*/ origin, CoordIJ coords);

/// Great circle distance between two geo points. This is not specific to H3,
/// but is implemented in the library and provided here as a convenience.
/// @static
@JS("h3.greatCircleDistance")
external num greatCircleDistance(
    List<num> latLng1, List<num> latLng2, String unit);

/// Exact area of a given cell
/// @static
@JS("h3.cellArea")
external num cellArea(dynamic /*String|List<num>*/ h3Index, String unit);

/// Calculate length of a given unidirectional edge
/// @static
@JS("h3.edgeLength")
external num edgeLength(dynamic /*String|List<num>*/ edge, String unit);

/// Average hexagon area at a given resolution
/// @static
@JS("h3.getHexagonAreaAvg")
external num getHexagonAreaAvg(num res, String unit);

/// Average hexagon edge length at a given resolution
/// @static
@JS("h3.getHexagonEdgeLengthAvg")
external num getHexagonEdgeLengthAvg(num res, String unit);

/// Find the index for a vertex of a cell.
/// @static
@JS("h3.cellToVertex")
external String cellToVertex(
    dynamic /*String|List<num>*/ h3Index, num vertexNum);

/// Find the indexes for all vertexes of a cell.
/// @static
@JS("h3.cellToVertexes")
external List<String> cellToVertexes(dynamic /*String|List<num>*/ h3Index);

/// Get the lat, lng of a given vertex
/// @static
@JS("h3.vertexToLatLng")
external List<num> /*Tuple of <num,num>*/ vertexToLatLng(
    dynamic /*String|List<num>*/ h3Index);

/// Returns true if the input is a valid vertex index.
/// @static
@JS("h3.isValidVertex")
external bool isValidVertex(dynamic /*String|List<num>*/ h3Index);

/// The total count of hexagons in the world at a given resolution. Note that above
/// resolution 8 the exact count cannot be represented in a JavaScript 32-bit number,
/// so consumers should use caution when applying further operations to the output.
/// @static
@JS("h3.getNumCells")
external num getNumCells(num res);

/// Get all H3 indexes at resolution 0. As every index at every resolution > 0 is
/// the descendant of a res 0 index, this can be used with h3ToChildren to iterate
/// over H3 indexes at any resolution.
/// @static
@JS("h3.getRes0Cells")
external List<String> getRes0Cells();

/// Get the twelve pentagon indexes at a given resolution.
/// @static
@JS("h3.getPentagons")
external List<String> getPentagons(num res);

/// Convert degrees to radians
/// @static
@JS("h3.degsToRads")
external num degsToRads(num deg);

/// Convert radians to degrees
/// @static
@JS("h3.radsToDegs")
external num radsToDegs(num rad);
// Module UNITS
@JS("h3.UNITS.m")
external String get m;
@JS("h3.UNITS.m2")
external String get m2;
@JS("h3.UNITS.km")
external String get km;
@JS("h3.UNITS.km2")
external String get km2;
@JS("h3.UNITS.rads")
external String get rads;
@JS("h3.UNITS.rads2")
external String get rads2;
// End module UNITS

// Module POLYGON_TO_CELLS_FLAGS
@JS("h3.POLYGON_TO_CELLS_FLAGS.containmentCenter")
external String get containmentCenter;
@JS("h3.POLYGON_TO_CELLS_FLAGS.containmentFull")
external String get containmentFull;
@JS("h3.POLYGON_TO_CELLS_FLAGS.containmentOverlapping")
external String get containmentOverlapping;
@JS("h3.POLYGON_TO_CELLS_FLAGS.containmentOverlappingBbox")
external String get containmentOverlappingBbox;

// End module POLYGON_TO_CELLS_FLAGS
/// 64-bit hexidecimal string representation of an H3 index
/*export type H3Index = string;*/
/// 64-bit hexidecimal string representation of an H3 index,
/// or two 32-bit integers in little endian order in an array.
/*export type H3IndexInput = string | number[];*/
/// Coordinates as an `{i, j}` pair
@anonymous
@JS()
abstract class CoordIJ {
  external num get i;
  external set i(num v);
  external num get j;
  external set j(num v);
  external factory CoordIJ({num i, num j});
}

/// Custom JS Error instance with an attached error code. Error codes come from the
/// core H3 library and can be found [in the H3 docs](https://h3geo.org/docs/library/errors#table-of-error-codes).
@anonymous
@JS()
abstract class H3Error {
  external String get message;
  external set message(String v);
  external num get code;
  external set code(num v);
  external factory H3Error({String message, num code});
}

/// Pair of lat,lng coordinates (or lng,lat if GeoJSON output is specified)
/*export type CoordPair = [number,number];*/
/// Pair of lower,upper 32-bit ints representing a 64-bit value
/*export type SplitLong = [number,number];*/

// End module h3
