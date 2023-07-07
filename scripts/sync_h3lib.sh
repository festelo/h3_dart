# This script copies H3Lib files to ios and macos directories

rm -rf h3_flutter/ios/Classes/h3lib
cp -R h3_ffi/c/h3lib h3_flutter/ios/Classes/h3lib

rm -rf h3_flutter/macos/Classes/h3lib
cp -R h3_ffi/c/h3lib h3_flutter/macos/Classes/h3lib

rm -rf h3_flutter/android/src/h3lib
cp -R h3_ffi/c/h3lib h3_flutter/android/src/h3lib

rm -rf h3_flutter/windows/include/h3lib
cp -R h3_ffi/c/h3lib h3_flutter/windows/include/h3lib

rm -rf h3_flutter/linux/include/h3lib
cp -R h3_ffi/c/h3lib h3_flutter/linux/include/h3lib