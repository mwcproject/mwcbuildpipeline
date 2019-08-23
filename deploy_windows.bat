echo "param passed in %1"
md5sum target\\nsis\\mwc-qt-wallet-1.0.5-win64-setup.exe
mkdir %systemdrive%%homepath%\.ssh
echo ftp.mwc.mw ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFCzEhIbZcESW50l2Mh9dFIeObKrDBNwZm+FPZzL3tp7U8xkcH0U7rx87cMDUKUfJnO8soJ3yqxf1RXOrFkXKQM= >> %systemdrive%%homepath%\.ssh\known_hosts


SETLOCAL EnableDelayedExpansion

for /f "skip=1 tokens=1-6 delims= " %%a in ('wmic path Win32_LocalTime Get Day^,Hour^,Minute^,Month^,Second^,Year /Format:table') do (
    IF NOT "%%~f"=="" (
        set /a FormattedDate=10000 * %%f + 100 * %%d + %%a
        set FormattedDate=!FormattedDate:~-4,2!-!FormattedDate:~-2,2!-!FormattedDate:~-6,2!
    )
)

set NAME=mwc-qt-wallet-1.0-5.beta.%1-win64-setup.exe
ls -l target\nsis
copy target\nsis\mwc-qt-wallet-1.0-5-win64-setup.exe target\nsis\%NAME%
echo y | pscp -pw uploader target\nsis\%NAME% uploader@ftp.mwc.mw:/home/uploader/
