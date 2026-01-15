Section "MWC GUI" SecMain
  SectionIn RO ; required

  SetOutPath "$INSTDIR"
    File "payload\${ARCH_SHORT}\mwc-qt-wallet.exe"

  SetOutPath "$INSTDIR"
    File "payload\${ARCH_SHORT}\webtunnelclient.exe"

  SetOutPath "$INSTDIR"
    File "payload\${ARCH_SHORT}\*.dll"

  SetOutPath "$INSTDIR\generic\"
    File "payload\${ARCH_SHORT}\generic\"

  SetOutPath "$INSTDIR\iconengines\"
    File "payload\${ARCH_SHORT}\iconengines\"

  SetOutPath "$INSTDIR\imageformats\"
      File "payload\${ARCH_SHORT}\imageformats\"

  SetOutPath "$INSTDIR\networkinformation\"
    File "payload\${ARCH_SHORT}\networkinformation\"

  SetOutPath "$INSTDIR\platforms\"
    File "payload\${ARCH_SHORT}\platforms\"

  SetOutPath "$INSTDIR\styles\"
    File "payload\${ARCH_SHORT}\styles\"

  SetOutPath "$INSTDIR\tls\"
    File "payload\${ARCH_SHORT}\tls\"

  SetOutPath "$INSTDIR\translations\"
    File "payload\${ARCH_SHORT}\translations\"

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

Section "Uninstall"
  !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
  Delete "$SMPROGRAMS\$StartMenuFolder\${APP_NAME} GUI.lnk"
  RMDir  "$SMPROGRAMS\$StartMenuFolder"

  Delete "$DESKTOP\${APP_NAME}.lnk"

  RMDir  /r "$INSTDIR"

  DeleteRegValue HKCU "${REG_DIR}" "StartMenu"
  DeleteRegKey /ifempty HKCU "${REG_DIR}"

  DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
SectionEnd


!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecMain} $(DESC_SecMain)
!insertmacro MUI_FUNCTION_DESCRIPTION_END
