#!/bin/sh

# Update repos
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
sudo apt-add-repository "deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-6.0 main"

# Add deps
sudo apt update
sudo apt-get install expect
sudo apt install clang-8 git curl make build-essential mesa-utils libgl1-mesa-dev openssl libssl-dev -y

sudo apt-get update -yqq
sudo apt-get install -yqq --no-install-recommends libncursesw5-dev

# list what we have
sudo apt list --installed

# Update rust
curl https://sh.rustup.rs -sSf | bash -s -- -y
# ~/.cargo/bin/rustup override set 1.37.0

sudo ln -s ~/.cargo/bin/cargo /usr/bin/cargo

# Get helper files
git clone https://github.com/mwcproject/mwcbuilder-linux-helpers
cat mwcbuilder-linux-helpers/QT-segment* | bzip2 -dc | tar xvf -
rm -rf mwcbuilder-linux-helpers

#sudo apt-get purge -yqq clang-8 clang-9 clangd-8 clangd-9 libclang-common-8-dev libclang-common-9-dev libclang1-8 libclang-cpp9
#sudo apt-get purge -yqq llvm-8 llvm-8-dev llvm-8-runtime llvm-9 llvm-9-dev llvm-9-runtime llvm-9-tools liblldb-8 liblldb-9 libllvm8 libllvm9
