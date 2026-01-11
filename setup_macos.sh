#!/bin/sh

set -x
set -e

brew cleanup
brew update
brew uninstall llvm
brew install libressl
brew install coreutils
brew install go
brew install pipx
pipx ensurepath

curl https://sh.rustup.rs -sSf | bash -s -- -y
# ~/.cargo/bin/rustup override set 1.37.0
echo "##vso[task.setvariable variable=PATH;]$PATH:$HOME/.cargo/bin"

# Install latest Qt 6.8.x using official packages (avoid git-cloned Qt)
QT_VERSION=$(pipx run --spec aqtinstall -- aqt list-qt mac desktop | grep -oE '6\.8\.[0-9]+' | sort -V | tail -n 1)
if [ -z "$QT_VERSION" ]; then
    echo "ERROR: Unable to resolve latest Qt 6.8.x version"
    exit 1
fi
echo "Using QT_VERSION=$QT_VERSION"
echo "##vso[task.setvariable variable=QT_VERSION]$QT_VERSION"
pipx run --spec aqtinstall -- aqt install-qt mac desktop $QT_VERSION clang_64 -O Qt
