@JS()
library types;

import "package:js/js.dart";

// Module h3
/// 64-bit hexidecimal string representation of an H3 index
/*type H3Index = string;*/
/// 64-bit hexidecimal string representation of an H3 index,
/// or two 32-bit integers in little endian order in an array.
/*type H3IndexInput = string | number[];*/
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

/// Length/Area units
@anonymous
@JS()
abstract class UNITS {
  external String get m;
  external set m(String v);
  external String get m2;
  external set m2(String v);
  external String get km;
  external set km(String v);
  external String get km2;
  external set km2(String v);
  external String get rads;
  external set rads(String v);
  external String get rads2;
  external set rads2(String v);
  external factory UNITS(
      {String m, String m2, String km, String km2, String rads, String rads2});
}

/// Whether a given string represents a valid H3 index
@JS("h3.h3IsValid")
external bool h3IsValid(dynamic /*String|List<num>*/ h3Index);

/// Whether the given H3 index is a pentagon
@JS("h3.h3IsPentagon")
external bool h3IsPentagon(dynamic /*String|List<num>*/ h3Index);

/// Whether the given H3 index is in a Class III resolution (rotated versus
/// the icosahedron and subject to shape distortion adding extra points on
/// icosahedron edges, making them not true hexagons).
@JS("h3.h3IsResClassIII")
external bool h3IsResClassIII(dynamic /*String|List<num>*/ h3Index);

/// Get the number of the base cell for a given H3 index
@JS("h3.h3GetBaseCell")
external num h3GetBaseCell(dynamic /*String|List<num>*/ h3Index);

/// Get the indices of all icosahedron faces intersected by a given H3 index
@JS("h3.h3GetFaces")
external List<num> h3GetFaces(dynamic /*String|List<num>*/ h3Index);

/// Returns the resolution of an H3 index
@JS("h3.h3GetResolution")
external num h3GetResolution(dynamic /*String|List<num>*/ h3Index);

/// Get the hexagon containing a lat,lon point
@JS("h3.geoToH3")
external String geoToH3(num lat, num lng, num res);

/// Get the lat,lon center of a given hexagon
@JS("h3.h3ToGeo")
external List<num> h3ToGeo(dynamic /*String|List<num>*/ h3Index);

/// Get the vertices of a given hexagon (or pentagon), as an array of [lat, lng]
/// points. For pentagons and hexagons on the edge of an icosahedron face, this
/// function may return up to 10 vertices.
@JS("h3.h3ToGeoBoundary")
external List<List<num>> h3ToGeoBoundary(String h3Index,
    [bool formatAsGeoJson]);

/// Get the parent of the given hexagon at a particular resolution
@JS("h3.h3ToParent")
external String h3ToParent(dynamic /*String|List<num>*/ h3Index, num res);

/// Get the children/descendents of the given hexagon at a particular resolution
@JS("h3.h3ToChildren")
external List<String> h3ToChildren(
    dynamic /*String|List<num>*/ h3Index, num res);

/// Get the center child of the given hexagon at a particular resolution
@JS("h3.h3ToCenterChild")
external String h3ToCenterChild(dynamic /*String|List<num>*/ h3Index, num res);

/// Get all hexagons in a k-ring around a given center. The order of the hexagons is undefined.
@JS("h3.kRing")
external List<String> kRing(dynamic /*String|List<num>*/ h3Index, num ringSize);

/// Get all hexagons in a k-ring around a given center, in an array of arrays
/// ordered by distance from the origin. The order of the hexagons within each ring is undefined.
@JS("h3.kRingDistances")
external List<List<String>> kRingDistances(
    dynamic /*String|List<num>*/ h3Index, num ringSize);

/// Get all hexagons in a hollow hexagonal ring centered at origin with sides of a given length.
/// Unlike kRing, this function will throw an error if there is a pentagon anywhere in the ring.
@JS("h3.hexRing")
external List<String> hexRing(
    dynamic /*String|List<num>*/ h3Index, num ringSize);

/// Get all hexagons with centers contained in a given polygon. The polygon
/// is specified with GeoJson semantics as an array of loops. Each loop is
/// an array of [lat, lng] pairs (or [lng, lat] if isGeoJson is specified).
/// The first loop is the perimeter of the polygon, and subsequent loops are
/// expected to be holes.
/// pairs instead of [lat, lng]
@JS("h3.polyfill")
external List<String> polyfill(
    List<List<dynamic>> /*List<List<num>>|List<List<List<num>>>*/ coordinates,
    num res,
    [bool isGeoJson]);

/// Get the outlines of a set of H3 hexagons, returned in GeoJSON MultiPolygon
/// format (an array of polygons, each with an array of loops, each an array of
/// coordinates). Coordinates are returned as [lat, lng] pairs unless GeoJSON
/// is requested.
/// It is the responsibility of the caller to ensure that all hexagons in the
/// set have the same resolution and that the set contains no duplicates. Behavior
/// is undefined if duplicates or multiple resolutions are present, and the
/// algorithm may produce unexpected or invalid polygons.
/// [lng, lat], closed loops
@JS("h3.h3SetToMultiPolygon")
external List<List<List<List<num>>>> h3SetToMultiPolygon(
    List<dynamic /*String|List<num>*/ > h3Indexes,
    [bool formatAsGeoJson]);

