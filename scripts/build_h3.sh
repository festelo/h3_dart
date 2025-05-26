cd "$(cd "$(dirname "$0")" > /dev/null && pwd)/.."

git submodule init
git submodule update

rm -rf h3_ffi/c/h3/build 
mkdir h3_ffi/c/h3/build
cd h3_ffi/c/h3/build
cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -G "Unix Makefiles" 
make