#!/bin/bash

set -e  # Exit on any error

cd "$(cd "$(dirname "$0")" > /dev/null && pwd)/.."

rm -rf h3_ffi/c/h3/build 
mkdir h3_ffi/c/h3/build
cd h3_ffi/c/h3/build
cmake .. -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON \
  -DBUILD_TESTING=OFF \
  -DCMAKE_LIBRARY_OUTPUT_DIRECTORY=lib
make