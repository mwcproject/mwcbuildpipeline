setlocal enableextensions enabledelayedexpansion
@echo on
set /p NUMBER_GLOBAL=<version.txt

del /s /q target
rmdir /s /q target

if "%QT_VERSION%"=="" set QT_VERSION=6.8.3
set QT_ROOT=%cd%\Qt

set RUSTFLAGS=-Ctarget-cpu=%CPU_CORE%

REM Current MS compiler has SSL2 as minimum setting and it is default, not much what we can lower
REM set CPPFLAGS=/arch:%MS_ARCH%
rem set CFLAGS=/arch:%MS_ARCH%

echo "Building for CPU (rust level only): %CPU_CORE%

mkdir target

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
