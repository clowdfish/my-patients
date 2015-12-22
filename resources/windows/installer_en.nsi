!include LogicLib.nsh
!include nsDialogs.nsh

; --------------------------------
; Variables
; --------------------------------

!define dest "{{dest}}"
!define src "{{src}}"
!define data "{{data}}"
!define name "{{name}}"
!define productName "{{productName}}"
!define version "{{version}}"
!define icon "{{icon}}"
!define banner "{{banner}}"

!define exec "{{productName}}.exe"

!define regkey "Software\${productName}"
!define uninstkey "Software\Microsoft\Windows\CurrentVersion\Uninstall\${productName}"

!define uninstaller "uninstall.exe"

; --------------------------------
; Installation
; --------------------------------

SetCompressor lzma

Name "${productName}"
Icon "${icon}"
OutFile "${dest}"
InstallDir "$PROGRAMFILES\${productName}"
InstallDirRegKey HKLM "${regkey}" ""

CRCCheck on
SilentInstall normal

XPStyle on
ShowInstDetails nevershow
AutoCloseWindow false
WindowIcon off

Caption "${productName} Setup"
; Don't add sub-captions to title bar
SubCaption 3 " "
SubCaption 4 " "

Page custom welcome
Page instfiles

Var Image
Var ImageHandle

Function .onInit

		; Extract banner image for welcome page
		InitPluginsDir
		ReserveFile "${banner}"
		File /oname=$PLUGINSDIR\banner.bmp "${banner}"

FunctionEnd

; Custom welcome page
Function welcome

		nsDialogs::Create 1018

		${NSD_CreateLabel} 185 1u 210 100% "Welcome to ${productName} version ${version} installer.$\r$\n$\r$\nClick install to begin."

		${NSD_CreateBitmap} 0 0 170 210 ""
		Pop $Image
		${NSD_SetImage} $Image $PLUGINSDIR\banner.bmp $ImageHandle

		nsDialogs::Show

		${NSD_FreeImage} $ImageHandle

FunctionEnd

; Installation declarations
Section "Install"

		WriteRegStr HKLM "${regkey}" "Install_Dir" "$INSTDIR"
		WriteRegStr HKLM "${uninstkey}" "DisplayName" "${productName}"
		WriteRegStr HKLM "${uninstkey}" "DisplayIcon" '"$INSTDIR\icon.ico"'
		WriteRegStr HKLM "${uninstkey}" "UninstallString" '"$INSTDIR\${uninstaller}"'

        ${If} ${FileExists} "$LOCALAPPDATA\${name}"
            ; do nothing to avoid overwriting user data
        ${Else}
            ; Create AppData directory
            CreateDirectory "$LOCALAPPDATA\${name}"
            CreateDirectory "$LOCALAPPDATA\${name}\data"

            ; Include all app data from /build/data directory
            SetOutPath "$LOCALAPPDATA\${name}\data"
            File /r "${data}\*"
        ${EndIf}

		; Remove all application files copied by previous installation
		RMDir /r "$INSTDIR"

		SetOutPath $INSTDIR

		; Include all files from /build directory
		File /r "${src}\*"

		; Create start menu shortcut
		CreateShortCut "$SMPROGRAMS\${productName}.lnk" "$INSTDIR\${exec}" "" "$INSTDIR\icon.ico"

		WriteUninstaller "${uninstaller}"

SectionEnd

; --------------------------------
; Uninstaller
; --------------------------------

ShowUninstDetails nevershow

UninstallCaption "Uninstall ${productName}"
UninstallText "Don't like ${productName} anymore? Hit uninstall button."
UninstallIcon "${icon}"

UninstPage custom un.confirm un.confirmOnLeave
UninstPage instfiles

Var RemoveAppDataCheckbox
Var RemoveAppDataCheckbox_State

; Custom uninstall confirm page
Function un.confirm

		nsDialogs::Create 1018

		${NSD_CreateLabel} 1u 1u 100% 24u "If you really want to remove ${productName} from your computer press uninstall button."

		${NSD_CreateCheckbox} 1u 35u 100% 10u "Remove also my ${productName} personal data"
		Pop $RemoveAppDataCheckbox

		nsDialogs::Show

FunctionEnd

Function un.confirmOnLeave

		; Save checkbox state on page leave
		${NSD_GetState} $RemoveAppDataCheckbox $RemoveAppDataCheckbox_State

FunctionEnd

; Uninstall declarations
Section "Uninstall"

		DeleteRegKey HKLM "${uninstkey}"
		DeleteRegKey HKLM "${regkey}"

		Delete "$SMPROGRAMS\${productName}.lnk"

		; Remove whole directory from Program Files
		RMDir /r "$INSTDIR"

		; Remove also appData directory generated by your app if user checked this option
		${If} $RemoveAppDataCheckbox_State == ${BST_CHECKED}
				RMDir /r "$LOCALAPPDATA\${name}"
		${EndIf}

SectionEnd