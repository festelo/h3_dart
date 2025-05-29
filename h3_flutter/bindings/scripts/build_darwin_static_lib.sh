#!/bin/bash

set -euo pipefail

# Absolute path to script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

# Clean build dir
rm -rf build
mkdir build
cd build

# Number of cores for parallel build
NUM_CORES=$(sysctl -n hw.ncpu)

##########
# iOS
##########

mkdir ios
cd ios
cmake ../.. \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DCMAKE_OSX_SYSROOT=$(xcodebuild -version -sdk iphoneos Path) \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 \
    -DCMAKE_INSTALL_PREFIX=$(pwd)/install \
    -DBUILD_SHARED_LIBS=OFF
make -j"$NUM_CORES"
make install
cd ..

##########
# iOS Simulator
##########

mkdir ios-simulator
cd ios-simulator
cmake ../.. \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64" \
    -DCMAKE_OSX_SYSROOT=$(xcodebuild -version -sdk iphonesimulator Path) \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 \
    -DCMAKE_INSTALL_PREFIX=$(pwd)/install \
    -DBUILD_SHARED_LIBS=OFF
make -j"$NUM_CORES"
make install
cd ..

##########
# macOS
##########

mkdir macos
cd macos
cmake ../.. \
    -DCMAKE_SYSTEM_NAME=Darwin \
    -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64" \
    -DCMAKE_OSX_SYSROOT=$(xcodebuild -version -sdk macosx Path) \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.13 \
    -DCMAKE_INSTALL_PREFIX=$(pwd)/install \
    -DBUILD_SHARED_LIBS=OFF
make -j"$NUM_CORES"
make install
cd ..

##########
# Create XCFramework
##########

xcodebuild -create-xcframework \
    -library ios/install/lib/libh3.a \
    -headers ios/install/include \
    -library ios-simulator/install/lib/libh3.a \
    -headers ios-simulator/install/include \
    -library macos/install/lib/libh3.a \
    -headers macos/install/include \
    -output h3.xcframework
cd ..

##########
# Copy output
##########

rm -rf ../darwin/Libs/h3.xcframework
mkdir -p ../darwin/Libs
cp -r build/h3.xcframework ../darwin/Libs/

# Clean build folder
rm -rf build

echo "✅ The XCFramework was built successfully: darwin/Libs/h3.xcframework"