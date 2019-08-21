df -h

git clone https://github.com/mwcproject/mwcbuilder-win32-helpers

cat mwcbuilder-win32-helpers/qt5-part2/* | bzip2 -dc | tar xvf -
cat mwcbuilder-win32-helpers/qt5/* | bzip2 -dc | tar xvf -
bzip2 -dc mwcbuilder-win32-helpers/libs32.tar.bz2 | tar xvf -

rm -rf mwcbuilder-win32-helpers

rustup install stable-i686-pc-windows-msvc
