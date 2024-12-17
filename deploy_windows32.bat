setlocal enableextensions enabledelayedexpansion
@echo on

set /p NUMBER_GLOBAL=<version.txt

echo "Param passed in is %1"
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
set NAME=mwc-qt-wallet-!VERSION!-win32-setup.exe
set NAME_UPLOAD=mwc-qt-wallet_!VERSION!-win32-setup.exe
) ELSE (
set NAME=mwc-qt-wallet-1.2.!NUMBER_GLOBAL!.beta.%1-win32-setup.exe
set NAME_UPLOAD=mwc-qt-wallet_1.2.!NUMBER_GLOBAL!.beta.%1-win32-setup.exe
)
echo "Using %NAME%"

sha256sum target\nsis\%NAME%

ls -l target\\nsis

rem Say 'n' for trusting certificate
pscp -scp -P 22 -pw %2  -batch -hostkey "ssh-ed25519 255 SHA256:FY3NMOUpHofoUyVyTynch3lICRSEOylPmMCJo7Y5Huo" target\nsis\%NAME% uploader@ftp.mwc.mw:/home/uploader/%NAME_UPLOAD%

endlocal


