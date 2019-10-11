#!/bin/sh

curl https://sh.rustup.rs -sSf | bash -s -- -y
~/.cargo/bin/rustup override set 1.37.0
echo "##vso[task.setvariable variable=PATH;]$PATH:$HOME/.cargo/bin"

brew install qt5
brew link qt5 --force

