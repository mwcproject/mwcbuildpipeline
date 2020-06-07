Section "MWC GUI" SecMain
  SectionIn RO ; required

  SetOutPath "$INSTDIR"
    File "payload\${ARCH_SHORT}\mwc-qt-wallet.exe"

  ; create uninstaller
  WriteUninstaller "$INSTDIR\uninstall.exe"

  ; create Start Menu shortcut
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
    CreateShortcut  "$SMPROGRAMS\$StartMenuFolder\${APP_NAME} GUI.lnk" "$INSTDIR\mwc-qt-wallet.exe"
  !insertmacro MUI_STARTMENU_WRITE_END

  ; write Add/Remove info to registry
  WriteRegStr   HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" \
                     "DisplayIcon" "$INSTDIR\mwc-qt-wallet.exe"
  WriteRegStr   HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" \
                     "DisplayName" "${APP_NAME}"
  WriteRegStr   HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" \
                     "DisplayVersion" "${VER_DISP}"
  ; TODO: DWORD EstimatedSize
  WriteRegStr   HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" \
                     "InstallLocation" "$INSTDIR\"
  WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" \
                     "NoModify" 1
  WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" \
                     "NoRepair" 1
  WriteRegStr   HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" \
                     "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
  WriteRegStr   HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" \
                     "URLInfoAbout" "https://mwc.mw"
  WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" \
                     "VersionMajor" ${VER_MAJOR}
  WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" \
                     "VersionMinor" ${VER_MINOR}

SectionEnd

Section "Prerequisites" SecPrerequisites
  SectionIn RO 

  SetOutPath $INSTDIR\Prerequisites

  ; install MSVC redist, needed for mwc713
  ReadRegStr $1 HKLM "SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\${ARCH_SHORT}" \
                     "Installed"
  StrCmp $1 1 skip_vcredist
  
  File "payload\${ARCH_SHORT}\vc_redist.${ARCH_SHORT}.exe"
  ExecWait '$INSTDIR\Prerequisites\vc_redist.${ARCH_SHORT}.exe /quiet'

  skip_vcredist:
SectionEnd

Section "mwc713" SecMWC713
  SectionIn RO ; TODO: make optional

  SetOutPath "$INSTDIR"
    File "payload\${ARCH_SHORT}\mwc713.exe"

  SetOutPath "$INSTDIR"
    File "payload\${ARCH_SHORT}\mwczip.exe"

  SetOutPath "$INSTDIR"
    File "payload\${ARCH_SHORT}\mwc.exe"

  SetOutPath "$INSTDIR"
    File "payload\${ARCH_SHORT}\tor.exe"

  SetOutPath "$INSTDIR\bearer\"
    File "payload\${ARCH_SHORT}\bearer\"

  SetOutPath "$INSTDIR\iconengines\"
    File "payload\${ARCH_SHORT}\iconengines\"

  SetOutPath "$INSTDIR\imageformats\"
    File "payload\${ARCH_SHORT}\imageformats\"

  SetOutPath "$INSTDIR\platforms\"
    File "payload\${ARCH_SHORT}\platforms\"

  SetOutPath "$INSTDIR\styles\"
    File "payload\${ARCH_SHORT}\styles\"

  SetOutPath "$INSTDIR\translations\"
    File "payload\${ARCH_SHORT}\translations\"

  SetOutPath "$INSTDIR"
    File "payload\${ARCH_SHORT}\D3Dcompiler_47.dll"

  SetOutPath "$INSTDIR"
    File "payload\${ARCH_SHORT}\libevent-2-1-7.dll"

  SetOutPath "$INSTDIR"
    File "payload\${ARCH_SHORT}\libevent_core-2-1-7.dll"

  SetOutPath "$INSTDIR"
    File "payload\${ARCH_SHORT}\libevent_extra-2-1-7.dll"

  SetOutPath "$INSTDIR"
    File "payload\${ARCH_SHORT}\libgcc_s_sjlj-1.dll"

  SetOutPath "$INSTDIR"
    File "payload\${ARCH_SHORT}\libssp-0.dll"

  SetOutPath "$INSTDIR"
    File "payload\${ARCH_SHORT}\zlib1.dll"

  SetOutPath "$INSTDIR"
    File "payload\${ARCH_SHORT}\libEGL.dll"

  SetOutPath "$INSTDIR"
    File "payload\${ARCH_SHORT}\libGLESV2.dll"

  SetOutPath "$INSTDIR"      
    File "payload\${ARCH_SHORT}\opengl32sw.dll"

  SetOutPath "$INSTDIR"      
    File "payload\${ARCH_SHORT}\Qt5Core.dll"

  SetOutPath "$INSTDIR"      
    File "payload\${ARCH_SHORT}\Qt5Gui.dll"

  SetOutPath "$INSTDIR"      
    File "payload\${ARCH_SHORT}\Qt5Network.dll"

  SetOutPath "$INSTDIR"      
    File "payload\${ARCH_SHORT}\Qt5Svg.dll"

  SetOutPath "$INSTDIR"      
    File "payload\${ARCH_SHORT}\Qt5Widgets.dll"

  SetOutPath "$INSTDIR"
    File "payload\${ARCH_SHORT}\libgcc_s_dw2-1.dll"

  SetOutPath "$INSTDIR"
    File "payload\${ARCH_SHORT}\libstdc++-6.dll"

  SetOutPath "$INSTDIR"
    File "payload\${ARCH_SHORT}\libwinpthread-1.dll"

  SetOutPath "$INSTDIR"
    File "payload\${ARCH_SHORT}\vcruntime140.dll"

  SetOutPath "$INSTDIR"
    File "payload\${ARCH_SHORT}\libcrypto-1_1.dll"

  SetOutPath "$INSTDIR"
    File "payload\${ARCH_SHORT}\libssl-1_1.dll"

  ; create Start Menu shortcut
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
    CreateShortcut  "$SMPROGRAMS\$StartMenuFolder\MWC713.lnk" "$INSTDIR\mwc713.exe" "--config $PROFILE\mwc-qt-wallet\wallet713v2.toml"
  !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd


Section "Uninstall"
  !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
  Delete "$SMPROGRAMS\$StartMenuFolder\${APP_NAME} GUI.lnk"
  Delete "$SMPROGRAMS\$StartMenuFolder\MWC713.lnk"
  RMDir  "$SMPROGRAMS\$StartMenuFolder"

  Delete "$DESKTOP\${APP_NAME}.lnk"

  RMDir  /r "$INSTDIR"

  DeleteRegValue HKCU "${REG_DIR}" "StartMenu"
  DeleteRegKey /ifempty HKCU "${REG_DIR}"

  DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
SectionEnd


!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecMain} $(DESC_SecMain)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecMWC713} $(DESC_SecMWC713)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecPrerequisites} $(DESC_SecPrerequisites)
!insertmacro MUI_FUNCTION_DESCRIPTION_END
