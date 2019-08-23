#!/bin/sh


DPKG_NAME=mwc-qt-wallet_1.0-5.beta.$1
echo "md5sum = `md5sum target/*.deb`";
mkdir -p ~/.ssh
echo "ftp.mwc.mw ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFCzEhIbZcESW50l2Mh9dFIeObKrDBNwZm+FPZzL3tp7U8xkcH0U7rx87cMDUKUfJnO8soJ3yqxf1RXOrFkXKQM=" >> ~/.ssh/known_hosts
DATE=`date +"%m-%d-%y"`
./sendfile.expect target/*.deb $DPKG_NAME-linux64-$DATE.deb;
./sendfile.expect target/*.tar.gz "$DPKG_NAME"_linux64-$DATE.tar.gz;

