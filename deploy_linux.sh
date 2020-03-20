#!/bin/sh

chmod 400 ./uploader.pem

TAG_FOR_BUILD_FILE=mwc-qt-wallet.version
if [ -f "$TAG_FOR_BUILD_FILE" ]; then
VERSION=`cat $TAG_FOR_BUILD_FILE`
DPKG_NAME=mwc-qt-wallet_$VERSION
else
DPKG_NAME=mwc-qt-wallet_1.0-14.beta.$1
fi
echo "md5sum = `md5sum target/*.deb`";
mkdir -p ~/.ssh
cp target/*.deb $DPKG_NAME-linux64.deb
cp target/*.tar.gz "$DPKG_NAME"_linux64.tar.gz
scp -i ./uploader.pem -o 'StrictHostKeyChecking no' $DPKG_NAME-linux64.deb uploader\@3.228.53.68:/home/uploader/
scp -i ./uploader.pem -o 'StrictHostKeyChecking no' "$DPKG_NAME"_linux64.tar.gz uploader\@3.228.53.68:/home/uploader/
scp -i ./uploader.pem -o 'StrictHostKeyChecking no' ~/rpmbuild/RPMS/x86_64/*.rpm uploader\@3.228.53.68:/home/uploader/

