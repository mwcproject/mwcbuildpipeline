#!/bin/sh

wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
sudo apt-add-repository "deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-6.0 main"

sudo apt update
sudo apt-get install expect
sudo apt install clang-6.0 git curl make build-essential libgl1-mesa-dev openssl libssl1.0-dev -y

curl https://sh.rustup.rs -sSf | bash -s -- -y

sudo ln -s ~/.cargo/bin/cargo /usr/bin/cargo


cat QT-segment* > ./QT.min.tar.bz2
bzip2 -dc QT.min.tar.bz2 | tar xvf -
rm -rf QT.min.tar.bz2
