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
py -3 -m aqt install-qt windows desktop  %QT_VERSION% win64_msvc2022_64 -O Qt

choco install -y golang

REM Installing rust for MSVC
choco install -y rustup.install
rustup toolchain install stable-x86_64-pc-windows-msvc
rustup target add x86_64-pc-windows-msvc
rustup default stable-x86_64-pc-windows-msvc
