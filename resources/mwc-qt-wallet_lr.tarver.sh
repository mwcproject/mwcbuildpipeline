#!/bin/sh
  
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
export QT_SCALE_FACTOR=1.001

$SCRIPTPATH/mwc-qt-wallet.bin
