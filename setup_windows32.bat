df -h

rem need putty for scp
choco install -y putty

git clone https://github.com/mwcproject/mwcbuilder-win32-helpers

cat mwcbuilder-win32-helpers/win32_5132_* | bzip2 -dc | tar xvf -
bzip2 -dc mwcbuilder-win32-helpers/libs32.tar.bz2 | tar xvf -

rm -rf mwcbuilder-win32-helpers

choco install -y llvm

rustup install stable-i686-pc-windows-msvc

rem rustup install 1.37.0-i686-pc-windows-msvc
rem rustup override set 1.37.0-i686-pc-windows-msvc
