@echo on

rem need putty for scp
choco install -y putty
choco install -y bzip2

git clone https://github.com/mwcproject/mwcbuilder-win64-helpers

Get-Content mwcbuilder-win64-helpers/win64_5132_* | bzip2 -dc | tar xvf -

rm -rf mwcbuilder-win64-helpers

choco install -y llvm
choco install -y openssl
choco install -y rust-ms

