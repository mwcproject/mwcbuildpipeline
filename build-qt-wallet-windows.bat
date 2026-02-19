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
    set "SANITISE_CC_FLAGS=/fsanitize=address"
    set "SANITISE_LINK_FLAGS=/INFERASANLIBS"
    set "SANITISE_RUSTFLAGS=-Ctarget-feature=-crt-static"
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
set "QT_BIN=%QT_ROOT%\%QT_VERSION%\msvc2022_64\bin"

if not exist "%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" (
    echo ERROR: vswhere.exe not found
    exit /b 1
)
for /f "usebackq delims=" %%I in (`"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "VSWHERE_INSTALLDIR=%%I"
if "%VSWHERE_INSTALLDIR%"=="" (
    echo ERROR: Visual Studio with C++ tools was not found
    exit /b 1
)
set "VSINSTALLDIR="
set "VS_DEVCMD=%VSWHERE_INSTALLDIR%\Common7\Tools\VsDevCmd.bat"
if exist "%VS_DEVCMD%" (
    call "%VS_DEVCMD%" -arch=amd64 -host_arch=amd64 || exit /b 1
) else (
    call "%VSWHERE_INSTALLDIR%\VC\Auxiliary\Build\vcvars64.bat" || exit /b 1
)

if "%VCToolsInstallDir%"=="" (
    echo ERROR: VCToolsInstallDir is not set after VS environment initialization
    exit /b 1
)
set "MSVC_BIN=%VCToolsInstallDir%bin\Hostx64\x64"
if not exist "%MSVC_BIN%\cl.exe" (
    echo ERROR: cl.exe was not found at %MSVC_BIN%
    exit /b 1
)

set "PATH=%MSVC_BIN%;%QT_BIN%;C:\Program Files (x86)\NSIS;%PATH%"
echo VSINSTALLDIR=%VSINSTALLDIR%
echo VCToolsInstallDir=%VCToolsInstallDir%
echo MSVC_BIN=%MSVC_BIN%

set "CFLAGS="
set "CXXFLAGS="
set "CFLAGS_x86_64_pc_windows_msvc="
set "CXXFLAGS_x86_64_pc_windows_msvc="

set "BASE_RUSTFLAGS=-Ctarget-cpu=%CPU_CORE%"
set "RUSTFLAGS=%BASE_RUSTFLAGS% %SANITISE_RUSTFLAGS%"

if /I "%SANITISE_ENABLED%"=="true" (
    set "CFLAGS=%SANITISE_CC_FLAGS%"
    set "CXXFLAGS=%SANITISE_CC_FLAGS%"
    set "CFLAGS_x86_64_pc_windows_msvc=%SANITISE_CC_FLAGS%"
    set "CXXFLAGS_x86_64_pc_windows_msvc=%SANITISE_CC_FLAGS%"
)

set CC_x86_64_pc_windows_msvc=cl
set CXX_x86_64_pc_windows_msvc=cl
set CC=cl
set CXX=cl
set CARGO_TARGET_X86_64_PC_WINDOWS_MSVC_LINKER=link
echo Pinned compiler chain: CC=%CC_x86_64_pc_windows_msvc% CXX=%CXX_x86_64_pc_windows_msvc% RustLinker=%CARGO_TARGET_X86_64_PC_WINDOWS_MSVC_LINKER% QtSpec=win32-msvc
where cl || exit /b 1
where link || exit /b 1
where nmake || exit /b 1

echo Building for CPU (rust level only): %CPU_CORE%

mkdir target

REM Building webtunnel client
git clone https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/webtunnel
cd webtunnel\main\client || exit /b 1
go build || exit /b 1
move client.exe ..\..\webtunnelclient.exe

cd ..\..\..

git clone https://github.com/mwcproject/mwc-wallet
cd mwc-wallet

set TAG_FOR_BUILD_FILE=..\mwc-core.version
IF EXIST "%TAG_FOR_BUILD_FILE%" (
    set /p VERSION=<..\mwc-core.version
    git fetch --all
    git checkout !VERSION!
)

cargo build --package mwc_wallet_lib --lib --release --target x86_64-pc-windows-msvc || exit /b 1

if not exist "target\x86_64-pc-windows-msvc\release\mwc_wallet_lib.lib" (
    echo ERROR: target\x86_64-pc-windows-msvc\release\mwc_wallet_lib.lib does not exist
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
    "%QT_BIN%\qmake.exe" -spec win32-msvc mwc-wallet-desktop.pro win32:RC_ICONS+=logo.ico "QMAKE_CFLAGS_RELEASE+=%SANITISE_CC_FLAGS%" "QMAKE_CXXFLAGS_RELEASE+=%SANITISE_CC_FLAGS%" "QMAKE_LFLAGS_RELEASE+=%SANITISE_LINK_FLAGS%"
) else (
    "%QT_BIN%\qmake.exe" -spec win32-msvc mwc-wallet-desktop.pro win32:RC_ICONS+=logo.ico
)
nmake /NOLOGO || exit /b 1
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

"%QT_BIN%\windeployqt6.exe" target\nsis\payload\x64\mwc-qt-wallet.exe

cd target/nsis
makensis x64.nsi
endlocal
