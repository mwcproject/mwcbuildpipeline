#!/bin/sh

#chmod 400 ./uploader.pem

LINUX_NAME=linux64-kernel-$1

NUMBER_GLOBAL=`cat ./version.txt`
TAG_FOR_BUILD_FILE=mwc-qt-wallet.version
if [ -f "$TAG_FOR_BUILD_FILE" ]; then
VERSION=`cat $TAG_FOR_BUILD_FILE`
DPKG_NAME=mwc-qt-wallet_$VERSION
else
DPKG_NAME=mwc-qt-wallet_1.1-$NUMBER_GLOBAL.beta.$2
fi
echo "sha256sum = `sha256sum target/*.deb`";
echo "sha256sum = `sha256sum target/*.tar.gz`";
echo "sha256sum = `sha256sum ~/rpmbuild/RPMS/x86_64/*.rpm`";
mkdir -p ~/.ssh
cp target/*.deb "$DPKG_NAME-$LINUX_NAME-$CPU_PACKAGE_NAME.deb"
cp target/*.tar.gz "$DPKG_NAME-$LINUX_NAME-$CPU_PACKAGE_NAME.tar.gz"
cp ~/rpmbuild/RPMS/x86_64/*.rpm "$DPKG_NAME-$LINUX_NAME-$CPU_PACKAGE_NAME.rpm"

ls -al

#scp -i ./uploader.pem -o 'StrictHostKeyChecking no' "$DPKG_NAME-$LINUX_NAME-$CPU_PACKAGE_NAME.deb" uploader\@ftp.mwc.mw:/home/uploader/
#scp -i ./uploader.pem -o 'StrictHostKeyChecking no' "$DPKG_NAME-$LINUX_NAME-$CPU_PACKAGE_NAME.tar.gz" uploader\@ftp.mwc.mw:/home/uploader/
#scp -i ./uploader.pem -o 'StrictHostKeyChecking no' "$DPKG_NAME-$LINUX_NAME-$CPU_PACKAGE_NAME.rpm" uploader\@ftp.mwc.mw:/home/uploader/

./scp.expect "$DPKG_NAME-$LINUX_NAME-$CPU_PACKAGE_NAME.deb" $3
./scp.expect "$DPKG_NAME-$LINUX_NAME-$CPU_PACKAGE_NAME.tar.gz" $3
./scp.expect "$DPKG_NAME-$LINUX_NAME-$CPU_PACKAGE_NAME.rpm" $3
