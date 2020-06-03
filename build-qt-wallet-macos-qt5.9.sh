#!/bin/sh

NUMBER_GLOBAL=`cat ./version.txt`

export MACOSX_DEPLOYMENT_TARGET=10.8

if [ $# -eq 0 ]
then
    echo "not signing"
else
    echo "building with signing and notary";
fi

# Clean everything. This is a release build so we can wait
rm -rf mwc713 mwc-node mwc-qt-wallet target/*
mkdir -p target

# Build mwc-node
git clone https://github.com/mwcproject/mwc-node
cd mwc-node
TAG_FOR_BUILD_FILE=../mwc-node.version
if [ -f "$TAG_FOR_BUILD_FILE" ]; then
    git fetch && git fetch --tags;
    git checkout `cat $TAG_FOR_BUILD_FILE`;
fi
./build_static.sh

FILE=target/release/mwc
if [ ! -f "$FILE" ]; then
    echo "ERROR: $FILE does not exist";
    exit 1;
fi

cd ..

# First build mwc713 statically
git clone https://github.com/mwcproject/mwc713
cd mwc713
TAG_FOR_BUILD_FILE=../mwc713.version
if [ -f "$TAG_FOR_BUILD_FILE" ]; then
    git fetch && git fetch --tags;
    git checkout `cat $TAG_FOR_BUILD_FILE`;
fi
./build_static.sh 
cd ..

# Second build mwc-qt-wallet

# prepare for QT fix
export QT_INSTALL_PATH="$HOME/Qt"
echo "QT_INSTALL_PATH=$QT_INSTALL_PATH"

git clone https://github.com/mwcproject/mwc-qt-wallet
cp fix_macos_makefile.sh mwc-qt-wallet
cd mwc-qt-wallet
# git checkout  2019_09_cold_wallet
TAG_FOR_BUILD_FILE=../mwc-qt-wallet.version
if [ -f "$TAG_FOR_BUILD_FILE" ]; then
    git fetch && git fetch --tags;
    git checkout `cat $TAG_FOR_BUILD_FILE`;
    echo "#define BUILD_VERSION  \"`cat $TAG_FOR_BUILD_FILE`\"" > build_version.h
else
    echo "#define BUILD_VERSION  \"1.0-$NUMBER_GLOBAL.beta-1\"" > build_version.h
fi
~/Qt/5.9/clang_64/bin/qmake mwc-qt-wallet.pro -spec macx-clang CONFIG+=x86_64
./fix_macos_makefile.sh
make -j 16

# Finally prep dmg
cp ../mwc-node/target/release/mwc mwc-qt-wallet.app/Contents/MacOS/mwc
cp ../mwc713/target/release/mwc713 mwc-qt-wallet.app/Contents/MacOS/mwc713
cp ../mwc713/target/release/mwczip mwc-qt-wallet.app/Contents/MacOS/mwczip
~/Qt/5.9/clang_64/bin/macdeployqt mwc-qt-wallet.app -appstore-compliant

if [ $# -eq 0 ]
then
   # We can't sign so just build dmg
   hdiutil create ../target/mwc-qt-wallet.dmg -fs HFS+ -srcfolder mwc-qt-wallet.app -format UDZO -volname mwc-qt-wallet
   echo "Complete!";
else
   # Sign
   codesign --force --options runtime --sign 'Developer ID Application: Christopher Gilliard (D6WGXN9XBM)' --deep mwc-qt-wallet.app
   # Building the disk image for the app folder
   hdiutil create ../target/mwc-qt-wallet.dmg -fs HFS+ -srcfolder mwc-qt-wallet.app -format UDZO -volname mwc-qt-wallet

   echo "Your diskimage is created. Now we need to sign it..."
   # signing resulting package
   codesign --sign 'Developer ID Application: Christopher Gilliard (D6WGXN9XBM)' ../target/mwc-qt-wallet.dmg

   # now notarize the app
   echo "Notarizing this will take a while..."

   rm -rf /tmp/notarize_out.log;
   xcrun altool --notarize-app -f ../target/mwc-qt-wallet.dmg --primary-bundle-id com.yourcompany.mwc-qt-wallet -u mimblewimblecoin2@protonmail.com -p $1
   echo "Sleeping for 2 minutes to let apple process things."
   sleep 120;
   xcrun stapler staple -q -v ../target/mwc-qt-wallet.dmg

   echo "Check your resulting image at target/mwc-qt-wallet.dmg. Check contents at mwc-qt-wallet/mwc-qt-wallet.app"
   echo "To do this, open the dmg, and drag the app into the /Applications folder"
   echo "Then run this command: spctl -a -v /Applications/mwc-qt-wallet.app"
   echo "You should see a message like this: source=Notarized Developer ID"
   echo "Note you must be on MacOSX10.14+"
fi

