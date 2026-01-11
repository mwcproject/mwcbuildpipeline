#!/bin/sh

brew cleanup
brew update
brew uninstall llvm
brew install libressl
brew install coreutils
brew install go

curl https://sh.rustup.rs -sSf | bash -s -- -y
# ~/.cargo/bin/rustup override set 1.37.0
echo "##vso[task.setvariable variable=PATH;]$PATH:$HOME/.cargo/bin"

# Install latest Qt 6.8.x using official packages (avoid git-cloned Qt)
python3 -m pip install --user aqtinstall
QT_VERSION=$(python3 -m aqt list-qt mac desktop | awk '/^6\\.8\\./ {print $1}' | sort -V | tail -n 1)
if [ -z "$QT_VERSION" ]; then
    echo "ERROR: Unable to resolve latest Qt 6.8.x version"
    exit 1
fi
echo "Using QT_VERSION=$QT_VERSION"
echo "##vso[task.setvariable variable=QT_VERSION]$QT_VERSION"
python3 -m aqt install-qt mac desktop $QT_VERSION clang_64 -O Qt
