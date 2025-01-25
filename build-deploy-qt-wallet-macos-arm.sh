#!/bin/sh

set -e
#set -x

# It is expected that this script will be run manually at the Mac with Apple Silicone CPU.

# Note, expected that QT version 6.2.4 is used. Search for '6.2.4' below
export QT_INSTALL_PATH="/Users/bay/Qt/"

echo "Starting build-qt-wallet-macos-arm.sh with QT location: $QT_INSTALL_PATH"
export MACOSX_DEPLOYMENT_TARGET=10.12
. ~/.cargo/env

# Clean everything. This is a release build so we can wait
rm -rf mwc713 mwc-node mwc-qt-wallet target/*
mkdir -p target

# Build mwc-node
while true; do
  git clone https://github.com/mwcproject/mwc-node.git && break
done
cd mwc-node
TAG_FOR_BUILD_FILE=../mwc-node.version
if [ -f "$TAG_FOR_BUILD_FILE" ]; then
    git fetch && git fetch --tags;
    git checkout `cat $TAG_FOR_BUILD_FILE`;
else
    echo "ERROR: mwc-node.version not found"
    exit 1;
fi
./build_static.sh

FILE=target/release/mwc
if [ ! -f "$FILE" ]; then
    echo "ERROR: $FILE does not exist";
    exit 1;
fi

cd ..

# build mwc713 statically
while true; do
  git clone https://github.com/mwcproject/mwc713.git && break
done
cd mwc713
TAG_FOR_BUILD_FILE=../mwc713.version
if [ -f "$TAG_FOR_BUILD_FILE" ]; then
    git fetch && git fetch --tags;
    git checkout `cat $TAG_FOR_BUILD_FILE`;
else
    echo "ERROR: mwc-node.version not found"
    exit 1;
fi
./build_static.sh

FILE=target/release/mwc713
if [ ! -f "$FILE" ]; then
    echo "ERROR: $FILE does not exist";
    exit 1;
fi

FILE=target/release/mwczip
if [ ! -f "$FILE" ]; then
    echo "ERROR: $FILE does not exist";
    exit 1;
fi

cd ..

# Second build mwc-qt-wallet
while true; do
  git clone https://github.com/mwcproject/mwc-qt-wallet.git && break
done
cd mwc-qt-wallet
TAG_FOR_BUILD_FILE=../mwc-qt-wallet.version
if [ -f "$TAG_FOR_BUILD_FILE" ]; then
    git fetch && git fetch --tags;
    git checkout `cat $TAG_FOR_BUILD_FILE`;
    echo "#define BUILD_VERSION  \"`cat $TAG_FOR_BUILD_FILE`\"" > build_version.h
else
    echo "ERROR: mwc-qt-wallet.version not found"
    exit 1;
fi

echo "Here is what we have at build_version.h"
cat build_version.h

$QT_INSTALL_PATH/6.2.4/macos/bin/qmake mwc-wallet-desktop.pro -spec macx-clang CONFIG+=arm64
make -j10

# Finally prep dmg
cp ../mwc-node/target/release/mwc mwc-qt-wallet.app/Contents/MacOS/mwc
cp ../mwc713/target/release/mwc713 mwc-qt-wallet.app/Contents/MacOS/mwc713
cp ../mwc713/target/release/mwczip mwc-qt-wallet.app/Contents/MacOS/mwczip
cp -a ../resources/macOs-arm64/* mwc-qt-wallet.app/Contents/MacOS/

$QT_INSTALL_PATH/6.2.4/macos/bin/macdeployqt mwc-qt-wallet.app -appstore-compliant -verbose=2
echo "deployqt complete"

echo "not signing just building dmg"
# We can't sign, just build dmg
hdiutil create ../target/mwc-qt-wallet.dmg -fs HFS+ -srcfolder mwc-qt-wallet.app -format UDZO -volname mwc-qt-wallet;
resulting_path=$(realpath "../target/mwc-qt-wallet.dmg")
echo "Complete!  Resulting file: $resulting_path";
echo "After please clean up:  rm -rf mwc713 mwc-node mwc-qt-wallet target/*"
