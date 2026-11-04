<p>
<a href="https://github.com/festelo/h3_dart/actions"><img src="https://github.com/festelo/h3_dart/actions/workflows/tests.yml/badge.svg" alt="Build & Test"></a>
<a href="https://codecov.io/gh/festelo/h3_dart"><img src="https://codecov.io/gh/festelo/h3_dart/branch/master/graph/badge.svg" alt="codecov"></a>
<a href="https://opensource.org/licenses/Apache-2.0"><img src="https://img.shields.io/badge/License-Apache_2.0-blue.svg" alt="License: Apache 2.0"></a>
</p>

## H3 Web

***In most cases you should not use this library directly, use [h3_dart](https://pub.dev/packages/h3_dart/) or [h3_flutter](https://pub.dev/packages/h3_flutter/) instead.***  

This package provides implementation of H3 abstraction from `package:h3_common` through bindings to Ubers's [h3-js](https://github.com/uber/h3-js) library written on JS.

Bindings are generated using `dart_js_facade_gen` tool.

```dart
// Get hexagons in specified triangle.
final h3 = const H3Web();
final hexagons = h3.polyfill(
  resolution: 5,
  coordinates: [
    GeoCoord(20.4522, 54.7104),
    GeoCoord(37.6173, 55.7558),
    GeoCoord(39.7015, 47.2357),
  ],
);
```  

### Setup

***In most cases you should not use this library directly, use [h3_dart](https://pub.dev/packages/h3_dart/) or [h3_flutter](https://pub.dev/packages/h3_flutter/) instead.***  

This library is built on top of `h3-js`, you have to import it.  
Add this line to your `index.html`, before the script that loads your app:
```html
    <script src="https://unpkg.com/h3-js@4.2.1"></script>
```
If you add `defer` to it, the script that loads your app must use `defer` too, so that
they run in order. Do not use `defer` with an `async` app script, such as Flutter's
`flutter_bootstrap.js`.

`H3Web.isH3JsLoaded` tells you whether h3-js is on the page. While it is `false`, every
call throws a `StateError`.

The library works with both web compilers, dart2js and dart2wasm
(`flutter build web --wasm`, `dart compile wasm`).

-------------
## For contributors:

The h3-js bindings are in `h3_web/lib/src/js/h3_js.dart`. They are written by hand with
`dart:js_interop` (the old `dart_js_facade_gen` generator is not maintained). To add an
h3-js function, add an `external` member to the `H3Js` extension type.

Run the tests with both compilers:
```bash
dart test -p chrome
dart test -p chrome -c dart2wasm
```
