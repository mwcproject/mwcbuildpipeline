
git clone https://github.com/mwcproject/mwcbuilder-win64-helpers

cat mwcbuilder-win64-helpers/Qt5.tar.bz2.* | bzip2 -dc | tar xvf -
bzip2 -dc mwcbuilder-win64-helpers/libs.tar.bz2 | tar xvf -
cp mwcbuilder-win64-helpers/pscp.exe .

rm -rf mwcbuilder-win64-helpers

choco install -y llvm
choco install rust

rem rem rustup override set 1.37.0