/// Compact a set of hexagons of the same resolution into a set of hexagons across
/// multiple levels that represents the same area.
@JS("h3.compact")
external List<String> compact(List<dynamic /*String|List<num>*/ > h3Set);

/// Uncompact a compacted set of hexagons to hexagons of the same resolution
@JS("h3.uncompact")
external List<String> uncompact(
    List<dynamic /*String|List<num>*/ > compactedSet, num res);

/// Whether two H3 indexes are neighbors (share an edge)
@JS("h3.h3IndexesAreNeighbors")
external bool h3IndexesAreNeighbors(dynamic /*String|List<num>*/ origin,
    dynamic /*String|List<num>*/ destination);

/// Get an H3 index representing a unidirectional edge for a given origin and destination
@JS("h3.getH3UnidirectionalEdge")
external String getH3UnidirectionalEdge(dynamic /*String|List<num>*/ origin,
    dynamic /*String|List<num>*/ destination);

/// Get the origin hexagon from an H3 index representing a unidirectional edge
@JS("h3.getOriginH3IndexFromUnidirectionalEdge")
external String getOriginH3IndexFromUnidirectionalEdge(
    dynamic /*String|List<num>*/ edgeIndex);

/// Get the destination hexagon from an H3 index representing a unidirectional edge
@JS("h3.getDestinationH3IndexFromUnidirectionalEdge")
external String getDestinationH3IndexFromUnidirectionalEdge(
    dynamic /*String|List<num>*/ edgeIndex);

/// Whether the input is a valid unidirectional edge
@JS("h3.h3UnidirectionalEdgeIsValid")
external bool h3UnidirectionalEdgeIsValid(
    dynamic /*String|List<num>*/ edgeIndex);

/// Get the [origin, destination] pair represented by a unidirectional edge
@JS("h3.getH3IndexesFromUnidirectionalEdge")
external List<String> getH3IndexesFromUnidirectionalEdge(
    dynamic /*String|List<num>*/ edgeIndex);

/// Get all of the unidirectional edges with the given H3 index as the origin (i.e. an edge to
/// every neighbor)
@JS("h3.getH3UnidirectionalEdgesFromHexagon")
external List<String> getH3UnidirectionalEdgesFromHexagon(
    dynamic /*String|List<num>*/ h3Index);

/// Get the vertices of a given edge as an array of [lat, lng] points. Note that for edges that
/// cross the edge of an icosahedron face, this may return 3 coordinates.
@JS("h3.getH3UnidirectionalEdgeBoundary")
external List<List<num>> getH3UnidirectionalEdgeBoundary(
    dynamic /*String|List<num>*/ edgeIndex,
    [bool formatAsGeoJson]);

/// Get the grid distance between two hex indexes. This function may fail
/// to find the distance between two indexes if they are very far apart or
/// on opposite sides of a pentagon.
/// number if the distance could not be computed
@JS("h3.h3Distance")
external num h3Distance(dynamic /*String|List<num>*/ origin,
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
@JS("h3.h3Line")
external List<String> h3Line(dynamic /*String|List<num>*/ origin,
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
@JS("h3.experimentalH3ToLocalIj")
external CoordIJ experimentalH3ToLocalIj(dynamic /*String|List<num>*/ origin,
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
@JS("h3.experimentalLocalIjToH3")
external String experimentalLocalIjToH3(
    dynamic /*String|List<num>*/ origin, CoordIJ coords);

/// Great circle distance between two geo points. This is not specific to H3,
/// but is implemented in the library and provided here as a convenience.
@JS("h3.pointDist")
external num pointDist(List<num> latlng1, List<num> latlng2, String unit);

/// Exact area of a given cell
@JS("h3.cellArea")
external num cellArea(String h3Index, String unit);

/// Exact length of a given unidirectional edge
@JS("h3.exactEdgeLength")
external num exactEdgeLength(String edge, String unit);

/// Average hexagon area at a given resolution
@JS("h3.hexArea")
external num hexArea(num res, String unit);

/// Average hexagon edge length at a given resolution
@JS("h3.edgeLength")
external num edgeLength(num res, String unit);

/// The total count of hexagons in the world at a given resolution. Note that above
/// resolution 8 the exact count cannot be represented in a JavaScript 32-bit number,
/// so consumers should use caution when applying further operations to the output.
@JS("h3.numHexagons")
external num numHexagons(num res);

/// Get all H3 indexes at resolution 0. As every index at every resolution > 0 is
/// the descendant of a res 0 index, this can be used with h3ToChildren to iterate
/// over H3 indexes at any resolution.
@JS("h3.getRes0Indexes")
external List<String> getRes0Indexes();

/// Get the twelve pentagon indexes at a given resolution.
@JS("h3.getPentagonIndexes")
external List<String> getPentagonIndexes(num res);

/// Convert degrees to radians
@JS("h3.degsToRads")
external num degsToRads(num deg);

/// Convert radians to degrees
@JS("h3.radsToDegs")
external num radsToDegs(num rad);
// End module h3
