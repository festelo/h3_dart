#!/bin/bash

# Generates h3api.h for the Swift Package Manager target in
# darwin/h3_flutter from h3api.h.in of the bundled H3 sources.
# Run it after updating the H3 submodule.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

VERSION_FILE="../../h3_ffi/c/h3/VERSION"
TEMPLATE="h3lib/include/h3api.h.in"
OUTPUT="../darwin/h3_flutter/Sources/h3_flutter/include/h3api.h"

VERSION="$(tr -d '[:space:]' < "$VERSION_FILE")"
IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"

mkdir -p "$(dirname "$OUTPUT")"
sed \
    -e "s/@H3_VERSION_MAJOR@/$MAJOR/" \
    -e "s/@H3_VERSION_MINOR@/$MINOR/" \
    -e "s/@H3_VERSION_PATCH@/$PATCH/" \
    "$TEMPLATE" > "$OUTPUT"

echo "Generated $OUTPUT for H3 $VERSION"
