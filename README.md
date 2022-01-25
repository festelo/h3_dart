## H3 FLUTTER

H3 version: 3.7.2

Library uses C-written H3 library almost without changes.  
Works via [FFI](https://pub.dev/packages/ffi) and bindings are automatically generated using [ffigen](https://pub.dev/packages/ffige)
## Setup

Just add the package to `pubspec.yaml` and that's all.
  
-------------
  
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

Generate `h3api.h` file and copy it to the ios folder (we use `ios` folder for both OS - Android and iOS):
```
cmake ..
rm -rf ../../../ios/Classes/h3lib // recreate the folder to remove old h3 files
mkdir ../../../ios/Classes/h3lib

cp src/h3lib/include/h3api.h ../../../ios/Classes/h3lib
```

Copy other source files (*.h and *.c) to the folder.
```
cd ..
tmp/h3_sources/src/h3lib/include
cp src/h3lib/include/* ../../ios/Classes/h3lib
cp src/h3lib/lib/* ../../ios/Classes/h3lib
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