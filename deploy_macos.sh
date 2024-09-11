#!/bin/sh

NUMBER_GLOBAL=`cat ./version.txt`
#chmod 400 ./uploader.pem
echo "sha256sum = `sha256sum target/*.dmg`";
TAG_FOR_BUILD_FILE=mwc-qt-wallet.version
if [ -f "$TAG_FOR_BUILD_FILE" ]; then
VERSION=`cat $TAG_FOR_BUILD_FILE`
FILE_PREFIX=mwc-qt-wallet_"${VERSION//\//_}"
else
FILE_PREFIX=mwc-qt-wallet_1.1-"${NUMBER_GLOBAL//\//_}".beta.$1
fi

cp target/*.dmg $FILE_PREFIX-macosx.dmg;
#scp -i ./uploader.pem -o 'StrictHostKeyChecking no' $FILE_PREFIX-macosx.dmg uploader\@ftp.mwc.mw:/home/uploader/
./scp.expect $FILE_PREFIX-macosx.dmg $2

echo "Retry 1 to upload in case if we was interrupted"
./scp.expect $FILE_PREFIX-macosx.dmg $2

echo "Retry 2 to upload in case if we was interrupted"
./scp.expect $FILE_PREFIX-macosx.dmg $2
