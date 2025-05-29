<p>
<a href="https://github.com/festelo/h3_dart/actions"><img src="https://github.com/festelo/h3_dart/actions/workflows/tests.yml/badge.svg" alt="Build & Test"></a>
<a href="https://codecov.io/gh/festelo/h3_dart"><img src="https://codecov.io/gh/festelo/h3_dart/branch/master/graph/badge.svg" alt="codecov"></a>
<a href="https://opensource.org/licenses/Apache-2.0"><img src="https://img.shields.io/badge/License-Apache_2.0-blue.svg" alt="License: Apache 2.0"></a>
</p>

## Geojson2H3

The `geojson2h3` library provides a set of utilities for converting between GeoJSON polygons and H3 hexagon indexes, designed to be used alongside with [h3_dart](https://pub.dev/packages/h3_dart/) or [h3_flutter](https://pub.dev/packages/h3_flutter/).  
  
It's a Dart port of the JavaScript library [geojson2h3](https://github.com/uber/geojson2h3).

```dart
// h3_flutter example
import 'package:h3_flutter/h3_flutter.dart';

final h3Factory = const H3Factory();
final h3 = h3Factory.load();
final geojson2h3 = Geojson2H3(h3);

final hexagon = H3Index.from(0x89283082837ffff);
final hexagonFeature = geojson2h3.h3ToFeature(hexagon);
```

Currently, the library is in an early stage and supports only two methods:
```dart
geojson2h3.h3ToFeature()
geojson2h3.h3SetToFeatureCollection()
```
You can find more information about these methods in the [original geojson2h3 documentation](https://github.com/uber/geojson2h3).