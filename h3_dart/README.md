<p>
<a href="https://github.com/festelo/h3_dart/actions"><img src="https://github.com/festelo/h3_dart/actions/workflows/tests.yml/badge.svg" alt="Build & Test"></a>
<a href="https://codecov.io/gh/festelo/h3_dart"><img src="https://codecov.io/gh/festelo/h3_dart/branch/master/graph/badge.svg" alt="codecov"></a>
<a href="https://opensource.org/licenses/Apache-2.0"><img src="https://img.shields.io/badge/License-Apache_2.0-blue.svg" alt="License: Apache 2.0"></a>
</p>

## H3 Dart

***If you are building a Flutter app use [h3_flutter](https://pub.dev/packages/h3_flutter/) instead.***

A platform neutral wrapper around Uber's [H3](https://github.com/uber/h3) library.
Internally it delegates to [h3_ffi](https://pub.dev/packages/h3_ffi) on the VM and to [h3_web](https://pub.dev/packages/h3_web) on the web.

```dart
final h3Factory = const H3Factory();
const kIsWeb = identical(0, 0.0); // taken from https://api.flutter.dev/flutter/foundation/kIsWeb-constant.html
final h3 = kIsWeb 
  ? h3Factory.web() 
  : h3Factory.byPath('path/to/library.dll');
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

***If you are building a Flutter app use [h3_flutter](https://pub.dev/packages/h3_flutter/) instead.***  

### VM

1. Build the native library using `scripts/build_h3.sh` or compile the C source manually.
   The `h3_ffi/c` directory has a git submodule pointing to the original H3 repository, pinned to the correct version.

2. Load the compiled binary with `H3Factory().byPath()`:
   ```dart
   final h3 = const H3Factory().byPath('path/to/library.dll')
   ```

### Web

1. Include `h3-js` in your `index.html`:
   ```html
   <script defer src="https://unpkg.com/h3-js@4.2.1"></script>
   ```  
   *Note, `main.dart.js` import should go after this line*  

2. Load the web implementation: 
   ```dart
   final h3 = const H3Factory().web();
   ```