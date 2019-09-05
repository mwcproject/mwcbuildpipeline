#!/bin/sh


DPKG_NAME=mwc-qt-wallet_1.0-5.beta.$1
echo "md5sum = `md5sum target/*.deb`";
mkdir -p ~/.ssh
DATE=`date +"%m-%d-%y"`
cp target/*.deb $DPKG_NAME-linux64-$DATE.deb
cp target/*.tar.gz "$DPKG_NAME"_linux64-$DATE.tar.gz
scp -i ./uploader.pem -o 'StrictHostKeyChecking no' $DPKG_NAME-linux64-$DATE.deb uploader\@3.228.53.68:/home/uploader/
scp -i ./uploader.pem -o 'StrictHostKeyChecking no' "$DPKG_NAME"_linux64-$DATE.tar.gz uploader\@3.228.53.68:/home/uploader/

