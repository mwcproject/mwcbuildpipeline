setlocal enableextensions enabledelayedexpansion
@echo on
set /p NUMBER_GLOBAL=<version.txt

del /s /q target
rmdir /s /q target
del /s /q mwc-wallet
rmdir /s /q mwc-wallet
del /s /q webtunnel
rmdir /s /q webtunnel
del /s /q mwc-qt-wallet
rmdir /s /q mwc-qt-wallet

if "%QT_VERSION%"=="" set QT_VERSION=6.8.3
set QT_ROOT=%cd%\Qt

set RUSTFLAGS=-Ctarget-cpu=%CPU_CORE%

REM Current MS compiler has SSL2 as minimum setting and it is default, not much what we can lower
REM set CPPFLAGS=/arch:%MS_ARCH%
rem set CFLAGS=/arch:%MS_ARCH%

echo "Building for CPU (rust level only): %CPU_CORE%

mkdir target

REM Building webtunnel client
git clone https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/webtunnel
cd webtunnel\main\client || exit /b 1
go build || exit /b 1
move client.exe ..\..\webtunnelclient.exe

cd ..\..\..


set "PATH=%QT_ROOT%\Tools\mingw1310_64\bin;%QT_ROOT%\%QT_VERSION%\mingw_64\bin;C:\Program Files (x86)\NSIS;%PATH%"

REM lto Needed to fix bunch of warnings during link step
set "RUSTFLAGS=%RUSTFLAGS% -Ctarget-cpu=%CPU_CORE%"

REM  Setting up Rust build based on MinGw
set CC_x86_64_pc_windows_gnu=gcc
set CXX_x86_64_pc_windows_gnu=g++
set AR_x86_64_pc_windows_gnu=ar
set RANLIB_x86_64_pc_windows_gnu=ranlib

REM Covering old rust crates that rely on CC
set CC=gcc
set CC_x86_64_pc_windows_gnu=gcc
set CXX=g++
set AR=ar
set RANLIB=ranlib

git clone https://github.com/mwcproject/mwc-wallet
cd mwc-wallet

set TAG_FOR_BUILD_FILE=..\mwc-core.version
IF EXIST "%TAG_FOR_BUILD_FILE%" (
    set /p VERSION=<..\mwc-core.version
    git fetch --all
    git checkout !VERSION!
)

cargo build --package mwc_wallet_lib --lib --release --target x86_64-pc-windows-gnu

cd ..


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
    echo #define BUILD_VERSION "2.0-!NUMBER_GLOBAL!.beta.%1" > build_version.h
    set PATCH_NUMBER="!NUMBER_GLOBAL!.beta.%1"
)

echo "Using patch number = %PATCH_NUMBER%"

xcopy ..\nsis\resources\logo.ico .
qmake -spec win32-g++ mwc-wallet-desktop.pro win32:RC_ICONS+=logo.ico
mingw32-make.exe -j%NUMBER_OF_PROCESSORS%  2>&1 | findstr /v /c:".drectve" /c:"corrupt .drectve"
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

xcopy webtunnel\webtunnelclient.exe target\nsis\payload\x64
xcopy mwc-qt-wallet\release\mwc-qt-wallet.exe target\nsis\payload\x64

powershell -Command "(gc target\nsis\include\config.nsh) -replace 'REPLACE_VERSION_PATCH', '%PATCH_NUMBER%' | Out-File -encoding ASCII target\nsis\include\config.nsh"

windeployqt6 target\nsis\payload\x64\mwc-qt-wallet.exe

cd target/nsis
makensis x64.nsi
endlocal
