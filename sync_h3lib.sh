# This script copies H3Lib files to ios and macos directories

rm -rf ios/Classes/h3lib
cp -R c/h3lib ios/Classes/h3lib

rm -rf macos/Classes/h3lib
cp -R c/h3lib macos/Classes/h3lib