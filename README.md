## H3 FLUTTER

H3 version: 3.7.2

The package allows to use [H3 library](https://github.com/uber/h3) directly in your Flutter application

The package uses C version under the hood. 
Works via [FFI](https://pub.dev/packages/ffi), bindings are automatically generated using [ffigen](https://pub.dev/packages/ffige)

Few functions were adopted to allow work with them in a "safe" mode:
```
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

But most of them are not. You still can use them, but it's more complicated, because you'll need to work directly with FFI (`calloc`, `malloc` and everything). If you want to try, you can use `h3c` singletone.

The package also contains few methods from JS library [Geojson2H3](https://github.com/uber/geojson2h3).
## Setup

Just add the package to `pubspec.yaml` and that's all.
  
-------------
## Tests

To make tests work you need to execute `prepare_tests.sh` script. The script builds h3 library from C code.  
The script is designed for macOS and therefore it probably work only under this system.  
  
## How to update the package to match latest H3 version

\~Good luck\~
  

You need cmake tool, if you're on macos use next command:
```
brew install cmake # install cmake
```

Clone h3 repository and prepare everything:
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
tmp/h3_sources/src/h3lib/include
cp src/h3lib/include/* ../../c/h3lib
cp src/h3lib/lib/* ../../c/h3lib
```

You need to add .h and .c files to the project using XCode if you want to launch example (iOS).  
Then, probably you will face some build errors, in my case i just followed xcode instructions to solve them.  

Code generation tool called [ffigen](https://pub.dev/packages/ffige) is used to create C-to-Dart bindings.  
To run it, you need to install LLVM:
```
brew install llvm
```
If you're using M1 Mac, as of now, you need to install x86 version of LLVM, to do it you need to install x86 version of Homebrew.

All H3 public functions should be specified in ffigen.yaml file
Run `flutter pub run ffigen --config ffigen.yaml` to generate bindings