setlocal enableextensions enabledelayedexpansion
echo "param passed in %1"
md5sum target\\nsis\\mwc-qt-wallet*-setup.exe
mkdir %systemdrive%%homepath%\.ssh
echo ftp.mwc.mw ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFCzEhIbZcESW50l2Mh9dFIeObKrDBNwZm+FPZzL3tp7U8xkcH0U7rx87cMDUKUfJnO8soJ3yqxf1RXOrFkXKQM= >> %systemdrive%%homepath%\.ssh\known_hosts

for /f "skip=1 tokens=1-6 delims= " %%a in ('wmic path Win32_LocalTime Get Day^,Hour^,Minute^,Month^,Second^,Year /Format:table') do (
    IF NOT "%%~f"=="" (
        set /a FormattedDate=10000 * %%f + 100 * %%d + %%a
        set FormattedDate=!FormattedDate:~-4,2!-!FormattedDate:~-2,2!-!FormattedDate:~-6,2!
    )
)

set TAG_FOR_BUILD_FILE=mwc-qt-wallet.version
IF EXIST "%TAG_FOR_BUILD_FILE%" (
set /p VERSION=<mwc-qt-wallet.version
echo "version = !VERSION!"
set NAME=mwc-qt-wallet-!VERSION!-win64-setup.exe
set NAME_UPLOAD=mwc-qt-wallet-!VERSION!-win64-setup-%CPU_PACKAGE_NAME%.exe
) ELSE (
set NAME=mwc-qt-wallet-1.0.19.beta.%1-win64-setup.exe
set NAME_UPLOAD=mwc-qt-wallet-1.0.19.beta.%1-win64-setup-%CPU_PACKAGE_NAME%.exe
)
echo "Using %NAME% and %NAME_UPLOAD%"
ls -l target\\nsis

rem Say 'y' for trusting certificate
echo y | pscp -scp -i uploader.ppk target\nsis\%NAME% uploader@3.228.53.68:/home/uploader/%NAME_UPLOAD%

endlocal
