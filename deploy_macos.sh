#!/bin/sh


echo "md5sum = `md5 target/*.dmg`";
cp target/*.dmg mwc-qt-wallet-1.0-5.beta.$1-macosx.dmg;
scp -i ./uploader.pem -o 'StrictHostKeyChecking no' mwc-qt-wallet-1.0-5.beta.$1-macosx.dmg uploader\@3.228.53.68:/home/uploader/
