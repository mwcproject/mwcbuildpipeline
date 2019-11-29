#!/bin/sh

curl https://sh.rustup.rs -sSf | bash -s -- -y
# ~/.cargo/bin/rustup override set 1.37.0
echo "##vso[task.setvariable variable=PATH;]$PATH:$HOME/.cargo/bin"

# Get helper files
git clone https://github.com/mwcproject/mwcbuilder-macos-helpers
cat mwcbuilder-macos-helpers/qt_59_aaa mwcbuilder-macos-helpers/qt_59_aab | bzip2 -dc | tar xvf -
rm -rf mwcbuilder-linux-helpers



