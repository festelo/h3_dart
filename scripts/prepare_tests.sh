#!/bin/bash

set -e  # Exit on any error

cd "$(cd "$(dirname "$0")" > /dev/null && pwd)/../h3_ffi"

# Build H3 library first
echo "Building H3 library..."
./build_h3.sh

# Array of library files to check in order
libraries=(
    "c/h3/build/lib/libh3.dylib"
    "c/h3/build/lib/libh3.so"
    "c/h3/build/bin/libh3.dll"
)

# Target destination
target="c/h3/build/test.common"

# Check each library file in order
for lib in "${libraries[@]}"; do
    if [ -f "$lib" ]; then
        echo "Found $lib, copying to $target"
        cp "$lib" "$target"
        echo "Successfully copied $lib to $target"
        exit 0
    fi
done

# If we get here, none of the libraries were found
echo "Error: None of the H3 libraries were found:"
for lib in "${libraries[@]}"; do
    echo "  - $lib"
done
exit 1 