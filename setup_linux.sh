#!/bin/sh

# Update repos
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
sudo apt-add-repository "deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-6.0 main"

# Add deps
sudo apt update
sudo apt-get install expect
sudo apt install clang-6.0 git curl make build-essential libgl1-mesa-dev openssl libssl-dev -y

sudo apt-get update -yqq
sudo apt-get install -yqq --no-install-recommends libncursesw5-dev


# Update rust
curl https://sh.rustup.rs -sSf | bash -s -- -y
# ~/.cargo/bin/rustup override set 1.37.0

sudo ln -s ~/.cargo/bin/cargo /usr/bin/cargo

# Get helper files
git clone https://github.com/mwcproject/mwcbuilder-linux-helpers
cat mwcbuilder-linux-helpers/QT-segment* | bzip2 -dc | tar xvf -
rm -rf mwcbuilder-linux-helpers

