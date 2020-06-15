#!/bin/sh

ls ~/Library/Keychains/

curl https://sh.rustup.rs -sSf | bash -s -- -y
# ~/.cargo/bin/rustup override set 1.37.0
echo "##vso[task.setvariable variable=PATH;]$PATH:$HOME/.cargo/bin"

# Get helper files
git clone https://github.com/mwcproject/mwcbuilder-macos-helpers
cat mwcbuilder-macos-helpers/qt_59_* | bzip2 -dc | tar xvf -
rm -rf mwcbuilder-macos-helpers

brew uninstall llvm

# Need to fix what installer did. Installer hardecoded paths to libs by some reasons and it is breaks the build
echo "Patching QT paths. MacOS issue"
grep -rl kbay . | grep prl | xargs sed -i '' 's/-F\/Users\/kbay\/Qt\/5.9\/clang_64\/lib//g'
# It is easy to check if you need that patch:
# 1. Remove the sed command
# 2. Try to build
# 3. Check logs if they have your local paths. If you see them - it is a problem for azure.

# setup certs
openssl enc -d -aes-256-cbc -in certs.tar.gz.enc -out certs.tar.gz -k $1
gzip -dc certs.tar.gz | tar xvf -

sudo security add-trusted-cert -d -r trustRoot -k ~/Library/Keychains/login.keychain certs/developerID_installer.cer
sudo security add-trusted-cert -d -r trustRoot -k ~/Library/Keychains/login.keychain certs/developerID_application.cer

cp certs/mimblewimble* ~/Library/Keychains
ls ~/Library/Keychains

