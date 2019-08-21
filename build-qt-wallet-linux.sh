#!/bin/sh

# Clean everything. This is a release build so we can wait
rm -rf mwc713 mwc-qt-wallet target/*
mkdir -p target

# First build mwc713 statically
git clone https://github.com/mwcproject/mwc713
cd mwc713
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
../Qt/5.9/gcc_64/bin/qmake mwc-qt-wallet.pro QMAKE_CXXFLAGS="-fno-sized-deallocation -pipe" -config release -spec linux-g++ CONFIG+=x86_64

FILE=Makefile
if [ ! -f "$FILE" ]; then
    echo "ERROR: $FILE does not exist";
    exit 1;
fi

make

FILE=mwc-qt-wallet
if [ ! -f "$FILE" ]; then
    echo "ERROR: $FILE does not exist";
    exit 1;
fi

cd ../
mkdir -p target/mwc-qt-wallet-1.0-5/usr/local/bin/
mkdir -p target/mwc-qt-wallet-1.0-5/usr/local/mwc-qt-wallet/bin
cp mwc-qt-wallet/mwc-qt-wallet target/mwc-qt-wallet-1.0-5/usr/local/mwc-qt-wallet/bin
cp mwc713/target/release/mwc713 target/mwc-qt-wallet-1.0-5/usr/local/mwc-qt-wallet/bin

# Make debain package
cd target
mkdir -p mwc-qt-wallet-1.0-5/DEBIAN
cp ../resources/control mwc-qt-wallet-1.0-5/DEBIAN
cp ../resources/mwc-qt-wallet.sh mwc-qt-wallet-1.0-5/usr/local/bin/mwc-qt-wallet
cp ../resources/mwc-qt-wallet_lr.sh mwc-qt-wallet-1.0-5/usr/local/bin/mwc-qt-wallet_lr
cp -rp ../resources/share mwc-qt-wallet-1.0-5/usr

echo "Building debain package at target/mwc-qt-wallet-1.0-5.deb"
dpkg-deb --build mwc-qt-wallet-1.0-5

echo "Building tar.gz"
mkdir tmp
cp ../mwc-qt-wallet/mwc-qt-wallet tmp
cp ../mwc713/target/release/mwc713 tmp
cd tmp
tar zcvf ../mwc-qt-wallet-1.0-5.tgz *

echo "Build Complete";

