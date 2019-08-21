#!/bin/sh

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
export QT_SCALE_FACTOR=1.6

$SCRIPTPATH/mwc-qt-wallet.bin
