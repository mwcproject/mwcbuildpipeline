#!/bin/sh


export MACOSX_DEPLOYMENT_TARGET=10.8

# Second build mwc-qt-wallet

# prepare for QT fix
export QT_INSTALL_PATH="$HOME/Qt"
echo "QT_INSTALL_PATH=$QT_INSTALL_PATH"

git clone https://github.com/mwcproject/mwc-qt-wallet
cp fix_macos_makefile.sh mwc-qt-wallet
cd mwc-qt-wallet
# git checkout  2019_09_cold_wallet
~/Qt/5.9/clang_64/bin/qmake mwc-qt-wallet.pro -spec macx-clang CONFIG+=x86_64
./fix_macos_makefile.sh
make -j 16

