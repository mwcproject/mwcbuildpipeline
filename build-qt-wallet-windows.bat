setlocal enableextensions enabledelayedexpansion
@echo on
set /p NUMBER_GLOBAL=<version.txt

set SANITISE_ENABLED=false
if "%SANITISE_BUILD%"=="true" set SANITISE_ENABLED=true
echo SANITISE_BUILD=%SANITISE_BUILD% (enabled=%SANITISE_ENABLED%)

set "SANITISE_CC_FLAGS="
set "SANITISE_LINK_FLAGS="
set "SANITISE_RUSTFLAGS="
if /I "%SANITISE_ENABLED%"=="true" (
    set "SANITISE_CC_FLAGS=-fsanitize=address"
    set "SANITISE_LINK_FLAGS=-fsanitize=address"
    set "SANITISE_RUSTFLAGS=-Clink-arg=-fsanitize=address"
    echo Sanitizers are enabled for Windows release build
) else (
    echo Sanitizers are disabled for Windows release build
)

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

set "BASE_RUSTFLAGS=-Clinker=gcc -Ctarget-cpu=%CPU_CORE%"
set "RUSTFLAGS=%BASE_RUSTFLAGS% %SANITISE_RUSTFLAGS%"

REM Current MS compiler has SSL2 as minimum setting and it is default, not much what we can lower
REM set CPPFLAGS=/arch:%MS_ARCH%
rem set CFLAGS=/arch:%MS_ARCH%

echo Building for CPU (rust level only): %CPU_CORE%

mkdir target

REM Building webtunnel client
git clone https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/webtunnel
cd webtunnel\main\client || exit /b 1
go build || exit /b 1
move client.exe ..\..\webtunnelclient.exe

cd ..\..\..


set "PATH=%QT_ROOT%\Tools\mingw1310_64\bin;%QT_ROOT%\%QT_VERSION%\mingw_64\bin;C:\Program Files (x86)\NSIS;%PATH%"

if /I "%SANITISE_ENABLED%"=="true" (
    set "MINGW_LIBASAN="
    for /f "delims=" %%F in ('dir /b /s "%QT_ROOT%\Tools\mingw1310_64\lib\gcc\x86_64-w64-mingw32\*\libasan.dll.a" 2^>nul') do set "MINGW_LIBASAN=%%F"
    if "!MINGW_LIBASAN!"=="" (
        echo ERROR: libasan.dll.a not found in Qt MinGW toolchain while SANITISE_BUILD=true
        echo ERROR: Ensure setup_windows.bat installs ASan runtime for mingw1310_64
        exit /b 1
    ) else (
        echo Using libasan: !MINGW_LIBASAN!
    )
)

set "RUSTFLAGS=%BASE_RUSTFLAGS% %SANITISE_RUSTFLAGS%"

if /I "%SANITISE_ENABLED%"=="true" (
    set "CFLAGS=%SANITISE_CC_FLAGS%"
    set "CXXFLAGS=%SANITISE_CC_FLAGS%"
)

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
set CARGO_TARGET_X86_64_PC_WINDOWS_GNU_LINKER=gcc
echo Pinned compiler chain: CC=%CC% CXX=%CXX% RustLinker=%CARGO_TARGET_X86_64_PC_WINDOWS_GNU_LINKER% QtSpec=win32-g++
gcc --version

git clone https://github.com/mwcproject/mwc-wallet
cd mwc-wallet

set TAG_FOR_BUILD_FILE=..\mwc-core.version
IF EXIST "%TAG_FOR_BUILD_FILE%" (
    set /p VERSION=<..\mwc-core.version
    git fetch --all
    git checkout !VERSION!
)

cargo build --package mwc_wallet_lib --lib --release --target x86_64-pc-windows-gnu || exit /b 1

if not exist "target\x86_64-pc-windows-gnu\release\libmwc_wallet_lib.a" (
    echo ERROR: target\x86_64-pc-windows-gnu\release\libmwc_wallet_lib.a does not exist
    exit /b 1
)

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
if /I "%SANITISE_ENABLED%"=="true" (
    qmake -spec win32-g++ mwc-wallet-desktop.pro win32:RC_ICONS+=logo.ico "QMAKE_CFLAGS_RELEASE+=%SANITISE_CC_FLAGS%" "QMAKE_CXXFLAGS_RELEASE+=%SANITISE_CC_FLAGS%" "QMAKE_LFLAGS_RELEASE+=%SANITISE_LINK_FLAGS%"
) else (
    qmake -spec win32-g++ mwc-wallet-desktop.pro win32:RC_ICONS+=logo.ico
)
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
