
; The name of the installer
Name "Sonic Gesture"

; The file to write
OutFile "sonicgesture-1.0.0.exe"

; The default installation directory
InstallDir $PROGRAMFILES\sonicgesture

; Registry key to check for directory (so if you install again, it will 
; overwrite the old one automatically)
InstallDirRegKey HKLM "Software\sonicgesture" "Install_Dir"

; Request application privileges for Windows Vista
RequestExecutionLevel admin

;--------------------------------

; Pages

Page components
Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

;--------------------------------

; The stuff to install
Section "Sonic Gesture (required)"

  SectionIn RO
  
  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  
  File "result\sonicgesture.exe"

  ; Data
  File /r /x .svn "result\data"

  ; QT stuff
  File "result\QtCore4.dll"
  File "result\QtGui4.dll"

  ; mingw stuff
  File "result\libgcc_s_dw2-1.dll"
  File "result\libstdc++-6.dll"
  File "result\mingwm10.dll"
  
  ; OpenCV stuff
  File "result\libcvaux210.dll"
  File "result\libml210.dll"
  File "result\libcv210.dll"
  File "result\libcxcore210.dll"
  File "result\libhighgui210.dll"
  File "result\libopencv_ffmpeg210.dll"
  

  ; Write the installation path into the registry
  WriteRegStr HKLM SOFTWARE\sonicgesture "Install_Dir" "$INSTDIR"
  
  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\sonicgesture" "DisplayName" "Sonic Gesture"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\sonicgesture" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\sonicgesture" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\sonicgesture" "NoRepair" 1
  WriteUninstaller "uninstall.exe"
  
SectionEnd

; Optional section (can be disabled by the user)
Section "Start Menu Shortcuts"

  CreateDirectory "$SMPROGRAMS\Sonic Gesture"
  CreateShortCut "$SMPROGRAMS\Sonic Gesture\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
  CreateShortCut "$SMPROGRAMS\Sonic Gesture\Sonic Gesture.lnk" "$INSTDIR\sonicgesture.exe" "" "$INSTDIR\sonicgesture.exe" 0
  
SectionEnd

;--------------------------------

; Uninstaller

Section "Uninstall"
  
  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\sonicgesture"
  DeleteRegKey HKLM SOFTWARE\sonicgesture

  ; Remove files and uninstaller
  Delete $INSTDIR\sonicgesture.exe
  Delete $INSTDIR\uninstall.exe
  Delete $INSTDIR\QtCore4.dll
  Delete $INSTDIR\QtGui4.dll
  Delete $INSTDIR\libgcc_s_dw2-1.dll
  Delete $INSTDIR\libstdc++-6.dll
  Delete $INSTDIR\mingwm10.dll
  Delete $INSTDIR\libml210.dll
  Delete $INSTDIR\libcv210.dll
  Delete $INSTDIR\libcxcore210.dll
  Delete $INSTDIR\libhighgui210.dll
  Delete $INSTDIR\libcvaux210.dll
  Delete $INSTDIR\libopencv_ffmpeg210.dll


  ; Remove shortcuts, if any
  Delete "$SMPROGRAMS\Sonic Gesture\*.*"

  ; Remove directories used
  RMDir /r $INSTDIR\result\data
  RMDir /r "$SMPROGRAMS\Sonic Gesture"
  RMDir /r "$INSTDIR"

SectionEnd
