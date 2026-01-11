#!/bin/sh

set -x
set -e

NUMBER_GLOBAL=`cat ./version.txt`
VERSION=2.0-$NUMBER_GLOBAL.beta.$1
echo $VERSION
VERSION_NAME=2.0
RELEASE_NAME=$NUMBER_GLOBAL.beta.$1
TAG_FOR_BUILD_FILE=mwc-qt-wallet.version
if [ -f "$TAG_FOR_BUILD_FILE" ]; then
    VERSION=`cat $TAG_FOR_BUILD_FILE`;
    VERSION_NAME=2.0
    RELEASE_NAME=$NUMBER_GLOBAL
fi

QT_VERSION=${QT_VERSION:-6.8.3}
QT_ROOT=${QT_INSTALL_PATH:-`pwd`/Qt}

# Clean everything.
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

# Let's build with minimal instaructs set, build will be compartible with all CPUs
# We can compromize performace for qt wallet.
# athlon64 is the minimal CPU for x86_64 bits
#
# Get the full list at:
#   rustc -C target-cpu=help
#
# CFlags are appilcable to C code builds. Rust normally using cc::Build and it use cc compiler that backed by gcc
# cc compiler accept CFLAGS.
# > man cc    - for details
echo "Building for CPU: $CPU_CORE"
export RUSTFLAGS="-C target-cpu=$CPU_CORE"
export CPPFLAGS="-march=$CPU_CORE -mcpu=$CPU_CORE"
export CFLAGS="-march=$CPU_CORE -mcpu=$CPU_CORE"

# Build mwc wallet & node static lib. Mwc-wallet lib build will cover both
git clone https://github.com/mwcproject/mwc-wallet
cd mwc-wallet

TAG_FOR_BUILD_FILE=../mwc-core.version
if [ -f "$TAG_FOR_BUILD_FILE" ]; then
    git fetch && git fetch --tags;
    git checkout `cat $TAG_FOR_BUILD_FILE`;
fi

./build_static_linux.sh

FILE=target/release/libmwc_wallet_lib.a
if [ ! -f "$FILE" ]; then
    echo "ERROR: $FILE does not exist";
    exit 1;
fi

cd ..

# Build mwc-qt-wallet
git clone https://github.com/mwcproject/mwc-qt-wallet
cd mwc-qt-wallet
TAG_FOR_BUILD_FILE=../mwc-qt-wallet.version
if [ -f "$TAG_FOR_BUILD_FILE" ]; then
    git fetch && git fetch --tags;
    git checkout `cat $TAG_FOR_BUILD_FILE`;
    echo "#define BUILD_VERSION  \"`cat $TAG_FOR_BUILD_FILE`\"" > build_version.h
else
    echo "#define BUILD_VERSION  \"$VERSION\"" > build_version.h
fi

$QT_ROOT/$QT_VERSION/gcc_64/bin/qmake mwc-wallet-desktop.pro QMAKE_CXXFLAGS="-include /usr/include/features.h -fno-sized-deallocation -pipe -L/usr/lib/x86_64-linux-gnu" -config release -spec linux-g++ CONFIG+=x86_64

FILE=Makefile
if [ ! -f "$FILE" ]; then
    echo "ERROR: $FILE does not exist";
    exit 1;
fi

make -j 8

FILE=mwc-qt-wallet
if [ ! -f "$FILE" ]; then
    echo "ERROR: $FILE does not exist";
    exit 1;
fi

cd ../
export DPKG_VERSION=$VERSION
export DPKG_NAME=mwc-qt-wallet-$DPKG_VERSION
echo "Building $DPKG_NAME"
mkdir -p target/$DPKG_NAME/usr/local/bin/
mkdir -p target/$DPKG_NAME/usr/local/mwc-qt-wallet/bin
mkdir -p target/$DPKG_NAME/usr/local/mwc-qt-wallet/bin/platforms
mkdir -p target/$DPKG_NAME/lib/x86_64-linux-gnu
cp mwc-qt-wallet/mwc-qt-wallet target/$DPKG_NAME/usr/local/mwc-qt-wallet/bin
cp webtunnel/webtunnelclient target/$DPKG_NAME/usr/local/mwc-qt-wallet/bin

cp $QT_ROOT/$QT_VERSION/gcc_64/plugins/platforms/libqxcb.so  target/$DPKG_NAME/usr/local/mwc-qt-wallet/bin/platforms

# Make debain package
cd target
mkdir -p $DPKG_NAME/DEBIAN
cp ../resources/control $DPKG_NAME/DEBIAN
cp ../resources/mwc-qt-wallet.sh $DPKG_NAME/usr/local/bin/mwc-qt-wallet
cp ../resources/mwc-qt-wallet_lr.sh $DPKG_NAME/usr/local/bin/mwc-qt-wallet_lr
cp -rp ../resources/share $DPKG_NAME/usr

# Update build number
perl -pi -e 's/VERSION_VALUE/$ENV{DPKG_VERSION}/g' $DPKG_NAME/DEBIAN/control

echo "Building debain package at target/$DPKG_NAME.deb"
dpkg-deb --build $DPKG_NAME

echo "Building tar.gz"
QT_WALLET_DIRECTORY=tmp/mwc-qt-wallet-$VERSION
mkdir -p tmp/mwc-qt-wallet-$VERSION
cp ../mwc-qt-wallet/mwc-qt-wallet $QT_WALLET_DIRECTORY/mwc-qt-wallet.bin
cp ../webtunnel/webtunnelclient $QT_WALLET_DIRECTORY
cp ../resources/mwc-qt-wallet.tarver.sh $QT_WALLET_DIRECTORY/mwc-qt-wallet
cp ../resources/mwc-qt-wallet_lr.tarver.sh $QT_WALLET_DIRECTORY/mwc-qt-wallet_lr

cd tmp
tar cvf ../mwc-qt-wallet-$VERSION.tar mwc-qt-wallet-$VERSION
gzip ../mwc-qt-wallet-$VERSION.tar
cp ../mwc-qt-wallet-$VERSION.tar.gz ~
cd ../..

# build RPM
cp rpmbuild.tar ~
cd ~
rm -rf rpmbuild
tar xvf rpmbuild.tar
cp mwc-qt-wallet-$VERSION.tar.gz rpmbuild/SOURCES/mwc-qt-wallet-1.1.tar.gz
cd rpmbuild/SOURCES
gzip -dc *.gz | tar xvf -
rm *.gz
mv * mwc-qt-wallet-1.1
tar cvf mwc-qt-wallet-1.1.tar mwc-qt-wallet-1.1
gzip mwc-qt-wallet-1.1.tar
cd ../..
cp rpmbuild/SPECS/mwc-qt-wallet.spec.template rpmbuild/SPECS/mwc-qt-wallet.spec

echo "relname=$RELEASE_NAME"
export RELEASE_NAME VERSION_NAME
perl -pi -e 's/RELEASE_NAME/$ENV{RELEASE_NAME}/g' rpmbuild/SPECS/mwc-qt-wallet.spec
perl -pi -e 's/VERSION_NAME/$ENV{VERSION_NAME}/g' rpmbuild/SPECS/mwc-qt-wallet.spec
rpmbuild -bb rpmbuild/SPECS/mwc-qt-wallet.spec

echo "Build Complete";
