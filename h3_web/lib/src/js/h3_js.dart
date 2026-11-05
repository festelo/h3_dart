/// Bindings to the [h3-js](https://github.com/uber/h3-js) library, written
/// with `dart:js_interop`, so they compile with both dart2js and dart2wasm.
///
/// Only the functions used by `H3Web` are bound. Every H3 index crosses the
/// boundary as a 64-bit hexadecimal string (h3-js also accepts a split long,
/// but strings are cheaper to convert on both compilers).
library;

import 'dart:js_interop';

import 'package:h3_common/h3_common.dart' show defaultH3JsUrl;

/// The `h3` object that h3-js puts on `globalThis`.
@JS('h3')
external H3Js? get _h3Global;

H3Js? _cached;

/// Returns the loaded h3-js library.
///
/// Throws a [StateError] that says how to fix it when h3-js is not loaded.
H3Js get h3js {
  final cached = _cached;
  if (cached != null) return cached;
  final h3 = _h3Global;
  if (h3 == null) {
    throw StateError(
      'h3-js is not loaded. Call await H3Web.ensureLoaded() before using H3, '
      'or add <script src="$defaultH3JsUrl"></script> to web/index.html, '
      'before the script that loads your app '
      '(flutter_bootstrap.js in a Flutter app), without defer or async.',
    );
  }
  return _cached = h3;
}

/// Whether h3-js is loaded on the page.
bool get isH3JsLoadedOnPage => _cached != null || _h3Global != null;

/// A `[lat, lng]` pair.
typedef JSCoordPair = JSArray<JSNumber>;

/// A loop of `[lat, lng]` pairs.
typedef JSLoop = JSArray<JSCoordPair>;

extension type H3Js._(JSObject _) implements JSObject {
  // Indexing and inspection
  external bool isValidCell(String h3Index);
  external bool isValidIndex(String h3Index);
  external bool isPentagon(String h3Index);
  external bool isResClassIII(String h3Index);
  external int getBaseCellNumber(String h3Index);
  external int getIndexDigit(String h3Index, int digit);
  external String constructCell(
    int baseCellNumber,
    JSArray<JSNumber> digits,
    int res,
  );
  external JSArray<JSNumber> getIcosahedronFaces(String h3Index);
  external int getResolution(String h3Index);
  external String latLngToCell(double lat, double lng, int res);
  external JSCoordPair cellToLatLng(String h3Index);
  external JSLoop cellToBoundary(String h3Index);

  // Hierarchy
  external String? cellToParent(String h3Index, int res);
  external JSArray<JSString> cellToChildren(String h3Index, int res);
  external double cellToChildrenSize(String h3Index, int res);
  external String? cellToCenterChild(String h3Index, int res);
  external double cellToChildPos(String h3Index, int parentRes);
  external String childPosToCell(int childPos, String h3Index, int childRes);
  external JSArray<JSString> compactCells(JSArray<JSString> h3Set);
  external JSArray<JSString> uncompactCells(
    JSArray<JSString> compactedSet,
    int res,
  );

  // Traversal
  external JSArray<JSString> gridDisk(String h3Index, int ringSize);
  external JSArray<JSArray<JSString>> gridDiskDistances(
    String h3Index,
    int ringSize,
  );
  external JSArray<JSString> gridRingUnsafe(String h3Index, int ringSize);
  external JSArray<JSString> gridRing(String h3Index, int ringSize);
  external int gridDistance(String origin, String destination);
  external JSArray<JSString> gridPathCells(String origin, String destination);
  external JSCoordIJ cellToLocalIj(String origin, String destination);
  external String localIjToCell(String origin, JSCoordIJ coords);

  // Regions
  external JSArray<JSString> polygonToCells(
    JSArray<JSLoop> coordinates,
    int res,
  );
  external JSArray<JSString> polygonToCellsExperimental(
    JSArray<JSLoop> coordinates,
    int res,
    String flags,
  );
  external JSArray<JSArray<JSLoop>> cellsToMultiPolygon(
    JSArray<JSString> h3Indexes,
  );

  // Directed edges
  external bool areNeighborCells(String origin, String destination);
  external String? cellsToDirectedEdge(String origin, String destination);
  external String? getDirectedEdgeOrigin(String edgeIndex);
  external String? getDirectedEdgeDestination(String edgeIndex);
  external bool isValidDirectedEdge(String edgeIndex);
  external String reverseDirectedEdge(String edgeIndex);
  external JSArray<JSString> directedEdgeToCells(String edgeIndex);
  external JSArray<JSString> originToDirectedEdges(String h3Index);
  external JSLoop directedEdgeToBoundary(String edgeIndex);

  // Vertexes
  external String cellToVertex(String h3Index, int vertexNum);
  external JSArray<JSString> cellToVertexes(String h3Index);
  external JSCoordPair vertexToLatLng(String h3Index);
  external bool isValidVertex(String h3Index);

  // Measurements
  external double greatCircleDistance(
    JSCoordPair latLng1,
    JSCoordPair latLng2,
    String unit,
  );
  external double cellArea(String h3Index, String unit);
  external double edgeLength(String edge, String unit);
  external double getHexagonAreaAvg(int res, String unit);
  external double getHexagonEdgeLengthAvg(int res, String unit);
  external double getNumCells(int res);
  external JSArray<JSString> getRes0Cells();
  external JSArray<JSString> getPentagons(int res);
  external double degsToRads(double deg);
  external double radsToDegs(double rad);
}

/// Coordinates as an `{i, j}` object.
extension type JSCoordIJ._(JSObject _) implements JSObject {
  external factory JSCoordIJ({int i, int j});
  external int get i;
  external int get j;
}
