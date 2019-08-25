
del /s /q target
rmdir /s /q target
del /s /q mwc713
rmdir /s /q mwc713
del /s /q mwc-qt-wallet
rmdir /s /q mwc-qt-wallet

set LIBCLANG_PATH=%cd%\lib
set OPENSSL_LIB_DIR=%cd%\lib\openssl@1.1/lib/
set OPENSSL_INCLUDE_DIR=%cd%\lib\openssl@1.1/include/
set OPENSSL_STATIC="yes"

mkdir target

git clone https://github.com/mwcproject/mwc713
cd mwc713
cargo build --release
cd ..


git clone https://github.com/mwcproject/mwc-qt-wallet
cd mwc-qt-wallet
cp ..\nsis\resources\logo.ico .
echo "#define BUILD_VERSION ^"1.0-5.beta.%1^" > build_version.h
..\Qt\5.13.0\mingw73_64\bin\qmake -spec win32-g++ mwc-qt-wallet.pro win32:RC_ICONS+=logo.ico
make
cd ..

mkdir target\nsis
mkdir target\nsis\payload
mkdir target\nsis\payload\x64
xcopy nsis target\nsis /e /s /t
xcopy nsis target\nsis
xcopy nsis\resources target\nsis\resources
xcopy nsis\include target\nsis\include
xcopy nsis\include\lang target\nsis\include\lang
xcopy nsis\payload\x64\* target\nsis\payload\x64

xcopy mwc713\target\release\mwc713.exe target\nsis\payload\x64
xcopy mwc-qt-wallet\release\mwc-qt-wallet.exe target\nsis\payload\x64
Qt\5.13.0\mingw73_64\bin\windeployqt target\nsis\payload\x64\mwc-qt-wallet.exe

cd target/nsis
makensis x64.nsi

