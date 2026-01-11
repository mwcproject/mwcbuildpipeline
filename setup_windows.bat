@echo on

rem need putty for scp
choco install -y putty
choco install -y bzip2
choco install -y gnuwin32-coreutils.install
choco install -y nsis

set PATH="C:\Program Files (x86)\GnuWin32\bin";%PATH%

rem Install latest Qt 6.8.x using official packages (avoid git-cloned Qt)
py -3 -m pip install --user aqtinstall
for /f "usebackq delims=" %%V in (`powershell -NoProfile -Command "$vers = py -3 -m aqt list-qt windows desktop | Select-String -Pattern '^6\.8\.' | ForEach-Object {($_.ToString() -split '\s+')[0]}; $latest = $vers | Sort-Object {[version]$_} | Select-Object -Last 1; Write-Output $latest"`) do set QT_VERSION=%%V
if "%QT_VERSION%"=="" (
    echo ERROR: Unable to resolve latest Qt 6.8.x version
    exit /b 1
)
echo Using QT_VERSION=%QT_VERSION%
echo ##vso[task.setvariable variable=QT_VERSION]%QT_VERSION%
py -3 -m aqt install-qt windows desktop %QT_VERSION% mingw_64 -O Qt
py -3 -m aqt install-tool windows desktop tools_mingw1310 -O Qt

choco install -y llvm
choco install -y openssl
choco install -y rust-ms
choco install -y golang
