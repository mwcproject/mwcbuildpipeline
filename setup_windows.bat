@echo on
setlocal enableextensions enabledelayedexpansion

rem need putty for scp
choco install -y putty
choco install -y bzip2
choco install -y gnuwin32-coreutils.install
choco install -y nsis

rem Install latest Qt 6.8.x using official packages (avoid git-cloned Qt)
set PIPX_HOME=%cd%\pipx_home
set PIPX_BIN_DIR=%cd%\pipx_bin
py -3 -m pip install --user pipx
for /f "usebackq delims=" %%V in (`powershell -NoProfile -Command "$tokens = (py -3 -m pipx run --spec aqtinstall aqt list-qt windows desktop) -split '\s+' | Where-Object {$_ -match '^6\.8\.'}; $latest = $tokens | Sort-Object {[version]$_} | Select-Object -Last 1; Write-Output $latest"`) do set QT_VERSION=%%V
if "%QT_VERSION%"=="" (
    echo ERROR: Unable to resolve latest Qt 6.8.x version
    exit /b 1
)
echo Using QT_VERSION=%QT_VERSION%
echo ##vso[task.setvariable variable=QT_VERSION]%QT_VERSION%

py -3 -m pip install --user --upgrade aqtinstall
py -3 -m aqt install-qt windows desktop  %QT_VERSION% win64_mingw -O Qt
py -3 -m aqt install-tool windows desktop tools_mingw1310 -O Qt

REM Ensure ASan runtime is available in the Qt MinGW toolchain.
set "QT_MINGW_ROOT=%cd%\Qt\Tools\mingw1310_64"
set "QT_MINGW_GCC_LIB="
for /d %%D in ("%QT_MINGW_ROOT%\lib\gcc\x86_64-w64-mingw32\*") do (
    if not defined QT_MINGW_GCC_LIB set "QT_MINGW_GCC_LIB=%%~fD"
)
if not defined QT_MINGW_GCC_LIB (
    echo ERROR: Unable to locate Qt MinGW GCC library directory under %QT_MINGW_ROOT%
    exit /b 1
)

set "QT_LIBASAN="
for /f "delims=" %%F in ('dir /b /s "!QT_MINGW_GCC_LIB!\libasan.dll.a" 2^>nul') do (
    if not defined QT_LIBASAN set "QT_LIBASAN=%%~fF"
)

if not defined QT_LIBASAN (
    echo ASan runtime was not found in Qt MinGW. Installing and copying required ASan files...
    choco install -y msys2
    if not exist "C:\tools\msys64\usr\bin\bash.exe" (
        echo ERROR: MSYS2 installation not found at C:\tools\msys64
        exit /b 1
    )

    C:\tools\msys64\usr\bin\bash.exe -lc "pacman --noconfirm -Sy --needed mingw-w64-x86_64-gcc-libs" || exit /b 1

    set "MSYS_MINGW64=C:\tools\msys64\mingw64"
    for /f "delims=" %%F in ('dir /b /s "!MSYS_MINGW64!\lib\gcc\x86_64-w64-mingw32\*\libasan.dll.a" 2^>nul') do (
        copy /y "%%~fF" "!QT_MINGW_GCC_LIB!\" >nul
    )
    for /f "delims=" %%F in ('dir /b /s "!MSYS_MINGW64!\x86_64-w64-mingw32\lib\libasan*" 2^>nul') do (
        copy /y "%%~fF" "%QT_MINGW_ROOT%\x86_64-w64-mingw32\lib\" >nul
    )
    for /f "delims=" %%F in ('dir /b /s "!MSYS_MINGW64!\bin\libasan*.dll" 2^>nul') do (
        copy /y "%%~fF" "%QT_MINGW_ROOT%\bin\" >nul
    )
)

set "QT_LIBASAN="
for /f "delims=" %%F in ('dir /b /s "!QT_MINGW_GCC_LIB!\libasan.dll.a" 2^>nul') do (
    if not defined QT_LIBASAN set "QT_LIBASAN=%%~fF"
)
if not defined QT_LIBASAN (
    echo ERROR: ASan runtime was not provisioned for Qt MinGW toolchain.
    exit /b 1
)
echo Using ASan import library: !QT_LIBASAN!

choco install -y golang

REM Intsalling rust for minGw
choco install -y rustup.install
rustup toolchain install stable-x86_64-pc-windows-gnu
rustup target add x86_64-pc-windows-gnu
rustup default stable-x86_64-pc-windows-gnu
