# This script copies H3Lib files to ios and macos directories

rm -rf ios/Classes/h3lib
cp -R c/h3lib h3_flutter/ios/Classes/h3lib

rm -rf macos/Classes/h3lib
cp -R c/h3lib h3_flutter/macos/Classes/h3lib