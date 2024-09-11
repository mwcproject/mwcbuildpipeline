@echo on

df -h

rem need putty for scp
choco install -y putty
choco install -y bzip2
choco install -y gnuwin32-coreutils.install

git clone https://github.com/mwcproject/mwcbuilder-win32-helpers

cat mwcbuilder-win32-helpers/win32_5132_* | bzip2 -dc | tar xvf -
bzip2 -dc mwcbuilder-win32-helpers/llvm_openssl_win32.tar.bz2 | tar xvf -

rm -rf mwcbuilder-win32-helpers

choco install -y llvm
rem Open SSL comes from the helper because choco doesn't install 32 bit packages for 64 bit OS.

choco install rustup.install
rustup install stable-i686-pc-windows-msvc

