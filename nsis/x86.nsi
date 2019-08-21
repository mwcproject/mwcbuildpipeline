!include "MUI2.nsh"

!define ARCH_SHORT "x86"
!define ARCH_LONG  "win32"

!include "include\config.nsh"


; 32-bit config

InstallDir "$PROGRAMFILES\${APP_NAME}"

;


!include "include\sections.nsh"
