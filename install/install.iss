[Setup]
AppName=Fast SysTray
AppVerName=Fast SysTray 1.1.4
DefaultDirName={pf}\FastSysTray
DefaultGroupName=Fast SysTray
UninstallDisplayIcon={uninstallexe}
LicenseFile=licence.txt
WizardImageFile=WizModernImage-IS.bmp
WizardSmallImageFile=WizModernSmallImage-IS.bmp
LanguageDetectionMethod=none

[Languages]
Name: "fr"; MessagesFile: "compiler:Languages\French.isl"; InfoBeforeFile: "texte_avant_installation.txt"; InfoAfterFile: "texte_apres_installation.txt";

[Types]
; Type d'installation
Name: "full"; Description: "Intallation complète";
Name: "executable"; Description: "Intallation des exécutables seulement (sans aide)";
Name: "compact"; Description: "Installation minimum (sans les sources)";
Name: "custom"; Description: "Installation personnalisée"; Flags: iscustom

[Components]
Name: "program"; Description: "Fichier de programmes"; Types: full compact executable custom; Flags: fixed;
Name: "help"; Description: "Aide du programme"; Types: full compact custom;
Name: "sources"; Description: "Source du programme"; Types: full custom;

[Files]
; Fichier exécutable
Source: "..\FastsysTray.exe"; DestDir: "{app}"; Components: program;
Source: "..\fst-run\fst_run.exe"; DestDir: "{app}"; Components: program;
Source: "..\fst-sc\fst_screen_copy.exe"; DestDir: "{app}"; DestName: "fst_sc.exe"; Components: program;
Source: "..\fst-sc\hookdll.dll"; DestDir: "{app}"; Components: program;

; Licence
Source: "licence.txt"; DestDir: "{app}"; Components: program;

; Aide
Source: "..\aide\*"; DestDir: "{app}\aide"; Components: help;

; Source
Source: "..\*"; DestDir: "{app}\source"; Excludes: "*.exe, *.~*, aide"; Flags: recursesubdirs; Components: sources;

[Icons]
Name: "{group}\Fast SysTray"; Filename: "{app}\FastsysTray.exe"; WorkingDir: "{app}"
Name: "{group}\Licence"; Filename: "{app}\licence.txt"; WorkingDir: "{app}"
Name: "{group}\Désinstallation de Fast SysTray"; Filename: "{uninstallexe}"

[Registry]
Root: HKCU; Subkey: "Software\Fast SysTray"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run\Fast SysTray"; Flags: uninsdeletevalue
Root: HKLM; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run\Fast SysTray"; Flags: uninsdeletevalue

[Code]
procedure AboutButtonOnClick(Sender: TObject);
begin
  MsgBox('Système d''instalation de Fast SysTray.'#13#10#13#10'Le système d''installation a été créé grâce à Inno Setup (http://www.innosetup.com).', mbInformation, mb_Ok) ;
end;

procedure InitializeWizard();
var
  AboutButton, CancelButton: TButton;
begin
  { Other custom controls }

  CancelButton := WizardForm.CancelButton;

  AboutButton := TButton.Create(WizardForm);
  AboutButton.Left := WizardForm.ClientWidth - CancelButton.Left - CancelButton.Width;
  AboutButton.Top := CancelButton.Top;
  AboutButton.Width := CancelButton.Width;
  AboutButton.Height := CancelButton.Height;
  AboutButton.Caption := '&A propos de...';
  AboutButton.OnClick := @AboutButtonOnClick;
  AboutButton.Parent := WizardForm;
end;
