cd "$(cd "$(dirname "$0")" > /dev/null && pwd)/.."

git submodule init
git submodule update

h3_flutter/bindings/scripts/build_darwin_static_lib.sh