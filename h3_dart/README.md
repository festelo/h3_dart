<p>
<a href="https://github.com/festelo/h3_dart/actions"><img src="https://github.com/festelo/h3_dart/actions/workflows/tests.yml/badge.svg" alt="Build & Test"></a>
<a href="https://codecov.io/gh/festelo/h3_dart"><img src="https://codecov.io/gh/festelo/h3_dart/branch/master/graph/badge.svg" alt="codecov"></a>
<a href="https://opensource.org/licenses/Apache-2.0"><img src="https://img.shields.io/badge/License-Apache_2.0-blue.svg" alt="License: Apache 2.0"></a>
</p>

## H3 Dart

***If you're developing Flutter application, use should use [h3_flutter](https://pub.dev/packages/h3_flutter/) instead.***  

The package allows to use Uber's [H3 library](https://github.com/uber/h3) directly in your Dart application

The package uses [h3_ffi](https://pub.dev/packages/h3_ffi) and [h3_web](https://pub.dev/packages/h3_web) under the hood. 

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

***If you're developing Flutter application, use should use [h3_flutter](https://pub.dev/packages/h3_flutter/) instead.***  

### VM

Get compiled h3 c library, depending on your platform it may have extension .so, .dll or any.

- You can run `scripts/build_h3.sh` script, the compiled library will be at `h3_ffi/c/h3lib/build/h3.so`

- You can compile it by yourself using C-code placed in `c` folder in this repository. It has small changes comparing to original Uber's code to make it more compatible with iOS and macOS versions of `h3_flutter`. This code is recompiled and used for testing everytime tests are launched, so it should work well.

- You can compile original Uber's code, which also should work well, just make sure you use correct version - https://github.com/uber/h3

Place your library somewhere and load it using `final h3 = const H3Factory().byPath('path/to/library.dll');`

### Web

Web version is built on top of `h3-js`, you have to import it.  
Add next line to your `index.html`:
```html
    <script defer src="https://unpkg.com/h3-js@3.7.2"></script>
```  
*Note, `main.dart.js` import should go after this line*  

You can load the web version using `final h3 = const H3Factory().web();`