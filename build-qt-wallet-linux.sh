#!/bin/sh

# Clean everything.
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
git apply -p1 ../patch.p1
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
export DPKG_VERSION=1.0-5.beta.$1
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
mkdir -p tmp/mwc-qt-wallet-1.0
cp ../mwc-qt-wallet/mwc-qt-wallet tmp/mwc-qt-wallet-1.0/mwc-qt-wallet.bin
cp ../mwc713/target/release/mwc713 tmp/mwc-qt-wallet-1.0
cp ../resources/mwc-qt-wallet.tarver.sh tmp/mwc-qt-wallet-1.0/mwc-qt-wallet
cp ../resources/mwc-qt-wallet_lr.tarver.sh tmp/mwc-qt-wallet-1.0/mwc-qt-wallet_lr

cd tmp
tar cvf ../mwc-qt-wallet-1.0-5.tar mwc-qt-wallet-1.0
gzip ../mwc-qt-wallet-1.0-5.tar

echo "Build Complete";

