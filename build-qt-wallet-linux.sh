#!/bin/sh

VERSION=1.0-6.beta.$1
TAG_FOR_BUILD_FILE=mwc-qt-wallet.version
if [ -f "$TAG_FOR_BUILD_FILE" ]; then
VERSION=`cat $TAG_FOR_BUILD_FILE`;
fi

# Clean everything.
rm -rf mwc713 mwc-qt-wallet target/*
mkdir -p target

# First build mwc713 statically
git clone https://github.com/mwcproject/mwc713
cd mwc713

TAG_FOR_BUILD_FILE=../mwc713.version
if [ -f "$TAG_FOR_BUILD_FILE" ]; then
    git fetch && git fetch --tags;
    git checkout `cat $TAG_FOR_BUILD_FILE`;
fi

./build_static.sh

FILE=target/release/mwc713
if [ ! -f "$FILE" ]; then
    echo "ERROR: $FILE does not exist";
    exit 1;
fi

cd ..

# Second build mwc-qt-wallet
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

../Qt/5.9/gcc_64/bin/qmake mwc-qt-wallet.pro QMAKE_CXXFLAGS="-fno-sized-deallocation -pipe" -config release -spec linux-g++ CONFIG+=x86_64

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
cp mwc-qt-wallet/mwc-qt-wallet target/$DPKG_NAME/usr/local/mwc-qt-wallet/bin
cp mwc713/target/release/mwc713 target/$DPKG_NAME/usr/local/mwc-qt-wallet/bin

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
cp ../mwc713/target/release/mwc713 $QT_WALLET_DIRECTORY
cp ../resources/mwc-qt-wallet.tarver.sh $QT_WALLET_DIRECTORY/mwc-qt-wallet
cp ../resources/mwc-qt-wallet_lr.tarver.sh $QT_WALLET_DIRECTORY/mwc-qt-wallet_lr

cd tmp
tar cvf ../mwc-qt-wallet-$VERSION.tar mwc-qt-wallet-$VERSION
gzip ../mwc-qt-wallet-$VERSION.tar

echo "Build Complete";

