[Setup]
AppName=Fast SysTray
AppVerName=Fast SysTray 1.1.1
DefaultDirName={pf}\FastSysTray
DefaultGroupName=Fast SysTray
UninstallDisplayIcon={uninstallexe}
LicenseFile=licence.txt
WizardImageFile=WizModernImage-IS.bmp
WizardSmallImageFile=WizModernSmallImage-IS.bmp
LanguageDetectionMethod=none

[Languages]
Name: "fr"; MessagesFile: "compiler:French.isl"; InfoBeforeFile: "texte_avant_installation.txt"


[Files]
; Fichier exécutable
Source: "..\FastsysTray.exe"; DestDir: "{app}";
Source: "..\fst-run\fst_run.exe"; DestDir: "{app}";
Source: "..\fst-sc\fst_screen_copy.exe"; DestDir: "{app}"; DestName: "fst_sc.exe"
Source: "..\fst-sc\hookdll.dll"; DestDir: "{app}";

; Licence
Source: "licence.txt"; DestDir: "{app}"

; Aide
Source: "..\aide\*"; DestDir: "{app}\aide"

; Source
Source: "..\*"; DestDir: "{app}\source"; Excludes: "*.exe, *.~*, aide"; Flags: recursesubdirs

[Icons]
Name: "{group}\Fast SysTray"; Filename: "{app}\FastsysTray.exe"; WorkingDir: "{app}"
Name: "{group}\Licence"; Filename: "{app}\licence.txt"; WorkingDir: "{app}"
Name: "{group}\Désinstallation de Fast SysTray"; Filename: "{uninstallexe}"

[Registry]
Root: HKCU; Subkey: "Software\Fast SysTray"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run\Fast SysTray"; Flags: uninsdeletevalue
Root: HKLM; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run\Fast SysTray"; Flags: uninsdeletevalue
