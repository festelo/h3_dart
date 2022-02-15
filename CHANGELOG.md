## 0.4.0
* **[BREAKING]** Change return types for `h3.h3IsPentagon` and h3IsResClassIII methods from [int] to [bool]
* Fix broken `h3.h3GetFaces` method
* Add `h3.h3ToParent` and `h3.h3ToChildren` methods
* Add tests for following methods:
```
h3.h3IsPentagon
h3.h3IsResClassIII,
h3.h3GetFaces
h3.h3GetBaseCell
h3.h3ToParent
h3.h3ToChildren
h3.h3ToCenterChild
```

## 0.3.0
* **[BREAKING]** resolution assert was added to `h3.polyfill` function.
* `CoordIJ` class was added
* `H3Exception` class was added
* `H3Units`, `H3AreaUnits`, `H3EdgeLengthUnits` enums were added
* Freeing allocated memory added
* `h3.h3IsValid` was added
* `h3.h3IsPentagon` was added
* `h3.h3IsResClassIII` was added
* `h3.h3GetBaseCell` was added
* `h3.h3GetFaces` was added
* `h3.h3GetResolution` was added
* `h3.geoToH3` was added
* `h3.h3ToGeo` was added
* `h3.kRing` was added
* `h3.hexRing` was added
* `h3.compact` was added
* `h3.uncompact` was added
* `h3.h3IndexesAreNeighbors` was added
* `h3.getH3UnidirectionalEdge` was added
* `h3.getOriginH3IndexFromUnidirectionalEdge` was added
* `h3.getDestinationH3IndexFromUnidirectionalEdge` was added
* `h3.h3UnidirectionalEdgeIsValid` was added
* `h3.getH3IndexesFromUnidirectionalEdge` was added
* `h3.getH3UnidirectionalEdgesFromHexagon` was added
* `h3.getH3UnidirectionalEdgeBoundary` was added
* `h3.h3Distance` was added
* `h3.h3Line` was added
* `h3.experimentalH3ToLocalIj` was added
* `h3.experimentalLocalIjToH3` was added
* `h3.pointDist` was added
* `h3.cellArea` was added
* `h3.exactEdgeLength` was added
* `h3.hexArea` was added
* `h3.edgeLength` was added
* `h3.numHexagons` was added
* `h3.getRes0Indexes` was added
* `h3.getPentagonIndexes` was added


## 0.2.1

* Fix build errors

## 0.2.0

* macOS system support was added
* Tests were added
* Documentation was added
* `h3.maxPolyfillSize` was removed
## 0.1.0

* `h3.maxPolyfillSize` was added
* `h3.polyfill` was added
* `h3.h3ToGeoBoundary` was added
* `h3.radsToDegs` was added
* `h3.degsToRads` was added
* `geojson2h3.h3ToFeature` was added
* `geojson2h3.h3SetToFeatureCollection` was added

## 0.1.0

* First version
