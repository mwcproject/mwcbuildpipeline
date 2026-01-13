#!/bin/sh

set -x
set -e

apt list --installed

# Update repos
#wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
#sudo apt-add-repository "deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-6.0 main"

# Add deps
sudo apt-get update -yqq
sudo apt install clang-14 git curl make build-essential mesa-utils libgl1-mesa-dev openssl libssl-dev -y
sudo apt-get install -yqq --no-install-recommends libncursesw5-dev libgl-dev
sudo apt-get install -y expect
sudo apt-get install -y golang
sudo apt-get install -y python3 python3-pip python3-venv

# list what we have
sudo apt list --installed

# Update rust
curl https://sh.rustup.rs -sSf | bash -s -- -y
# ~/.cargo/bin/rustup override set 1.37.0

sudo ln -sf ~/.cargo/bin/cargo /usr/bin/cargo

# Install latest Qt 6.8.x using official packages (avoid git-cloned Qt)
python3 -m pip install --user pipx
QT_VERSION=$(python3 -m pipx run --spec aqtinstall aqt list-qt linux desktop | grep -oE '6\.8\.[0-9]+' | sort -V | tail -n 1)
if [ -z "$QT_VERSION" ]; then
    echo "ERROR: Unable to resolve latest Qt 6.8.x version"
    exit 1
fi
echo "Using QT_VERSION=$QT_VERSION"
echo "##vso[task.setvariable variable=QT_VERSION]$QT_VERSION"
python3 -m pipx run --spec aqtinstall aqt install-qt linux desktop $QT_VERSION linux_gcc_64 -O Qt

#sudo apt-get purge -yqq clang-8 clang-9 clangd-8 clangd-9 libclang-common-8-dev libclang-common-9-dev libclang1-8 libclang-cpp9
#sudo apt-get purge -yqq llvm-8 llvm-8-dev llvm-8-runtime llvm-9 llvm-9-dev llvm-9-runtime llvm-9-tools liblldb-8 liblldb-9 libllvm8 libllvm9
