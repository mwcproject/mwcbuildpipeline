#!/bin/sh


DPKG_NAME=mwc-qt-wallet_1.0-5.beta.$1
echo "md5sum = `md5sum target/*.deb`";
mkdir -p ~/.ssh
echo "ftp.mwc.mw ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFCzEhIbZcESW50l2Mh9dFIeObKrDBNwZm+FPZzL3tp7U8xkcH0U7rx87cMDUKUfJnO8soJ3yqxf1RXOrFkXKQM=" >> ~/.ssh/known_hosts
DATE=`date +"%m-%d-%y"`
cp target/*.deb $DPKG_NAME-linux64-$DATE.deb
cp target/*.tar.gz $DPKG_NAME_linux64-$DATE.tar.gz
scp -i ./uploader.pem $DPKG_NAME-linux64-$DATE.deb uploader@3.228.53.68:/home/uploader/
scp -i ./uploader.pem $DPKG_NAME_linux64-$DATE.tar.gz uploader@3.228.53.68:/home/uploader/

