<p>
<a href="https://github.com/festelo/h3_dart/actions"><img src="https://github.com/festelo/h3_dart/actions/workflows/tests.yml/badge.svg" alt="Build & Test"></a>
<a href="https://codecov.io/gh/festelo/h3_dart"><img src="https://codecov.io/gh/festelo/h3_dart/branch/master/graph/badge.svg" alt="codecov"></a>
<a href="https://opensource.org/licenses/Apache-2.0"><img src="https://img.shields.io/badge/License-Apache_2.0-blue.svg" alt="License: Apache 2.0"></a>
</p>

## H3 Flutter

Cross‑platform Flutter plugin for Uber's [H3](https://github.com/uber/h3) library.
Internally it delegates to [h3_ffi](https://pub.dev/packages/h3_ffi) on the VM and to [h3_web](https://pub.dev/packages/h3_web) on the web. 

```dart
final h3Factory = const H3Factory();
final h3 = await h3Factory.load();
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

There are also a few methods ported from the JS library [Geojson2H3](https://github.com/uber/geojson2h3). To access them, instantiate the `Geojson2H3` class using `const Geojson2H3(h3)`. It uses [package:geojson2h3](https://pub.dev/packages/geojson2h3) internally.

## Setup
### Mobile, Desktop

Add `h3_flutter` package to `pubspec.yaml`, import it, and load, no further actions required.
```dart
import 'package:h3_flutter/h3_flutter.dart';

final h3 = const H3Factory().load();
final geojson2h3 = Geojson2H3(h3);
```

### Web

Web version is built on top of `h3-js` v4.5.0. `load()` adds h3-js to the page if it is
not there yet, so `web/index.html` needs no changes. Await it before the first H3 call:
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final h3 = await const H3Factory().load();
  runApp(MyApp(h3: h3));
}
```

`load()` returns a `FutureOr<H3>`: on mobile and desktop, and on Web when h3-js is already
on the page, the value is available immediately. Pass `libraryUrl` to load h3-js from
another location, for example your own server.

If you prefer a `<script>` tag, add h3-js to `web/index.html` **before** the
`flutter_bootstrap.js` script:
```html
<script src="https://unpkg.com/h3-js@4.5.0"></script>
<script src="flutter_bootstrap.js" async></script>
```

Do not add `defer` or `async` to the h3-js script. Flutter loads `flutter_bootstrap.js`
with `async`, which can run before a `defer` script, most often when the page is loaded
from the browser cache. Your app then starts before h3-js is loaded.

Both web compilers are supported: `flutter build web` (JavaScript) and
`flutter build web --wasm` (WebAssembly).

-------------
## For contributors

### Running iOS and Mac builds locally (not from pub)

With Swift Package Manager (enabled by default in Flutter), the package in `darwin/h3_flutter` compiles the H3 sources directly, no extra steps are needed.

The CocoaPods integration links a prebuilt static library instead: Xcode doesn't bundle CMake—unlike Android's NDK—so it cannot build H3 source files directly, since H3 uses CMake. GitHub Actions prebuilds this library before publishing `h3_flutter` to pub.dev, but this prebuild step doesn't happen when you clone the library directly from git.

To build the library locally for iOS/macOS development with CocoaPods, you need to build the `xcframework` yourself by running:
```bash
bindings/scripts/build_darwin_static_lib.sh
```

### Upgrading the package to a new version of H3 library
  
As this library is built on top of `h3_web` and `h3_ffi`, you must update these packages first, please refer to their `README` files.
Then regenerate `h3api.h` for the Swift Package Manager target:
```bash
bindings/scripts/generate_darwin_h3api.sh
```
Once they are updated, try to run the example for all the platforms.
Ideally, it would work out of the box.
