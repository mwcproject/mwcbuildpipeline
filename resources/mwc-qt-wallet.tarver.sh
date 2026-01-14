#!/bin/sh

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
export LD_LIBRARY_PATH="$SCRIPTPATH/lib:$LD_LIBRARY_PATH"
export QT_PLUGIN_PATH="$SCRIPTPATH/plugins"
export QT_QPA_PLATFORM_PLUGIN_PATH="$SCRIPTPATH/plugins/platforms"
export QT_QPA_PLATFORM = xcb
exec "$SCRIPTPATH/mwc-qt-wallet.bin" --ui_scale 1.6
