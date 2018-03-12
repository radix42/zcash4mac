;This file will be executed next to the application bundle image
;I.e. current directory will contain folder winzec with application files
[Setup]
AppId={{wallet}}
AppName=winzec
AppVersion=1.0.5-248
AppVerName=winzec 1.0.5-248
AppPublisher=The MercerWeiss Collective
AppComments=winzec
AppCopyright=Copyright (C) 2018 The MercerWeiss Collective
AppPublisherURL=http://winzec.com
;AppSupportURL=http://java.com/
;AppUpdatesURL=http://java.com/
DefaultDirName={localappdata}\winzec
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
OutputBaseFilename=winzec-1.0.5-248
Compression=lzma
SolidCompression=yes
PrivilegesRequired=lowest
SetupIconFile=winzec\winzec.ico
UninstallDisplayIcon={app}\winzec.ico
UninstallDisplayName=winzec
WizardImageStretch=No
WizardSmallImageFile=winzec-setup-icon.bmp   
ArchitecturesInstallIn64BitMode=x64


[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "winzec\winzec.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "winzec\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\winzec"; Filename: "{app}\winzec.exe"; IconFilename: "{app}\winzec.ico"; Check: returnTrue()
Name: "{commondesktop}\winzec"; Filename: "{app}\winzec.exe";  IconFilename: "{app}\winzec.ico"; Check: returnFalse()


[Run]
Filename: "{app}\winzec.exe"; Parameters: "-Xappcds:generatecache"; Check: returnFalse()
Filename: "{app}\winzec.exe"; Description: "{cm:LaunchProgram,winzec}"; Flags: nowait postinstall skipifsilent; Check: returnTrue()
Filename: "{app}\winzec.exe"; Parameters: "-install -svcName ""winzec"" -svcDesc ""winzec"" -mainExe ""winzec.exe""  "; Check: returnFalse()

[UninstallRun]
Filename: "{app}\winzec.exe "; Parameters: "-uninstall -svcName winzec -stopOnUninstall"; Check: returnFalse()

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
