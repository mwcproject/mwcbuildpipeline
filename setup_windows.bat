
git clone https://github.com/mwcproject/mwcbuilder-win64-helpers

echo "scp.expect version.txt %1"
pscp.exe -pw %1 version.txt uploader@3.228.53.68:/home/uploader

cat mwcbuilder-win64-helpers/Qt5.tar.bz2.* | bzip2 -dc | tar xvf -
bzip2 -dc mwcbuilder-win64-helpers/libs.tar.bz2 | tar xvf -

rm -rf mwcbuilder-win64-helpers

echo "scp.expect version.txt %1"
pscp.exe -pw %1 version.txt uploader@3.228.53.68:/home/uploader

choco install -y llvm
choco install rust

rem need putty for scp
choco install -y putty

rem rem rustup override set 1.37.0
