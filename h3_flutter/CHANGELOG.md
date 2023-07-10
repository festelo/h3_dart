## 0.6.6
* Fix Android release build

## 0.6.5
* Flutter for Linux support

## 0.6.4
* Flutter for Windows support
* Rename `libh3lib.lib` file to `h3.so`

## 0.6.3
* Add `holes` param to `H3.polyfill` function (thanks [@iulian0512](https://github.com/iulian0512))
* Fix web setup readme.
* Fix web example
* Fix web test
* Fix android build (thanks [@rtviwe](https://github.com/iulian0512))
* Update dependencies (incl. `h3_web`, `h3_ffi`, `h3_common`, `geojson2h3` v6.0.1 and others)
* Fix android test setup (github actions)
* Temporary disable macos test (github actions)

## 0.6.2
* Fix Android build
* Add Android tests
* Remove C files from GitHub stats

## 0.6.1
* Fix Android build

## 0.6.0
* Split `h3_dart` library into 5 libraries - `h3_dart`, `h3_ffi`, `h3_web`, `h3_common`, `geojson2h3`
* Use `BigInt` instead of `int` for h3 indexes due to `web` specific.
* Web support added to `h3_dart` and `h3_flutter`
## 0.5.2
* Update README.md and tests
## 0.5.1
* Update README.md

## 0.5.0
* Split `h3_flutter` library into 2 libraries - `h3_flutter` and `h3_dart` for pure-dart projects.
* **[BREAKING]** remove `h3` and `geojson2H3` singletones.  
  To access h3 you should use `H3Factory().load()` if you use `h3_flutter` and `H3Factory().byPath(...)` or `H3Factory().byDynamicLibary(...)` if you use `h3_dart`
* Add `GeoCoordRadians` to allow to specify coordinates in radians.  
  `GeoCoordRadians` must be converted to `GeoCoord` using `.toDegrees(converter)` method before you can use it in h3 or geojson2h3 methods.
* Add option to convert `GeoCoord` to `GeoCoordRadians` via `.toRadians(converter)` method
* Add AngleConverter and GeoCoordConverter classes to convert between radians and degrees.  
  AngleConverter is abstract, but has two implementations - H3AngleConverter and NativeAngleConverter
* Add tests on windows, linux, flutter stable and dev.
* Add integration tests for `h3_flutter` built for macos
* CI/CD improvements - more checks, automatic publishing

## 0.4.2
* Fix `CoordIJ.toString()` output
* Change `CoordIJ.hashCode`to generate more unique hashcode
* Fix `GeoCoord.toString()` output
* Change `GeoCoord.hashCode`to generate more unique hashcode
* Add world-wrapping feature to `GeoCoord()` constructor
* `geojson2h3.h3ToFeature` and `geojson2h3.h3SetToFeatureCollection` now adds `'properties': {}` to output when properties not set. To make the behaviour closer to JS version of the library
* Change type for `properties` parameter in `geojson2h3.h3SetToFeatureCollection` function. Now it accepts Function() instead of Map
* Rename `h3_flutter_test.dart` to `h3_test.dart`
* Add tests for following methods:
```
geojson2h3.h3ToFeature
geojson2h3.h3SetToFeatureCollection
CoordIJ.==
CoordIJ.hashCode
CoordIJ.toString
GeoCoord.==
GeoCoord.hashCode
GeoCoord.toString
GeoCoord() (World-Wrapping)
H3Exception.toString
```

## 0.4.1
* Fix `h3.getH3UnidirectionalEdgesFromHexagon` method - now it returns 5 elements for pentagon.
* Fix `h3.h3Line` method - now it throws `H3Exception` instead of some internal when input is not valid.
* Update README.md.
* Update documentation for methods `h3.h3ToParent`, `h3.h3ToCenterChild`, `h3.getH3UnidirectionalEdge`, `h3.getOriginH3IndexFromUnidirectionalEdge`, `h3.getDestinationH3IndexFromUnidirectionalEdge`, `h3.h3Distance`.
* Add tests for following methods:
```
h3.h3IndexesAreNeighbors
h3.getH3UnidirectionalEdge
h3.getOriginH3IndexFromUnidirectionalEdge
h3.getDestinationH3IndexFromUnidirectionalEdge
h3.h3UnidirectionalEdgeIsValid
h3.getH3UnidirectionalEdgesFromHexagon
h3.getH3UnidirectionalEdgeBoundary
h3.h3Distance
h3.h3Line
h3.experimentalH3ToLocalIj
h3.experimentalLocalIjToH3
h3.hexArea
h3.edgeLength
h3.cellArea
h3.pointDist
h3.numHexagons
h3.getRes0Indexes
h3.getPentagonIndexes
```

## 0.4.0
* **[BREAKING]** Change return types for `h3.h3IsPentagon` and h3IsResClassIII methods from [int] to [bool]
* Fix broken `h3.h3GetFaces` method
* Add `h3.h3ToParent` and `h3.h3ToChildren` methods
* Add tests for following methods:
```
h3.h3IsPentagon
h3.h3IsResClassIII
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
