;This file will be executed next to the application bundle image
;I.e. current directory will contain folder zcash4win with application files
[Setup]
AppId={{wallet}}
AppName=zcash4win
AppVersion=@version@
AppVerName=zcash4win @version@
AppPublisher=MercerWeiss Consulting
AppComments=zcash4win
AppCopyright=Copyright (C) 2017 David Mercer
AppPublisherURL=http://zcash4win.com
;AppSupportURL=http://java.com/
;AppUpdatesURL=http://java.com/
DefaultDirName={localappdata}\zcash4win
DisableStartupPrompt=Yes
DisableDirPage=Yes
DisableProgramGroupPage=Yes
DisableReadyPage=Yes
DisableFinishedPage=Yes
DisableWelcomePage=Yes
DefaultGroupName=Unknown
;Optional License
LicenseFile=license.txt
;Win7 or above
MinVersion=0,6.1 
OutputBaseFilename=zcash4win-@version@
Compression=lzma
SolidCompression=yes
PrivilegesRequired=lowest
SetupIconFile=zcash4win\zcash4win.ico
UninstallDisplayIcon={app}\zcash4win.ico
UninstallDisplayName=zcash4win
WizardImageStretch=No
WizardSmallImageFile=zcash4win-setup-icon.bmp   
ArchitecturesInstallIn64BitMode=x64


[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "zcash4win\zcash4win.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "zcash4win\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\zcash4win"; Filename: "{app}\zcash4win.exe"; IconFilename: "{app}\zcash4win.ico"; Check: returnTrue()
Name: "{commondesktop}\zcash4win"; Filename: "{app}\zcash4win.exe";  IconFilename: "{app}\zcash4win.ico"; Check: returnFalse()


[Run]
Filename: "{app}\zcash4win.exe"; Parameters: "-Xappcds:generatecache"; Check: returnFalse()
Filename: "{app}\zcash4win.exe"; Description: "{cm:LaunchProgram,zcash4win}"; Flags: nowait postinstall skipifsilent; Check: returnTrue()
Filename: "{app}\zcash4win.exe"; Parameters: "-install -svcName ""zcash4win"" -svcDesc ""zcash4win"" -mainExe ""zcash4win.exe""  "; Check: returnFalse()

[UninstallRun]
Filename: "{app}\zcash4win.exe "; Parameters: "-uninstall -svcName zcash4win -stopOnUninstall"; Check: returnFalse()

[Code]
function returnTrue(): Boolean;
begin
  Result := True;
end;

function returnFalse(): Boolean;
begin
  Result := False;
end;

function InitializeSetup(): Boolean;
begin
// Possible future improvements:
//   if version less or same => just launch app
//   if upgrade => check if same app is running and wait for it to exit
//   Add pack200/unpack200 support? 
  Result := True;
end;  
