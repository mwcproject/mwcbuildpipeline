!include "MUI2.nsh"

!define ARCH_SHORT "x64"
!define ARCH_LONG  "win64"

!include "include\config.nsh"


; 64-bit config

InstallDir "$PROGRAMFILES64\${APP_NAME}"

Function .onInit
  SetRegView 64
FunctionEnd

Function un.onInit
  SetRegView 64
FunctionEnd

;


!include "include\sections.nsh"
