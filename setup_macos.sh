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

# Get helper files
git clone https://github.com/mwcproject/mwcbuilder-macos-helpers
cat mwcbuilder-macos-helpers/macos_599_* | bzip2 -dc | tar xvf -
rm -rf mwcbuilder-macos-helpers

# Need to fix what installer did. Installer hardecoded paths to libs by some reasons and it is breaks the build
echo "Patching QT paths. MacOS issue"
grep -rl bay . | grep prl | xargs sed -i '' 's/-F\/Users\/bay\/Qt\/5.9.9\/clang_64\/lib//g'
echo "Patch for QT paths - DONE"
grep -rl bay . | grep prl
echo "Checking for QT paths, prl - DONE"

# It is easy to check if you need that patch:
# 1. Remove the sed command
# 2. Try to build
# 3. Check logs if they have your local paths. If you see them - it is a problem for azure.

