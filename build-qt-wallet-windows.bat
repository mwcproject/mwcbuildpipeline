setlocal enableextensions enabledelayedexpansion
@echo on
set /p NUMBER_GLOBAL=<version.txt

del /s /q target
rmdir /s /q target
del /s /q mwc-node
rmdir /s /q mwc-node
del /s /q mwc713
rmdir /s /q mwc713
del /s /q mwc-qt-wallet
rmdir /s /q mwc-qt-wallet

set RUSTFLAGS=-Ctarget-cpu=%CPU_CORE%

REM Current MS compiler has SSL2 as minimum setting and it is default, not much what we can lower
REM set CPPFLAGS=/arch:%MS_ARCH%
rem set CFLAGS=/arch:%MS_ARCH%

echo "Building for CPU (rust level only): %CPU_CORE%

mkdir target

git clone https://github.com/mwcproject/mwc-node
cd mwc-node

set TAG_FOR_BUILD_FILE=..\mwc-node.version
IF EXIST "%TAG_FOR_BUILD_FILE%" (
    set /p VERSION=<..\mwc-node.version
    git fetch --all
    git checkout !VERSION!
)

call build_static64.bat

cd ..

git clone https://github.com/mwcproject/mwc713
cd mwc713
set TAG_FOR_BUILD_FILE=..\mwc713.version
IF EXIST "%TAG_FOR_BUILD_FILE%" (
    set /p VERSION=<..\mwc713.version
    echo "version=!VERSION!"
    git fetch --all
    git checkout !VERSION!
)

call build_static64.bat

cd ..

set PATH=%cd%\Qt\Tools\mingw730_64\bin;%cd%\Qt\5.13.2\mingw73_64\bin;C:\Program Files (x86)\NSIS;%PATH%

git clone https://github.com/mwcproject/mwc-qt-wallet
cd mwc-qt-wallet
set TAG_FOR_BUILD_FILE=..\mwc-qt-wallet.version
IF EXIST "%TAG_FOR_BUILD_FILE%" (
    set /p QT_WALLET_VERSION=<..\mwc-qt-wallet.version
    @echo off
    (for /f "tokens=2,* delims=." %%a in (..\mwc-qt-wallet.version) do echo %%b) > output.txt
    @echo on
    set /p PATCH_NUMBER=<output.txt
    echo "Using !QT_WALLET_VERSION! patchnumber= %PATCH_NUMBER%"
    git fetch --all
    git checkout !QT_WALLET_VERSION!
    echo #define BUILD_VERSION "!QT_WALLET_VERSION!" > build_version.h
) ELSE (
    echo #define BUILD_VERSION "1.1-!NUMBER_GLOBAL!.beta.%1" > build_version.h
    set PATCH_NUMBER="!NUMBER_GLOBAL!.beta.%1"
)

echo "Using patch number = %PATCH_NUMBER%"

xcopy ..\nsis\resources\logo.ico .
qmake -spec win32-g++ mwc-wallet-desktop.pro win32:RC_ICONS+=logo.ico
rem  For local build try to use:  mingw32-make.exe -j8
rem make -j 8
mingw32-make.exe -j8
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
xcopy mwc713\target\release\mwczip.exe target\nsis\payload\x64
xcopy mwc-node\target\release\mwc.exe target\nsis\payload\x64
xcopy mwc-qt-wallet\release\mwc-qt-wallet.exe target\nsis\payload\x64
xcopy resources\64\tor.exe target\nsis\payload\x64

powershell -Command "(gc target\nsis\include\config.nsh) -replace 'REPLACE_VERSION_PATCH', '%PATCH_NUMBER%' | Out-File -encoding ASCII target\nsis\include\config.nsh"

windeployqt target\nsis\payload\x64\mwc-qt-wallet.exe

cd target/nsis
makensis x64.nsi
endlocal
