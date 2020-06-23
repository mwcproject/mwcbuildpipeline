!define APP_NAME   "MWC"
!define REG_DIR    "Software\${APP_NAME}"
!define VER_MAJOR  1
!define VER_MINOR  0
!define VER_PATCH  REPLACE_VERSION_PATCH
!define VER_PRE    "-INTERNAL"
!define VER_DISP   "${VER_MAJOR}.${VER_MINOR}.${VER_PATCH}"


Name "${APP_NAME} ${VER_DISP}"
OutFile "mwc-qt-wallet-${VER_DISP}-${ARCH_LONG}-setup.exe"

InstallDirRegKey HKCU "${REG_DIR}" ""

RequestExecutionLevel admin

Var StartMenuFolder


; style
!define MUI_ABORTWARNING
!define MUI_UNABORTWAARNING

!define MUI_ICON   "resources\logo.ico"
!define MUI_UNICON "resources\logo.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "resources\header.bmp"
!define MUI_HEADERIMAGE_RIGHT


; installer flow
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "resources\license.txt"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY

!define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKCU" 
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${REG_DIR}" 
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "StartMenu"
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "${APP_NAME}"
!insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder

!insertmacro MUI_PAGE_INSTFILES

Function CreateDesktopShortcut
  CreateShortcut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\mwc-qt-wallet.exe"
FunctionEnd

!define MUI_FINISHPAGE_SHOWREADME ""
!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
!define MUI_FINISHPAGE_SHOWREADME_TEXT "Create Desktop Shortcut"
!define MUI_FINISHPAGE_SHOWREADME_FUNCTION CreateDesktopShortcut
!define MUI_FINISHPAGE_RUN "$INSTDIR\mwc-qt-wallet.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Run MWC Qt Wallet now"
!insertmacro MUI_PAGE_FINISH


; uninstaller flow
!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH


; language
!insertmacro MUI_LANGUAGE "English"

!include "include\lang\en.nsh"
