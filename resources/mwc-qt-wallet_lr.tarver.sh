#!/bin/sh

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
export LD_LIBRARY_PATH="$SCRIPTPATH/lib:$LD_LIBRARY_PATH"
export QT_PLUGIN_PATH="$SCRIPTPATH/plugins"
export QT_QPA_PLATFORM_PLUGIN_PATH="$SCRIPTPATH/plugins/platforms"
exec "$SCRIPTPATH/mwc-qt-wallet.bin"
