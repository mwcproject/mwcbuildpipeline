#!/bin/sh

set -x
set -e

echo "Starting build-qt-wallet-macos.sh"
NUMBER_GLOBAL=`cat ./version.txt`
export MACOSX_DEPLOYMENT_TARGET=10.9
. ~/.cargo/env
export QT_VERSION=${QT_VERSION:-6.8.3}

# Clean everything. This is a release build so we can wait
rm -rf mwc-wallet webtunnel mwc-qt-wallet target
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

# Build mwc wallet & node static lib. Mwc-wallet lib build will cover both
git clone https://github.com/mwcproject/mwc-wallet
cd mwc-wallet

TAG_FOR_BUILD_FILE=../mwc-core.version
if [ -f "$TAG_FOR_BUILD_FILE" ]; then
    git fetch && git fetch --tags;
    git checkout `cat $TAG_FOR_BUILD_FILE`;
fi
# It is a target that match QT 6.8 macos version
export MACOSX_DEPLOYMENT_TARGET=12.0
export CFLAGS="-mmacosx-version-min=12.0"
export CXXFLAGS="-mmacosx-version-min=12.0"
export RUSTFLAGS="-C link-arg=-mmacosx-version-min=12.0"

./build_static.sh

FILE=target/release/libmwc_wallet_lib.a
if [ ! -f "$FILE" ]; then
    echo "ERROR: $FILE does not exist";
    exit 1;
fi

cd ..

# prepare for QT fix
export QT_INSTALL_PATH=${QT_INSTALL_PATH:-`pwd`/Qt}
echo "QT_INSTALL_PATH=$QT_INSTALL_PATH"

# Second build mwc-qt-wallet
git clone https://github.com/mwcproject/mwc-qt-wallet
cp fix_macos_makefile.sh mwc-qt-wallet
cd mwc-qt-wallet
TAG_FOR_BUILD_FILE=../mwc-qt-wallet.version
if [ -f "$TAG_FOR_BUILD_FILE" ]; then
    git fetch && git fetch --tags;
    git checkout `cat $TAG_FOR_BUILD_FILE`;
    echo "#define BUILD_VERSION  \"`cat $TAG_FOR_BUILD_FILE`\"" > build_version.h
fi

echo "Here is what we have at build_version.h"
cat build_version.h

$QT_INSTALL_PATH/$QT_VERSION/macos/bin/qmake mwc-wallet-desktop.pro -spec macx-clang CONFIG+=x86_64
# ./fix_macos_makefile.sh
make -j8

# Finally prep dmg
cp ../webtunnel/webtunnelclient mwc-qt-wallet.app/Contents/MacOS/webtunnelclient
$QT_INSTALL_PATH/$QT_VERSION/macos/bin/macdeployqt mwc-qt-wallet.app -appstore-compliant -verbose=2
echo "deployqt complete"

if [ -z "$2" ]
then
   echo "not signing just building dmg"
   # We can't sign so just build dmg
   hdiutil create ../target/mwc-qt-wallet.dmg -fs HFS+ -srcfolder mwc-qt-wallet.app -format UDZO -volname mwc-qt-wallet;
   echo "Complete!";
else
   echo "Setting up certs"
   unzip -P $4 ../certs.zip
   ls -al ./certs
   # setup certs
   sudo security list-keychains
   ls -l ~/Library/Keychains
   #echo 'export PATH="/usr/local/opt/libressl/bin:$PATH"' >> /Users/runner/.bash_profile 
   #source /Users/runner/.bash_profile
   #openssl version
   #openssl enc -d -aes-256-cbc -in ../certs.tar.gz.enc -out certs.tar.gz -k $3
   #openssl enc -d -aes-256-cbc -in ../certsJB.tar.gz.enc -out certs.tar.gz -k $4
   
   sudo security create-keychain -p password nchain.keychain
   sudo security add-certificates -k nchain.keychain certs/azure_cert.cer
   sudo security unlock-keychain -p password nchain.keychain
   sudo security import certs/azure_cert.p12 -k nchain.keychain -P $4 -T /usr/bin/codesign
   echo "Finished creating keychain"

   security list-keychains -s login.keychain nchain.keychain
   ls -l ~/Library/Keychains
   sudo security list-keychain
   sudo security set-key-partition-list -S apple-tool:,apple: -s -k password nchain.keychain >/dev/null 2>&1

   echo "signing the app now"
   # Sign
   #codesign --force --options runtime --sign 'Developer ID Application: Christopher Gilliard (D6WGXN9XBM)' --deep mwc-qt-wallet.app
   codesign --force --options runtime --sign 'Developer ID Application: James Byrer (76DUL32Z4P)' --deep mwc-qt-wallet.app
   # Building the disk image for the app folder
   hdiutil create ../target/mwc-qt-wallet.dmg -fs HFS+ -srcfolder mwc-qt-wallet.app -format UDZO -volname mwc-qt-wallet

#   echo "SIGNING AND NOTARIZING IS DISABLED!!! Please fix me"
#   exit

   echo "Your diskimage is created. Now we need to sign it..."
   # signing resulting package
   #codesign --sign 'Developer ID Application: Christopher Gilliard (D6WGXN9XBM)' ../target/mwc-qt-wallet.dmg
   codesign --sign 'Developer ID Application: James Byrer (76DUL32Z4P)' ../target/mwc-qt-wallet.dmg

   # now notarize the app
   echo "Notarizing this will take a while..."

   rm -rf /tmp/notarize_out.log;
   #xcrun altool --notarize-app -f ../target/mwc-qt-wallet.dmg --primary-bundle-id com.yourcompany.mwc-qt-wallet -u mimblewimblecoin2@protonmail.com -p $2
   #xcrun altool --notarize-app -f ../target/mwc-qt-wallet.dmg --primary-bundle-id com.yourcompany.mwc-qt-wallet -u jbyrer@gmail.com -p $5
   xcrun altool --notarize-app -f ../target/mwc-qt-wallet.dmg --primary-bundle-id com.yourcompany.mwc-qt-wallet -u jillianebyrer@gmail.com -p $5
   echo "Sleeping for 2 minutes to let apple process things."
   sleep 120;
   xcrun stapler staple -q -v ../target/mwc-qt-wallet.dmg

   echo "Check your resulting image at target/mwc-qt-wallet.dmg. Check contents at mwc-qt-wallet/mwc-qt-wallet.app"
   echo "To do this, open the dmg, and drag the app into the /Applications folder"
   echo "Then run this command: spctl -a -v /Applications/mwc-qt-wallet.app"
   echo "You should see a message like this: source=Notarized Developer ID"
   echo "Note you must be on MacOSX10.14+"
fi
