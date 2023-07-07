<p>
<a href="https://github.com/festelo/h3_dart/actions"><img src="https://github.com/festelo/h3_dart/actions/workflows/tests.yml/badge.svg" alt="Build & Test"></a>
<a href="https://codecov.io/gh/festelo/h3_dart"><img src="https://codecov.io/gh/festelo/h3_dart/branch/master/graph/badge.svg" alt="codecov"></a>
<a href="https://opensource.org/licenses/Apache-2.0"><img src="https://img.shields.io/badge/License-Apache_2.0-blue.svg" alt="License: Apache 2.0"></a>
</p>

## H3 Ffi

***In most cases you should not use this library directly, use [h3_dart](https://pub.dev/packages/h3_dart/) or [h3_flutter](https://pub.dev/packages/h3_flutter/) instead.***  

H3 C library version: 3.7.2

The package allows to use [H3 library](https://github.com/uber/h3) directly in your Dart VM application

The package uses C version under the hood. 
Works via [FFI](https://pub.dev/packages/ffi), bindings are automatically generated using [ffigen](https://pub.dev/packages/ffige)

```dart
// Get hexagons in specified triangle.
final h3 = const H3FfiFactory().byPath('../h3.so');
final hexagons = h3.polyfill(
  resolution: 5,
  coordinates: [
    GeoCoord(20.4522, 54.7104),
    GeoCoord(37.6173, 55.7558),
    GeoCoord(39.7015, 47.2357),
  ],
);
```  

Most of C's `H3` functions are available in `H3` class, which you can get using `H3Factory`. But if you can't find method you need, you can call C function directly, althrough it's more complicated, because you'll need to work directly with FFI (you will need to worry about allocation and native types). If you want to try, you can use `H3CFactory` to get access to `H3C` instance (import 'package:h3_ffi/internal.dart').

### Setup

***In most cases you should not use this library directly, use [h3_dart](https://pub.dev/packages/h3_dart/) or [h3_flutter](https://pub.dev/packages/h3_flutter/) instead.***  
***If you use [h3_flutter](https://pub.dev/packages/h3_flutter/) you don't need to have compiled H3 C library, it will be built automatically***


Add `h3_ffi` package to `pubspec.yaml`.

Get compiled h3 library, depending on your platform it may have extension .so, .dll or any.

- You can run `scripts/build_h3.sh` script, the compiled library will be at `h3_ffi/c/h3lib/build/h3.so` (or `h3.dll` for Windows)

- You can compile it by yourself using C-code placed in `c` folder in this repository. It has small changes comparing to original Uber's code to make it more compatible with iOS and macOS versions of `h3_flutter`. This code is recompiled and used for testing everytime tests are launched, so it should work well.

- You can compile original Uber's code, which also should work well, just make sure you use correct version - https://github.com/uber/h3

Place your library somewhere and load it using `H3FfiFactory().byPath('path/to/library.dll')`:
  
-------------
## For contributors:

### Tests

To make tests work you need to execute `scripts/prepare_tests.sh` script. This script builds h3 library from C code.  
The script works well under macOS, Linux and Windows (bash required).  
  
### Upgrading the package to be compatible with new Uber's H3 library

\~Good luck\~
  

You need cmake tool, if you're on macos use next command to install it:
```
brew install cmake # install cmake
```

Clone h3 repository and create work folders:
```
git clone https://github.com/uber/h3 tmp/h3_sources 
# git checkout ... - checkout on commit you need, currently stable versions are in stable-3.x branch
mkdir tmp/h3_sources/build
cd tmp/h3_sources/build
```

Generate `h3api.h` file and copy it to `c/h3lib` folder:
```
cmake ..
rm -rf ../../../c/h3lib // recreate the folder to remove old h3 files
mkdir ../../../c/h3lib

cp src/h3lib/include/h3api.h ../../../c/h3lib
```

Copy other source files (*.h and *.c) to the folder.
```
cd ..
cp src/h3lib/include/* ../../c/h3lib
cp src/h3lib/lib/* ../../c/h3lib
```

Copy c/h3lib folder to ios and macos folders with `scripts/sync_h3lib.sh` script:
```
sh scripts/sync_h3lib.sh
```

You need to add .h and .c files to the project using XCode if you want to launch example (for iOS and macOS).  
You can face some build errors, in my case i just followed xcode instructions to solve them.  

Code generation tool called [ffigen](https://pub.dev/packages/ffige) is used to create C-to-Dart bindings.  
To run it, you need to install LLVM:
```
brew install llvm
```

All H3 public functions should be specified in ffigen.yaml file
Run `flutter pub run ffigen --config ffigen.yaml` to generate bindings