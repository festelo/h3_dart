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

# Version of the bundled H3 C library, used in the iOS framework's Info.plist
H3_VERSION=$(cat "$SCRIPT_DIR/../../../h3_ffi/c/h3/VERSION" 2>/dev/null || echo "1.0.0")

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
    -DH3_VERSION="$H3_VERSION" \
    -DBUILD_SHARED_LIBS=ON
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
    -DH3_VERSION="$H3_VERSION" \
    -DBUILD_SHARED_LIBS=ON
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
# Create XCFrameworks
##########

# iOS: dynamic h3.framework, so H3 symbols stay exported even when the app
# links its pods statically (use_frameworks! :linkage => :static or no
# use_frameworks! at all).
xcodebuild -create-xcframework \
    -framework ios/install/h3.framework \
    -framework ios-simulator/install/h3.framework \
    -output h3.xcframework

# macOS: static libh3.a, force-loaded by the pod.
xcodebuild -create-xcframework \
    -library macos/install/lib/libh3.a \
    -headers macos/install/include \
    -output h3_macos.xcframework
cd ..

##########
# Copy output
##########

rm -rf ../darwin/Libs/h3.xcframework ../darwin/Libs/h3_macos.xcframework
mkdir -p ../darwin/Libs
cp -R build/h3.xcframework build/h3_macos.xcframework ../darwin/Libs/

# Clean build folder
rm -rf build

echo "✅ The XCFrameworks were built successfully: darwin/Libs/h3.xcframework, darwin/Libs/h3_macos.xcframework"