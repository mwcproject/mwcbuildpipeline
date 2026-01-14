#!/bin/sh

APP_DIR=/usr/local/mwc-qt-wallet
export LD_LIBRARY_PATH="$APP_DIR/lib:$LD_LIBRARY_PATH"
export QT_PLUGIN_PATH="$APP_DIR/plugins"
export QT_QPA_PLATFORM_PLUGIN_PATH="$APP_DIR/plugins/platforms"
export QT_QPA_PLATFORM = xcb
exec "$APP_DIR/bin/mwc-qt-wallet"
