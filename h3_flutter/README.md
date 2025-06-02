<p>
<a href="https://github.com/festelo/h3_dart/actions"><img src="https://github.com/festelo/h3_dart/actions/workflows/tests.yml/badge.svg" alt="Build & Test"></a>
<a href="https://codecov.io/gh/festelo/h3_dart"><img src="https://codecov.io/gh/festelo/h3_dart/branch/master/graph/badge.svg" alt="codecov"></a>
<a href="https://opensource.org/licenses/Apache-2.0"><img src="https://img.shields.io/badge/License-Apache_2.0-blue.svg" alt="License: Apache 2.0"></a>
</p>

## H3 Flutter

The package allows to use Uber's [H3 library](https://github.com/uber/h3) directly in your Dart application

The package uses [h3_ffi](https://pub.dev/packages/h3_ffi) and [h3_web](https://pub.dev/packages/h3_web) under the hood. 

```dart
final h3Factory = const H3Factory();
final h3 = h3Factory.load();
// Get hexagons in specified triangle.
final hexagons = h3.polyfill(
  resolution: 5,
  coordinates: [
    GeoCoord(20.4522, 54.7104),
    GeoCoord(37.6173, 55.7558),
    GeoCoord(39.7015, 47.2357),
  ],
);
```  

There are also few methods ported from JS library [Geojson2H3](https://github.com/uber/geojson2h3), to access them you should instantiate Geojson2H3 class using `const Geojson2H3(h3)`. It uses [package:geojson2h3](https://pub.dev/packages/geojson2h3) internally.

## Setup
### Mobile, Desktop

Add `h3_flutter` package to `pubspec.yaml`, import it and load, no further actions required.
```dart
import 'package:h3_flutter/h3_flutter.dart';

final h3 = const H3Factory().load();
final geojson2h3 = Geojson2H3(h3);
```

### Web

Web version is built on top of `h3-js` v4.2.1, you have to import it.  
Add next line to your `index.html`:
```html
    <script defer src="https://unpkg.com/h3-js@4.2.1"></script>
```  
*Note, `main.dart.js` import should go after this line*  
  
-------------
## For contributors:

### Running iOS and Mac builds locally (not from pub)

As Xcode doesn't bundle CMake—unlike Android's NDK—it cannot build H3 source files directly, since H3 uses CMake.

This is why GitHub Actions prebuilds a static library before publishing `h3_flutter` to pub.dev, providing a smoother experience for users of this library. However, this prebuild step doesn't happen when you clone the library directly from git. 

To build the library locally for iOS/macOS development, you need to build the `xcframework` yourself by running:
```bash
bindings/scripts/build_darwin_static_lib.sh
```

### Upgrading the package to a new version of H3 library
  
As this library is built on top of `h3_web` and `h3_ffi`, you must update these packages first, please refer to their `README` files.
Once they are updated, try to run the example for all the platforms.
Ideally, it would work out of the box.
