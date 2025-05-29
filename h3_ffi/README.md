<p>
<a href="https://github.com/festelo/h3_dart/actions"><img src="https://github.com/festelo/h3_dart/actions/workflows/tests.yml/badge.svg" alt="Build & Test"></a>
<a href="https://codecov.io/gh/festelo/h3_dart"><img src="https://codecov.io/gh/festelo/h3_dart/branch/master/graph/badge.svg" alt="codecov"></a>
<a href="https://opensource.org/licenses/Apache-2.0"><img src="https://img.shields.io/badge/License-Apache_2.0-blue.svg" alt="License: Apache 2.0"></a>
</p>

## H3 Ffi

***In most cases, you should not use this library directly, use [h3_dart](https://pub.dev/packages/h3_dart/) or [h3_flutter](https://pub.dev/packages/h3_flutter/) instead.***  

H3 C library version: **4.2.1**

This package allows you to use the [H3 library](https://github.com/uber/h3) directly in your Dart VM application. It wraps the native C implementation under the hood using [FFI](https://pub.dev/packages/ffi), with bindings automatically generated via [ffigen](https://pub.dev/packages/ffige).

```dart
// Get hexagons within the specified triangle.
final h3 = const H3FfiFactory().byPath('../h3.so');
final hexagons = h3.polygonToCells(
  resolution: 5,
  coordinates: [
    GeoCoord(20.4522, 54.7104),
    GeoCoord(37.6173, 55.7558),
    GeoCoord(39.7015, 47.2357),
  ],
);
```  

If, for some reason, the wrapper around the C library doesn't work for you, you can use the C library directly via FFI. `H3CFactory` (import 'package:h3_ffi/internal.dart') is provided to make it more convenient. However, in the vast majority of cases this is not needed.

### Setup

***In most cases, you should not use this library directly, use [h3_dart](https://pub.dev/packages/h3_dart/) or [h3_flutter](https://pub.dev/packages/h3_flutter/) instead.***  
***If you use [h3_flutter](https://pub.dev/packages/h3_flutter/) you don't need to build the native library yourself***


1. Add `h3_ffi` package to `pubspec.yaml`.

2. Compile the H3 library for your platform. Depending on your platform, it usually has the extension `.so` (Linux), `.dll` (Windows) or `.dylib` (macOS).  

   The most convenient way to do this is by using the `build_h3.sh` script from the repository.  
   Clone it, then run `sh scripts/build_h3.sh`.  
   Once the build is done, you'll find the library at `h3_ffi/c/h3/build/lib/`

3. Load the binary: `H3FfiFactory().byPath('path/to/library.dll')`:
  
-------------
## For contributors:

### Tests

To make tests work, please run `build_h3.sh` script first.
  
### Upgrading the package to a new version of H3 library

\~Good luck\~

#### Insturctions are written for macOS, on other systems the process may differ

You need cmake tool, install if you don't have it:
```
brew install cmake # install cmake
```

Switch [uber/h3](https://github.com/uber/h3) submodule to the wanted version:

```
# pwd: h3_ffi/
cd c/h3
git checkout <version>
```

Build the library:
```
sh ../scripts/build_h3.sh
```

Code generation tool called [ffigen](https://pub.dev/packages/ffige) is used to create C-to-Dart bindings.  
To use it, you need to have LLVM installed:
```
brew install llvm
```

Run `dart run ffigen --config ffigen.yaml` to generate the bindings

Adapt [h3_ffi.dart](src/h3_ffi.dart) to the new changes. If necessary, apply changes to other packages in this repository. 

Make sure all tests work succesfully. 

Proceed to updating `h3_flutter` package.
