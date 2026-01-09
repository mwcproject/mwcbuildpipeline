#!/bin/sh

set -e
set -x

# It is expected that this script will be run manually at the Mac with Apple Silicone CPU.

# Note, expected that QT version 6.2.4 is used. Search for '6.2.4' below
export QT_INSTALL_PATH="/Users/bay/Qt/"

echo "Starting build-qt-wallet-macos-arm.sh with QT location: $QT_INSTALL_PATH"
export MACOSX_DEPLOYMENT_TARGET=10.12
. ~/.cargo/env

# Clean everything. This is a release build so we can wait
rm -rf mwc-wallet webtunnel mwc-qt-wallet target/*
mkdir -p target

# Building webtunnel client
for attempt in 1 2 3 4 5; do
  if git clone https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/webtunnel; then
     break
  fi
  echo "webtunnel clone failed (attempt $attempt), retrying in 10s..."
  rm -rf webtunnel
  sleep 10
done
if [ ! -d "webtunnel/.git" ]; then
        echo "webtunnel clone failed after retries"
    exit 1
fi
cd webtunnel/main/client
go build
mv client ../../webtunnelclient

cd ../../..


# Build mwc-node
while true; do
  git clone https://github.com/mwcproject/mwc-wallet.git && break
done
cd mwc-wallet
TAG_FOR_BUILD_FILE=../mwc-core.version
if [ -f "$TAG_FOR_BUILD_FILE" ]; then
    git fetch && git fetch --tags;
    git checkout `cat $TAG_FOR_BUILD_FILE`;
fi
./build_static.sh

FILE=target/release/libmwc_wallet_lib.a
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
cp ../webtunnel/webtunnelclient mwc-qt-wallet.app/Contents/MacOS/webtunnelclient
$QT_INSTALL_PATH/6.2.4/macos/bin/macdeployqt mwc-qt-wallet.app -appstore-compliant -verbose=2
echo "deployqt complete"

echo "not signing just building dmg"
# We can't sign, just build dmg
hdiutil create ../target/mwc-qt-wallet.dmg -fs HFS+ -srcfolder mwc-qt-wallet.app -format UDZO -volname mwc-qt-wallet;
resulting_path=$(realpath "../target/mwc-qt-wallet.dmg")
echo "Complete!  Resulting file: $resulting_path";
echo "After please clean up:  rm -rf mwc713 mwc-node mwc-qt-wallet target/*"
