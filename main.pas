{*******************************************************************************
 * Copyright (C) 2004 MARTINEAU Emeric (php4php@free.fr)
 *
 * Fast SysTray
 *
 * Version 1.0.0
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation; either version 2 of the License, or (at your option) any later
 * version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
 * Place, Suite 330, Boston, MA 02111-1307 USA
 *
 ******************************************************************************}

{*******************************************************************************
 * Liste des images pour les menus. Numéro d'index et à quoi elles correspondent
 * ImageList1 :
 *                 0 : quitter,
 *                 1 : arrêter,
 *                 2 : redémarer,
 *                 3 : logoff,
 *                 4 : préférence,
 *                 5 : mise en veille,
 *                 6 : ecran de veille,
 *                 7 : verrouiller
 *                 8 : hibernation
 *                 9 : exécuter
 *                10 : capture d'écran
 *                11 : aide
 ******************************************************************************}

unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Menus, ShellApi, ComCtrls, filectrl, MMSystem, Registry,
  ComObj, ShlObj, ActiveX, ImgList, XPTheme, BoiteCreerRacourci, Clipbrd;

const
  TrayIconMessage = WM_USER + 100 ;
  CHEMIN_REGISTRE = 'Software\Fast SysTray' ;
  { Utilise pour ExitWindowsEx pour Windows 2003 }
  SHTDN_REASON_MAJOR_APPLICATION  = $00040000 ;

type
  TForm1 = class(TForm)
    ImageList1: TImageList;
    BoutonEnregistrerConfiguration: TButton;
    BoutonAnnuler: TButton;
    TabControl1: TTabControl;
    { GroupeBox de l'onglet Menu}
    GroupBoxMenu1: TGroupBox;
    GroupBoxMenu2: TGroupBox;
    { Case à cocher de l'onglet Menu}
    CocheMenuVeille: TCheckBox;
    CocheMenuVerrouiller: TCheckBox;
    CocheMenuArreter: TCheckBox;
    CocheMenuRentrerDisques: TCheckBox;
    CocheMenuEjecterDisques: TCheckBox;
    CocheMenuDisques: TCheckBox;
    CocheMenuDisquesLabel: TCheckBox;
    GroupBoxMenu3: TGroupBox;
    CocheMenuCapturerEcran: TCheckBox;
    CocheMenuExecuter: TCheckBox;
    GroupBoxGeneral2: TGroupBox;
    RaccourciBureau: TCheckBox;
    RaccourciLacementRapide: TCheckBox;
    RaccourciDemarrer: TCheckBox;
    GroupBoxGeneral1: TGroupBox;
    LancerAutoOrdi: TCheckBox;
    LancerAutoUser: TCheckBox;
    CocheMenuGraphisme: TCheckBox;
    AjouterRac: TButton;
    ModifierRac: TButton;
    SupprimerRac: TButton;
    DescendreRac: TButton;
    MonterRac: TButton;
    ajouterSeparateur: TButton;
    Timer1: TTimer;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    site_internet: TLabel;
    Memo1: TMemo;
    ListBoxRac: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BoutonEnregistrerConfigurationClick(Sender: TObject);
    procedure BoutonAnnulerClick(Sender: TObject);
    procedure LancerAutoOrdiClick(Sender: TObject);
    procedure LancerAutoUserClick(Sender: TObject);
    procedure TabControl1Change(Sender: TObject);
    procedure CocheMenuDisquesClick(Sender: TObject);
    procedure AjouterRacClick(Sender: TObject);
    procedure ModifierRacClick(Sender: TObject);
    procedure ListBoxRacClick(Sender: TObject);
    procedure ajouterSeparateurClick(Sender: TObject);
    procedure SupprimerRacClick(Sender: TObject);
    procedure MonterRacClick(Sender: TObject);
    procedure DescendreRacClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure site_internetClick(Sender: TObject);
  public
    ListRacCmd : TStringList ;                          // Liste contenant les commandes des raccourcis du menu
    ListRacArg : TStringList ;                          // Liste contenant les arguments de la ligne de commandes des raccourcis du menu    
  private
    { Déclarations privées}
    NewPopUpMenu1 : TPopupMenu ;                        // contient le menu PopUp
    IWantReallyExit : Boolean ;                         // Indique si on doit quitter l'application. Utilise pour CloseQuery()
    ListeDesLecteurs : TDriveComboBox ;                 // Liste des lecteurs présents sur la machine
    ListItemDuMenuPopUp : array of TMenuitem ;          // Contient les menus
    NbList : Integer ;                                  // Pointeur sur la dernière entrée du menu
    ListItemEjecterDisque : array of TMenuitem ;        // Contient les menus pour l'ejection
    ListItemRentrerDisque : array of TMenuitem ;        // Contient les menus pour rentrer les disques
    NbListjecterDisque : Integer ;                      // Pointeur sur la dernière entrée du menu
    IconData: TNotifyIconData;                          // structure contenant les données pour l'icone
    proc:function : BOOL; stdcall;                      // Pointe sur la fonction LockWorkStation
    procedure ajouterMenuArretWindows ;                 // Ajoute le menu arrêt windows
    procedure ajouterMenuFastSysTray ;                  // ajoute le menu de l'application
    procedure ajouterMenuSeparateur ;                   // Ajoute un séparateur dans le menu
    procedure ajouterLecteur ;                          // Ajoute les lecteurs présents
    procedure ajouterMesProgrammes ;                    // Ajoute le menu Mes Programmes
    procedure AfficherLecteur(Sender: TObject) ;        // Lance l'explorateur sur le lecteur
    procedure Quitter(Sender: TObject) ;                // quitte le programme
    procedure Preferences(Sender: TObject) ;            // Affiche la fenêtre de préférence
    procedure ShutDownWindows(Sender: TObject) ;        // Arrête le micro
    procedure RebootWindows(Sender: TObject) ;          // Redémarre l'ordi
    procedure LoggOffWindows(Sender: TObject) ;         // Ferme la session
    procedure LockWindows(Sender: TObject) ;            // Verrouille la session
    procedure EjecterLecteur(Sender: TObject) ;         // ejecte le lecteur
    procedure RentrerLecteur(Sender: TObject) ;         // Rentre le lecteur
    procedure EcranDeVeilleWindows(Sender: TObject) ;   // Ecran de veille
    procedure MiseEnVeilleWindows(Sender: TObject) ;    // Mise en veille
    { déclaration de la procédure qui interceptera les messages que windows envoie
      lorsqu'il veut se fermer à savoir WM_QUERYENDSESSION }
    procedure WMQueryEndSession(var Message: TWMQueryEndSession); message WM_QUERYENDSESSION;
    procedure SauveMenuConfig(Registre : TRegistry) ;   // Enregistre dans la base de registre lea config des menus.
    procedure LitMenuConfig(Registre : TRegistry)  ;    // Lit dans la base de registre la config des menus.
    procedure SauveGeneralConfig() ;                    // Enregistre dans la base de registre lea config des menus.
    procedure LitGeneralConfig() ;                      // Lit dans la base de registre la config des menus.
    procedure LireEnregistrerConfig(Lire : Boolean) ;   // Lit ou enregistre la config
    function  litChemRepRegist(sCle : string): string;  // Lit les répertoires système
    procedure AjouteIcone;                              // Ajoute l'icone SysTray
    procedure SupprimeIcone;                            // Enlève l'icone systay
    procedure WMTrayIconMessage(var Msg: TMessage);     // gestion des...
      message TrayIconMessage;                          // ...messages (clics souris) venant de l'icone
    procedure CreerMenu ;                               // Créer le menu
    procedure ShowTabMenus(status : Boolean) ;          // Affiche le contenu de l'onglet Menus
    procedure ShowTabGeneral(status : Boolean) ;        // Affiche le contenu de l'onglet Général
    procedure ShowTabMesProgrammes(status : Boolean) ;  // Affiche le contenu de l'onglet Mes Programmes
    procedure ShowTabAPropos(status : Boolean) ;        // Affiche le contenu de l'onglet A propos
    function  tokenPrivilege : Boolean ;                // Prend les privilège pour redémarrer/arrêter/hiberner windows
    procedure HibernateWindows(Sender: TObject) ;       // Redémarre l'ordi
    procedure SauveMesProgrammesConfig() ;              // Enregistre les raccourci Mes Programmes
    procedure LitMesProgrammesConfig() ;                // Lit les raccourcis Mes Programmes
    Function  IsPrevInstance : HWND ;                   // Indique s'il y a déjà une occurence du programme en cours
    procedure LancerMesProgrammes(Sender: TObject) ;    // Lance le raccourci Mes Programmes
    procedure ajouterMenuOutils;                        // ajoute le menu outil
    procedure Executer(Sender: TObject) ;               // Lancer la boite exécuter
    procedure CopieDEcran(Sender: TObject) ;            // Copie l'écran de le presse papier
    procedure afficherAide(Sender: TObject) ;           // Affiche l'aide
    procedure MenueMeasureItem(Sender: TObject; ACanvas: TCanvas; var Width, Height: Integer);
    procedure MenueDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect;
      Selected: Boolean);

    { Déclarations publiques}
  end;

var
  Form1: TForm1;
  NouveauMenu : TMenuitem ;


implementation

{$R *.DFM}

{*******************************************************************************
 * Affiche le contenu de l'onglet A propos
 ******************************************************************************}
procedure TForm1.ShowTabAPropos(status : Boolean) ;
begin
    Panel1.Visible := Status ;
end;

{*******************************************************************************
 * Affiche le contenu de l'onglet Mes programmes
 ******************************************************************************}
procedure TForm1.ShowTabMesProgrammes(status : Boolean) ;
begin
    ListBoxRac.Visible := status ;
    AjouterRac.Visible := status ;
    ModifierRac.Visible := status ;
    SupprimerRac.Visible := status ;
    MonterRac.Visible := status ;
    DescendreRac.Visible := status ;
    ajouterSeparateur.Visible := Status ;
end;

{*******************************************************************************
 * cette fonction renvoie 0 s'il n'y a pas d'instance du même programme déjà
 * lancée sinon le handle de l'instance déjà lancée c'est à dire une valeur <>0
 * cette fonction est appelé dans le source du projet. voir ce source pour
 * comprendre.
 ******************************************************************************}
Function TForm1.IsPrevInstance : HWND ;
Var ClassName:Array[0..255] of char;
    TitreApplication:string;
Begin
    result := 0 ;
    TitreApplication := Application.Title ;
    { on change le titre car sinon, on trouverait toujours une application déjà
      lancée (la notre!) }
    Application.Title := '' ;
    try
        { met dans ClassName le nom de la class de l'application }
        GetClassName(Application.handle, ClassName, 254) ;
        { renvoie le Handle de la première fenêtre de Class (type) ClassName et
          de titre TitreApplication (0 s'il n'y en a pas) }
        result := FindWindow(ClassName,PChar(TitreApplication)) ;
    finally
        { restauration du vrai titre }
        Application.Title := TitreApplication ;
    end;
end;

{*******************************************************************************
 * Affiche le contenu de l'onglet Menus
 ******************************************************************************}
procedure TForm1.ShowTabMenus(status : Boolean) ;
begin
    GroupBoxMenu1.Visible := Status ;
    GroupBoxMenu2.Visible := Status ;
    GroupBoxMenu3.Visible := Status ;
    CocheMenuGraphisme.Visible := Status ;
end;

{*******************************************************************************
 * Affiche le contenu de l'onglet Menus
 ******************************************************************************} 
procedure TForm1.ShowTabGeneral(status : Boolean) ;
begin
    GroupBoxGeneral1.Visible := Status ;
    GroupBoxGeneral2.Visible := Status ;
end;

{*******************************************************************************
 * Met Windows en hibernation
 ******************************************************************************}
procedure TForm1.HibernateWindows(Sender: TObject) ;
begin
    if Application.MessageBox('Etes-vous sûr de vouloir mettre Windows en hibernation ?', 'Hibernation de Windows', MB_YESNO or MB_ICONQUESTION) = IDYES
    then
        if tokenPrivilege
        then
            SetSystemPowerState(False, False) ;
end;

{*******************************************************************************
 * Prend les privilèges adéquates
 ******************************************************************************}
function TForm1.tokenPrivilege : Boolean ;
var
    sTokenIn,sTokenOut : TTOKENPRIVILEGES ;
    dwLen : DWORD ;
    hCurrentProcess,hToken : THANDLE ;
    Luid1 : TLargeInteger ;
begin
    Result := True ;

    try
        { Point sur notre processus }
        hCurrentProcess := GetCurrentProcess ;
        { ajuste les privilèges, nécessaire pour Windows XP }
        OpenProcessToken(hCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY,hToken) ;
        LookupPrivilegeValue(nil, 'SeShutdownPrivilege', Luid1) ;
        sTokenIn.Privileges[0].Luid := Luid1 ;
        sTokenIn.PrivilegeCount := 1 ;
        sTokenIn.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED ;
        AdjustTokenPrivileges(hToken, FALSE, sTokenIn,sizeof(TTOKENPRIVILEGES), sTokenOut,dwLen) ;
        CloseHandle(hToken) ;
    except
        Application.MessageBox('Impossible d''acquérire les privilèges nécéssaires. Opération annulées', 'Erreur', MB_ICONERROR or MB_OK) ;
        Result := False ;
    end ;

    application.ProcessMessages ;
end ;

{*******************************************************************************
 * Lit les répertoires windows
 ******************************************************************************}
function TForm1.litChemRepRegist(sCle : string): string;
var
    Registe : TRegistry;
begin
    Registe := TRegistry.Create;
    try
        Registe.RootKey := HKEY_CURRENT_USER ;

        if Registe.OpenKey('\software\microsoft\windows\currentversion\explorer\shell folders', False)
        then
            result:= Registe.ReadString(sCle);

    finally
        Registe.CloseKey;
        Registe.Free;
    end;
end;

{*******************************************************************************
 * Lit la config générale dans la base de registre
 ******************************************************************************}
procedure TForm1.LitGeneralConfig() ;
Var Registre : TRegistry ;
    temp : String ;
begin
    Registre := TRegistry.Create ;

    try
        { Lancer au démarrage de l'ordi }
        Registre.RootKey := HKEY_LOCAL_MACHINE ;
        Registre.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True) ;

        LancerAutoOrdi.Checked := Registre.ValueExists('Fast SysTray') ;

        if LancerAutoOrdi.Checked
        then
            LancerAutoUser.Enabled := False ;

        { Lancer au démarrage de la session }
        Registre.RootKey := HKEY_CURRENT_USER ;
        Registre.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True) ;

        LancerAutoUser.Checked := Registre.ValueExists('Fast SysTray') ;

        if LancerAutoUser.Checked
        then
            LancerAutoOrdi.Enabled := False ;

        Registre.CloseKey ;
    finally
        Registre.Free ;
    end ;

    { Raccourci sur le bureau }
    temp := litChemRepRegist('Desktop') + '\Fast SysTray.lnk' ;
    RaccourciBureau.Checked := FileExists(temp) ;

    { Raccourci dans le menu démarrer }
    temp := litChemRepRegist('Start Menu') + '\Fast SysTray\Fast SysTray.lnk' ;
    RaccourciDemarrer.Checked := FileExists(temp) ;

    { Raccourci du Quick Lauch }
    temp := litChemRepRegist('AppData') + '\Microsoft\Internet Explorer\Quick Launch\Fast SysTray.lnk' ;
    RaccourciLacementRapide.Checked := FileExists(temp) ;
end ;

{*******************************************************************************
 * Enregistre la config générale dans la base de registre
 ******************************************************************************}
procedure TForm1.SauveGeneralConfig() ;
Var Registre : TRegistry ;
    ShellLink : IShellLink ;
    temp : String ;
begin
    Registre := TRegistry.Create ;

    try
        Registre.RootKey := HKEY_LOCAL_MACHINE ;
        Registre.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True) ;

        { Lancement au démarage de l'odinateur }
        if LancerAutoOrdi.Checked = True
        then begin
            Registre.WriteString('Fast SysTray', Application.ExeName) ;
        end
        else begin
            { Si on ne lance pas au démarrage de l'ordi on supprime la clef }
            Registre.DeleteValue('Fast SysTray') ;

            { Lancement au démarrage de la session }
            Registre.RootKey := HKEY_CURRENT_USER ;
            Registre.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True) ;

            if LancerAutoUser.Checked = True
            then begin
                Registre.WriteString('Fast SysTray', Application.ExeName) ;
            end
            else
                Registre.DeleteValue('Fast SysTray') ;
        end ;

        Registre.CloseKey ;
    finally
        Registre.Free ;
    end ;

    { Créer un objet lien}
    ShellLink := CreateComObject(CLSID_ShellLink) as IShellLink ;
    { Description du racourci }
    // Ne fonctionne pas !
    // ShellLink.SetDescription(PChar('Fast SysTray')) ;
    { Fichier sur lequel on créer le raccourci }
    ShellLink.SetPath(PChar(Application.ExeName)) ;
    ShellLink.SetShowCmd(SW_SHOW) ;

    { Raccourci sur le bureau }
    temp := litChemRepRegist('Desktop') + '\Fast SysTray.lnk' ;

    if (RaccourciBureau.Checked = True)
    then
        { Ne recréer pas le fichier inutile }
        if not FileExists(temp)
        then
            { Enregistre le fichier }
            (ShellLink as IpersistFile).Save(StringToOleStr(temp), true)
    else
        DeleteFile(temp) ;

    { Raccourci dans le menu démarrer }
    temp := litChemRepRegist('Start Menu') + '\Fast SysTray' ;

    if RaccourciDemarrer.Checked
    then begin
        { Ne recréer pas le fichier inutile }
        if not FileExists(temp + '\Fast SysTray.lnk')
        then begin
            { Créer le répertoire }
            {I-}
            MkDir(temp) ;
            {I+}
            { Enregistre le fichier }
            (ShellLink as IpersistFile).Save(StringToOleStr(temp + '\Fast SysTray.lnk'), true) ;
        end ;
    end
    else begin
        DeleteFile(temp + '\Fast SysTray.lnk') ;
        {$I-}
        RmDir(temp) ;
        {$I+}
    end ;

    { Raccourci du Quick Lauch }
    if RaccourciLacementRapide.Enabled
    then begin
        temp := litChemRepRegist('AppData') + '\Microsoft\Internet Explorer\Quick Launch\Fast SysTray.lnk' ;

        if (RaccourciLacementRapide.Checked = True)
        then begin
            { Ne recréer pas le fichier inutile }
            if not FileExists(temp)
            then
                { Enregistre le fichier }
                (ShellLink as IpersistFile).Save(StringToOleStr(temp), true) ;
        end
        else
            DeleteFile(temp) ;
    end ;
end ;

{*******************************************************************************
 * Enregistre la config des menus dans la base de registre
 ******************************************************************************}
procedure TForm1.SauveMenuConfig(Registre : TRegistry) ;
begin
    { Menu Arrêter }
    Registre.WriteBool('MenuArreter', CocheMenuArreter.Checked) ;
    { Menu Verrouiller }
    if @proc <> nil
    then
        Registre.WriteBool('MenuVerrouiller', CocheMenuVerrouiller.Checked) ;

    { Menu Veille }
    Registre.WriteBool('MenuVeille', CocheMenuVeille.Checked) ;
    { Menu RentrerDisques }
    Registre.WriteBool('MenuRentrerDisques', CocheMenuRentrerDisques.Checked) ;
    { Menu EjecterDisques }
    Registre.WriteBool('MenuEjecterDisques', CocheMenuEjecterDisques.Checked) ;
    { Menu Disques }
    Registre.WriteBool('MenuDisques', CocheMenuDisques.Checked) ;
    { Menu Disques Label }
    Registre.WriteBool('MenuDisquesLabel', CocheMenuDisquesLabel.Checked) ;
    { Menu Graphisme }
    Registre.WriteBool('MenuGraphisme', CocheMenuGraphisme.Checked) ;
    { Menu Capturer Ecran }
    Registre.WriteBool('MenuCapturerEcran', CocheMenuCapturerEcran.Checked) ;
    { Menu Executer }
    Registre.WriteBool('MenuExecuter', CocheMenuExecuter.Checked) ;

end ;

{*******************************************************************************
 * Enregistre la config des menus dans la base de registre
 ******************************************************************************}
procedure TForm1.LitMenuConfig(Registre : TRegistry) ;
begin
    { Menu Arrêter }
    if Registre.ValueExists('MenuArreter')
    then
        CocheMenuArreter.Checked := Registre.ReadBool('MenuArreter')
    else begin
        CocheMenuArreter.Checked := True ;
        Registre.WriteBool('MenuArreter', CocheMenuArreter.Checked) ;
    end ;

    { Menu Verrouiller }
    if @proc <> nil
    then
        if Registre.ValueExists('MenuVerrouiller')
        then
            CocheMenuVerrouiller.Checked := Registre.ReadBool('MenuVerrouiller')
        else begin
            CocheMenuVerrouiller.Checked := True ;
            Registre.WriteBool('MenuVerrouiller', CocheMenuVerrouiller.Checked) ;
        end
    else
        CocheMenuVerrouiller.Checked := False ;

    { Menu Veille }
    if Registre.ValueExists('MenuVeille')
    then
        CocheMenuVeille.Checked := Registre.ReadBool('MenuVeille')
    else begin
        CocheMenuVeille.Checked := True ;
        Registre.WriteBool('MenuVeille', CocheMenuVeille.Checked) ;
    end ;

    { Menu RentrerDisques }
    if Registre.ValueExists('MenuRentrerDisques')
    then
        CocheMenuRentrerDisques.Checked := Registre.ReadBool('MenuRentrerDisques')
    else begin
        CocheMenuRentrerDisques.Checked := True ;
        Registre.WriteBool('MenuRentrerDisques', CocheMenuRentrerDisques.Checked) ;
    end ;

    { Menu EjecterDisques }
    if Registre.ValueExists('MenuEjecterDisques')
    then
        CocheMenuEjecterDisques.Checked := Registre.ReadBool('MenuEjecterDisques')
    else begin
        CocheMenuEjecterDisques.Checked := True ;
        Registre.WriteBool('MenuEjecterDisques', CocheMenuEjecterDisques.Checked) ;
    end ;

    { Menu Disques }
    if Registre.ValueExists('MenuDisques')
    then
        CocheMenuDisques.Checked := Registre.ReadBool('MenuDisques')
    else begin
        CocheMenuDisques.Checked := True ;
        Registre.WriteBool('MenuDisques', CocheMenuDisques.Checked) ;
    end ;

    CocheMenuDisquesLabel.Enabled := CocheMenuDisques.Checked ;

    { Menu Disques }
    if CocheMenuDisquesLabel.Enabled
    then
        if Registre.ValueExists('MenuDisquesLabel')
        then
            CocheMenuDisquesLabel.Checked := Registre.ReadBool('MenuDisquesLabel')
        else begin
            CocheMenuDisquesLabel.Checked := True ;
            Registre.WriteBool('MenuDisquesLabel', CocheMenuDisquesLabel.Checked) ;
        end ;

    { Menu Disques }
    if Registre.ValueExists('MenuGraphisme')
    then
        CocheMenuGraphisme.Checked := Registre.ReadBool('MenuGraphisme')
    else begin
        CocheMenuGraphisme.Checked := False ;
        Registre.WriteBool('MenuGraphisme', CocheMenuGraphisme.Checked) ;
    end ;

    { Menu Capturer Ecran }
    if Registre.ValueExists('MenuCapturerEcran')
    then
        CocheMenuCapturerEcran.Checked := Registre.ReadBool('MenuCapturerEcran')
    else begin
        CocheMenuCapturerEcran.Checked := True ;
        Registre.WriteBool('MenuCapturerEcran', CocheMenuCapturerEcran.Checked) ;
    end ;

    { Menu Exécuter }
    if Registre.ValueExists('MenuExecuter')
    then
        CocheMenuExecuter.Checked := Registre.ReadBool('MenuExecuter')
    else begin
        CocheMenuExecuter.Checked := True ;
        Registre.WriteBool('MenuExecuter', CocheMenuExecuter.Checked) ;
    end ;    
end ;

{*******************************************************************************
 * Procédure appelée pour Lire ou Enregistrer la config
 ******************************************************************************}
procedure TForm1.LireEnregistrerConfig(Lire : Boolean) ;
Var Registre : TRegistry ;
begin
    Registre := TRegistry.Create ;

    Registre.RootKey := HKEY_CURRENT_USER ;

    try
        Registre.OpenKey(CHEMIN_REGISTRE, True) ;

        if Lire = True
        then begin
            LitMenuConfig(Registre) ;
            LitGeneralConfig ;

            if ListBoxRac.Items.Count <= 0
            then
                LitMesProgrammesConfig ;
        end
        else begin
            SauveMenuConfig(Registre) ;
            SauveGeneralConfig ;
            SauveMesProgrammesConfig() ;
        end ;

        Registre.CloseKey ;
    finally
        Registre.Free ;
    end ;
end;

{*******************************************************************************
 * Procédure appelée quand Windows se ferme
 ******************************************************************************}
procedure TForm1.WMQueryEndSession(var Message: TWMQueryEndSession);
begin
  IWantReallyExit := True ;
  inherited;
end;

{*******************************************************************************
 * Lance la mise en veille
 ******************************************************************************}
procedure TForm1.MiseEnVeilleWindows(Sender: TObject) ;
begin
    PostMessage(Application.Handle, WM_SYSCOMMAND, SC_MONITORPOWER, 1);
end ;

{*******************************************************************************
 * Lance l'écran de veille
 ******************************************************************************}
procedure TForm1.EcranDeVeilleWindows(Sender: TObject) ;
begin
    PostMessage(GetDesktopWindow, WM_SYSCOMMAND, SC_SCREENSAVE, 0) ;
end ;

{*******************************************************************************
 * Verrouille la session
 ******************************************************************************}
procedure TForm1.LockWindows(Sender: TObject) ;
begin
    if @proc <> nil
    then
        proc ;
end ;


{*******************************************************************************
 * REntre le lecteur
 ******************************************************************************}
procedure TForm1.RentrerLecteur(Sender: TObject) ;
Var
  Res : MciError;
  OpenParm: TMCI_Open_Parms;
  Flags : DWord;
  S : String;
  DeviceID : Word;
begin
    { Lecteur }
    S := ListeDesLecteurs.Items[(Sender as TMenuItem).Tag][1] + ':' ;

    { Flag pour l'ouverture }
    Flags := mci_Open_Type or mci_Open_Element ;

    { Construit la structure pour l'ejection }
    With OpenParm do begin
        dwCallback := 0 ;
        lpstrDeviceType := 'CDAudio' ;
        lpstrElementName := PChar(S) ;
    end ;

    { Envoie la commande d'éjection }
    Res := mciSendCommand(0, mci_Open, Flags, Longint(@OpenParm)) ;

    { Si Res = 0, C'est que l'ejection n'a pas fonctionné }
    if Res = 0
    then begin
        DeviceID := OpenParm.wDeviceID ;

        try
            mciSendCommand(DeviceID, MCI_SET, MCI_SET_DOOR_CLOSED, 0) ;
        finally
            mciSendCommand(DeviceID, mci_Close, Flags, Longint(@OpenParm));
        end;
    end ;
end ;

{*******************************************************************************
 * Ejecte le lecteur
 ******************************************************************************}
procedure TForm1.EjecterLecteur(Sender: TObject) ;
Var
  Res : MciError;
  OpenParm: TMCI_Open_Parms;
  Flags : DWord;
  S : String;
  DeviceID : Word;
begin
    { Lecteur }
    S := ListeDesLecteurs.Items[(Sender as TMenuItem).Tag][1] + ':' ;

    { Flag pour l'ouverture }
    Flags := mci_Open_Type or mci_Open_Element ;

    { Construit la structure pour l'ejection }
    With OpenParm do begin
        dwCallback := 0 ;
        lpstrDeviceType := 'CDAudio' ;
        lpstrElementName := PChar(S) ;
    end ;

    { Envoie la commande d'éjection }
    Res := mciSendCommand(0, mci_Open, Flags, Longint(@OpenParm)) ;

    { Si Res = 0, C'est que l'ejection n'a pas fonctionné }
    if Res = 0
    then begin
        DeviceID := OpenParm.wDeviceID ;

        try
            mciSendCommand(DeviceID, MCI_SET, MCI_SET_DOOR_OPEN, 0) ;
        finally
            mciSendCommand(DeviceID, mci_Close, Flags, Longint(@OpenParm));
        end;
    end ;
end ;

{*******************************************************************************
 * Affiche l'explorateur avec le lecteur demandé
 ******************************************************************************}
procedure TForm1.AfficherLecteur(Sender: TObject) ;
var lecteur : String ;
begin
    lecteur := ListeDesLecteurs.Items[(Sender as TMenuItem).Tag][1] + ':\' ;

    ShellExecute(Handle, 'EXPLORE', PChar(lecteur), '','',SW_SHOWNORMAL);
end ;

{*******************************************************************************
 * Ajoute les lecteurs
 ******************************************************************************}
procedure TForm1.ajouterLecteur ;
Var
    i : Integer ;
    Bmp1 : TBitmap ;
    TypeLecteur : Integer ;
    ShInfo1 : SHFILEINFO ;
    NbLecteur : Integer ;
//    NouveauMenu : TMenuitem ;
begin

    { Créer le BMP }
    Bmp1 := TBitmap.Create() ;
    { Définir la couleur de transparence }
    Bmp1.Canvas.Brush.Color := clMenu ;
    Bmp1.Canvas.Pen.Color := clMenu ;
    { Active la transparence. Prend le pixel 1:1 }
    Bmp1.Transparent := True ;
    Bmp1.Width := 16;
    Bmp1.Height := 16;

    { Récupère le nombre de lecteur }
    NbLecteur := ListeDesLecteurs.Items.Count - 1 ;

    if (CocheMenuRentrerDisques.Checked = True) or (CocheMenuEjecterDisques.Checked = True)
    then begin
        NbListjecterDisque := 0 ;

        { Ajoute les Lecteur }
        For i := 0 to NbLecteur do
        Begin
            { Lit le type de lecteur }
            TypeLecteur := GetDriveType(PChar(ListeDesLecteurs.Items[i][1] + ':\')) ;

            { Si c'est un CD-ROM ou un disque amovible, ils peuvent être ejecté }
            if (TypeLecteur = DRIVE_CDROM) //or (TypeLecteur = DRIVE_REMOVABLE)
            then begin
                { Efface l'icone pour le prochaine icone }
                Bmp1.Canvas.Rectangle(0, 0, 16, 16) ;

                { Récupère les informations liés au lecteur }
                SHGetFileInfo(PChar(ListeDesLecteurs.Items[i][1] + ':\'), 0, ShInfo1, sizeOF(SHFILEINFO), SHGFI_ICON or SHGFI_SMALLICON) ;

                { Dessine l'icône }
                DrawIconEx(Bmp1.Canvas.Handle, 0, 0, ShInfo1.hIcon, 0, 0, 0, 0, DI_NORMAL) ;

                NbListjecterDisque := NbListjecterDisque + 1 ;

                if (CocheMenuEjecterDisques.Checked = True)
                then begin
                    { Ejecter }
                    NouveauMenu := TMenuItem.Create(Self);
                    NouveauMenu.Caption := 'Ejecter ' + ListeDesLecteurs.Items[i][1] + ':\' ;
                    NouveauMenu.OnClick := EjecterLecteur ;
                    NouveauMenu.Tag := i ;
                    NouveauMenu.Bitmap.Assign(Bmp1) ;
                    NouveauMenu.Name := 'ME' + IntToStr(i) ;

                    SetLength(ListItemEjecterDisque, NbListjecterDisque) ;

                    ListItemEjecterDisque[NbListjecterDisque - 1] := NouveauMenu ;

                    { On ne libère surtout pas le menu
                    NouveauMenu.Free ;
                    }
                end ;

                if (CocheMenuRentrerDisques.Checked = True)
                then begin
                    { Rentrer }
                    NouveauMenu := TMenuItem.Create(Self);
                    NouveauMenu.Caption := 'Fermer ' + ListeDesLecteurs.Items[i][1] + ':\' ;
                    NouveauMenu.OnClick := RentrerLecteur ;
                    NouveauMenu.Tag := i ;
                    NouveauMenu.Bitmap.Assign(Bmp1) ;
                    NouveauMenu.Name := 'MR' + IntToStr(i) ;

                    SetLength(ListItemRentrerDisque, NbListjecterDisque) ;

                    ListItemRentrerDisque[NbListjecterDisque - 1] := NouveauMenu ;

                    { On ne libère surtout pas le menu
                    NouveauMenu.Free ;
                    }
                end ;
            end ;
        end ;

        if (CocheMenuEjecterDisques.Checked = True)
        then begin
            { Enregistre le sous-menu Ejecter }
            NbList := NbList + 1 ;
            SetLength(ListItemDuMenuPopUp, NbList) ;
            ListItemDuMenuPopUp[NbList - 1] := NewSubMenu('Ejecter les disques', 0, 'SubItemEjecterCD' , ListItemEjecterDisque, True) ;
        end ;

        if (CocheMenuRentrerDisques.Checked = True)
        then begin
            { Enregistre le sous-menu Rentrer }
            NbList := NbList + 1 ;
            SetLength(ListItemDuMenuPopUp, NbList) ;
            ListItemDuMenuPopUp[NbList - 1] := NewSubMenu('Fermer les disques', 0, 'SubItemRentrerCD' , ListItemRentrerDisque, True) ;
        end ;

        { Ajoute un Séparateur }
        ajouterMenuSeparateur ;
    end ;

    if (CocheMenuDisques.Checked = True)
    then begin
        { Liste des Disque à Explorer }
        For i := 0 to NbLecteur do
        Begin
            { Efface l'icone pour le prochaine icone }
            Bmp1.Canvas.Rectangle(0, 0, 16, 16) ;

            { Récupère les informations liés au lecteur }
            SHGetFileInfo(PChar(ListeDesLecteurs.Items[i][1] + ':\'), 0, ShInfo1, sizeOF(SHFILEINFO), SHGFI_ICON or SHGFI_SMALLICON) ;

            { Dessine l'icône }
            DrawIconEx(Bmp1.Canvas.Handle, 0, 0, ShInfo1.hIcon, 0, 0, 0, 0, DI_NORMAL) ;

            NouveauMenu := TMenuItem.Create(Self);

            if CocheMenuDisquesLabel.Checked
            then
                NouveauMenu.Caption := ListeDesLecteurs.Items[i]
            else
                NouveauMenu.Caption := ListeDesLecteurs.Items[i][1] + ':\' ;

            NouveauMenu.OnClick := AfficherLecteur ;
            NouveauMenu.Tag := i ;
            NouveauMenu.Bitmap.Assign(Bmp1) ;
            NouveauMenu.Name := 'MD' + IntToStr(i) ;

            NbList := NbList + 1 ;
            SetLength(ListItemDuMenuPopUp, NbList) ;

            ListItemDuMenuPopUp[NbList - 1] := NouveauMenu ;
        end ;

        { Ajoute un Séparateur }
        ajouterMenuSeparateur ;
    end ;

    Bmp1.Free
end ;

{*******************************************************************************
 * Ajoute un séparateur dans le menu
 ******************************************************************************}
procedure TForm1.ajouterMenuSeparateur ;
//Var
//    NouveauMenu : TMenuitem ;
begin
    {** Séparateur **}
    NouveauMenu := TMenuItem.Create(Self);
    NouveauMenu.Caption := '-' ;
    NouveauMenu.OnClick := nil ;
    NouveauMenu.Name := 'N' + IntToStr(NbList) ;

    NbList := NbList + 1 ;
    SetLength(ListItemDuMenuPopUp, NbList) ;

    ListItemDuMenuPopUp[NbList - 1] := NouveauMenu ;
end ;

{*******************************************************************************
 * Ajoute le menu FastSysTray
 ******************************************************************************}
procedure TForm1.ajouterMenuFastSysTray ;
begin
    {** Aide **}
    NouveauMenu := TMenuItem.Create(Self);
    NouveauMenu.Caption := 'Aide' ;
    NouveauMenu.OnClick := afficherAide ;
    NouveauMenu.ImageIndex := 11 ;
    NouveauMenu.Name := 'MAide' ;

    NbList := NbList + 1 ;
    SetLength(ListItemDuMenuPopUp, NbList) ;

    ListItemDuMenuPopUp[NbList - 1] := NouveauMenu ;

    {** Préférence **}
    NouveauMenu := TMenuItem.Create(Self);
    NouveauMenu.Caption := 'Préférences' ;
    NouveauMenu.OnClick := Preferences ;
    NouveauMenu.ImageIndex := 4 ;
    NouveauMenu.Name := 'MPref' ;

    NbList := NbList + 1 ;
    SetLength(ListItemDuMenuPopUp, NbList) ;

    ListItemDuMenuPopUp[NbList - 1] := NouveauMenu ;

    {** Quitter **}
    NouveauMenu := TMenuItem.Create(Self);
    NouveauMenu.Caption := 'Quitter Fast SysTray' ;
    NouveauMenu.OnClick := Quitter ;
    NouveauMenu.ImageIndex := 0 ;
    NouveauMenu.Name := 'MQuit' ;

    NbList := NbList + 1 ;
    SetLength(ListItemDuMenuPopUp, NbList) ;

    ListItemDuMenuPopUp[NbList - 1] := NouveauMenu ;
end ;

{*******************************************************************************
 * Quitte le programme
 ******************************************************************************}
procedure TForm1.Quitter(Sender: TObject) ;
begin
    if Application.MessageBox('Etes-vous sûr de vouloir quitter Fast SysTray ?', 'Quitter', MB_YESNO or MB_ICONQUESTION) = IDYES
    then begin
        IWantReallyExit := True ;
        SupprimeIcone ;
        Application.Terminate ;
    end ;
end ;

{*******************************************************************************
 * Affiche la fenêtre
 ******************************************************************************}
procedure TForm1.Preferences(Sender: TObject) ;
begin
    Show ;
end ;

{*******************************************************************************
 * Eteind l'ordinateur
 ******************************************************************************}
procedure TForm1.ShutDownWindows(Sender: TObject) ;
var osVer: OSVERSIONINFO;
begin
    if Application.MessageBox('Etes-vous sûr de vouloir arrêter Windows ?', 'Arrêt de Windows', MB_YESNO or MB_ICONQUESTION) = IDYES
    then
        if tokenPrivilege()
        then begin
            osVer.dwOSVersionInfoSize := Sizeof(osVer);
            GetVersionEx(osVer);

            { test pour la version de windows (9x ou XP) }
            if osVer.dwPlatformId = VER_PLATFORM_WIN32_WINDOWS
            then
                ExitWindowsEx(EWX_SHUTDOWN or EWX_FORCEIFHUNG , 0) // 95
            else
                ExitWindowsEx(EWX_POWEROFF or EWX_FORCEIFHUNG , SHTDN_REASON_MAJOR_APPLICATION) ;
        end ;
end ;

{*******************************************************************************
 * Redémarrer l'ordinateur
 ******************************************************************************}
procedure TForm1.RebootWindows(Sender: TObject) ;
begin
    if Application.MessageBox('Etes-vous sûr de vouloir redémarrer Windows ?', 'Redémarrer de Windows', MB_YESNO or MB_ICONQUESTION) = IDYES
    then
        if tokenPrivilege()
        then begin
            ExitWindowsEx(EWX_REBOOT or EWX_FORCEIFHUNG, SHTDN_REASON_MAJOR_APPLICATION) ;
        end ;
end ;

{*******************************************************************************
 * LoggOff l'ordinateur
 ******************************************************************************}
procedure TForm1.LoggOffWindows(Sender: TObject) ;
begin
    if Application.MessageBox('Etes-vous sûr de vouloir redémarrer Windows ?', 'Redémarrer de Windows', MB_YESNO or MB_ICONQUESTION) = IDYES
    then
        ExitWindowsEx(EWX_LOGOFF or EWX_FORCEIFHUNG, SHTDN_REASON_MAJOR_APPLICATION) ;
end ;

{*******************************************************************************
 * Ajoute le menu Windows Arrêter/Redémarrer/Fermer session
 ******************************************************************************}
procedure TForm1.ajouterMenuArretWindows ;
Var
//    NouveauMenu : TMenuitem ;
    Sep : Boolean ;
begin
    { Indique s'il faut mettre un séparateur en fin }
    Sep := False ;

    if (CocheMenuArreter.Checked = True)
    then begin
        Sep := True ;

        {** Arrêter **}
        NouveauMenu := TMenuItem.Create(Self);
        NouveauMenu.Caption := 'Arrêter Windows' ;
        NouveauMenu.OnClick := ShutDownWindows ;
        NouveauMenu.ImageIndex := 1 ;
        NouveauMenu.Name := 'MArr' ;

        NbList := NbList + 1 ;
        SetLength(ListItemDuMenuPopUp, NbList) ;

        ListItemDuMenuPopUp[NbList - 1] := NouveauMenu ;

        {** Redémarrer **}
        NouveauMenu := TMenuItem.Create(Self);
        NouveauMenu.Caption := 'Redémarrer Windows' ;
        NouveauMenu.OnClick := RebootWindows ;
        NouveauMenu.ImageIndex := 2 ;
        NouveauMenu.Name := 'MRebo' ;

        NbList := NbList + 1 ;
        SetLength(ListItemDuMenuPopUp, NbList) ;

        ListItemDuMenuPopUp[NbList - 1] := NouveauMenu ;

        {** LogOff **}
        NouveauMenu := TMenuItem.Create(Self);
        NouveauMenu.Caption := 'Fermer session' ;
        NouveauMenu.OnClick := LoggOffWindows ;
        NouveauMenu.ImageIndex := 3 ;
        NouveauMenu.Name := 'MLogO' ;

        NbList := NbList + 1 ;
        SetLength(ListItemDuMenuPopUp, NbList) ;

        ListItemDuMenuPopUp[NbList - 1] := NouveauMenu ;
    end ;

    if @proc <> nil
    then
        if (CocheMenuVerrouiller.Checked = True)
        then begin
            Sep := True ;

            NouveauMenu := TMenuItem.Create(Self);
            NouveauMenu.Caption := 'Verrouiller session' ;
            NouveauMenu.OnClick := LockWindows ;
            NouveauMenu.ImageIndex := 7 ;
            NouveauMenu.Name := 'MVerr' ;

            NbList := NbList + 1 ;
            SetLength(ListItemDuMenuPopUp, NbList) ;

            ListItemDuMenuPopUp[NbList - 1] := NouveauMenu ;
        end ;

    if (CocheMenuVeille.Checked = True)
    then begin

        if Sep = True
        then
            ajouterMenuSeparateur ;

        Sep := True ;

        {** Ecran de veille **}
        NouveauMenu := TMenuItem.Create(Self);
        NouveauMenu.Caption := 'Ecran de veille' ;
        NouveauMenu.OnClick := EcranDeVeilleWindows ;
        NouveauMenu.ImageIndex := 6 ;
        NouveauMenu.Name := 'MEV' ;

        NbList := NbList + 1 ;
        SetLength(ListItemDuMenuPopUp, NbList) ;

        ListItemDuMenuPopUp[NbList - 1] := NouveauMenu ;

        {** Mise en veille **}
        NouveauMenu := TMenuItem.Create(Self);
        NouveauMenu.Caption := 'Mise en veille' ;
        NouveauMenu.OnClick := MiseEnVeilleWindows ;
        NouveauMenu.ImageIndex := 5 ;
        NouveauMenu.Name := 'MMEV' ;

        NbList := NbList + 1 ;
        SetLength(ListItemDuMenuPopUp, NbList) ;

        ListItemDuMenuPopUp[NbList - 1] := NouveauMenu ;

        {** Hibernation **}
        NouveauMenu := TMenuItem.Create(Self);
        NouveauMenu.Caption := 'Hibernation' ;
        NouveauMenu.OnClick := HibernateWindows ;
        NouveauMenu.ImageIndex := 8 ;
        NouveauMenu.Name := 'MHIB' ;

        NbList := NbList + 1 ;
        SetLength(ListItemDuMenuPopUp, NbList) ;

        ListItemDuMenuPopUp[NbList - 1] := NouveauMenu ;
    end ;

    { Ajoute un séparateur }
    if Sep = True
    then
        ajouterMenuSeparateur ;
end ;

{*******************************************************************************
 * Ajoute l'icône SysTray
 ******************************************************************************}
procedure TForm1.AjouteIcone;
begin
  { structure de type TNotifyIconData (voir shellapi.pas) }
  with IconData do
  begin
    { Prend l'icone du programme }
    hIcon := LoadIcon(HInstance, 'MAINICON') ;
    { Taille de la structure de l'icone }
    cbSize := SizeOf(IconData) ;
    { Handle de l'icone }
    Wnd := Handle ;
    { Identifiant de l'icone }
    uID := 0 ;
    { Titre de l'icone }
    StrPCopy(szTip, 'FastSysTray') ;
    { Procédure traitant le message provenant de l'icone SysTray }
    uCallBackMessage := TrayIconMessage ;
    { Champs utilisé }
    uFlags := NIF_ICON or NIF_TIP or NIF_MESSAGE ;
  end;
  { ajout de l'icone (utilise ShellApi) }
  Shell_NotifyIcon(NIM_ADD, @IconData) ;
end;

{*******************************************************************************
 * Supprime l'icône SysTray
 ******************************************************************************}
procedure TForm1.SupprimeIcone;
begin
  { l'ID de l'icone suffit pour l'identifier }
  IconData.uID := 0 ;
  { suppression de cette icone }
  Shell_NotifyIcon(NIM_DELETE, @IconData) ;
end;

{*******************************************************************************
 * Gestion du Clic Droit et du Double Clic provenant de la Tray Icon
 ******************************************************************************}
procedure TForm1.WMTrayIconMessage(var Msg: TMessage);  // voir Messages.pas
begin
    case Msg.LParam of
        WM_RBUTTONUP : CreerMenu ;
        WM_LBUTTONUP : CreerMenu ;
    end;
end;

{*******************************************************************************
 * Création de la feuille
 ******************************************************************************}
procedure TForm1.FormCreate(Sender: TObject);
Var osVer : OSVERSIONINFO ;
    Registre : TRegistry ;
    Fenetre : HWND ;
    handle : integer ;
begin
    { Vérifie que la fonction LockWorkStation existe. Winodws NT seulement }
    Handle := LoadLibrary('user32.dll');

    if Handle <> 0
    then
        @proc := GetProcAddress(Handle, 'LockWorkStation') ;


    FreeLibrary(Handle);

    { Vérifie qu'il n'y a pas déjà un occurence de lancée }
    Fenetre := IsPrevinstance ;

    If IsPrevinstance <> 0
    then
        if Application.MessageBox('Fast SysTray est déjà lancé, voulez-vous le relancer ?', 'Question', MB_YESNO or MB_ICONQUESTION) = IDYES
        then
            SendMessage(Fenetre, WM_CLOSE, 0, 0)
        else
            Close ;

    { Créer la liste des commandes }
    ListRacCmd := TStringList.Create() ;
    ListRacArg := TStringList.Create() ;

    if @proc = nil
    then
        CocheMenuVerrouiller.Enabled := False ;

    { Par défaut on ne veut pas réellement quitter }
    IWantReallyExit := False ;

    { Lit la config }
    LireEnregistrerConfig(True) ;

    osVer.dwOSVersionInfoSize := Sizeof(osVer);
    GetVersionEx(osVer);

    { test pour la version de windows (9x ou XP) }
    if osVer.dwPlatformId = VER_PLATFORM_WIN32_WINDOWS
    then
        CocheMenuVerrouiller.Enabled := False ; // Windows 9x

    { Vérifie qu'il y a IE4 et + pour le Quick Lauch }
    Registre := TRegistry.Create ;

    try
        Registre.RootKey := HKEY_LOCAL_MACHINE ;
        Registre.OpenKey('Software\Microsoft', False) ;

        if not Registre.KeyExists('Active Setup')
        then
            RaccourciLacementRapide.Enabled := False ;

        Registre.CloseKey ;
    finally
        Registre.Free ;
    end ;

    { Position les onglets }
    ShowTabMenus(True) ;
    ShowTabGeneral(False) ;
    ShowTabMesProgrammes(False) ;
    ShowTabAPropos(False) ;

    AjouteIcone;
end;

{*******************************************************************************
 * Quitte le programme
 ******************************************************************************}
procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
    CanClose := IWantReallyExit ;

    if IWantReallyExit = False
    then begin
        BoutonAnnulerClick(Sender) ;

        { On peut recevoire le message WM_CLOSE si on lance l'application une
          deuxième fois }
        If IsPrevinstance <> 0
        then begin
            SupprimeIcone ;
            CanClose := True ;
        end ;
    end ;
end;

{*******************************************************************************
 * Créer le menu
 ******************************************************************************}
procedure TForm1.CreerMenu ;
var P: TPoint;
    i: Integer ;
begin
    { On récupère la position en premier car on a le temp de déplacer la souris
      avant l'apparition du menu }
    GetCursorPos(P) ;

    { Cache la fenètre au cas ou on clique sur le menu }
    Hide ;
    { Annuler la config }
    BoutonAnnulerClick(Self) ;

    { Remet le timer ou bon intervel }
    Timer1.Interval := 2000 ;

    { Désactive le timer et le remet au bon interval }
    if (Timer1.Enabled = True)
    then begin
        Timer1.Enabled := False ;

        { Si timer pas désactiver alors destruction }
        if (ListeDesLecteurs <> nil)
        then begin
            ListeDesLecteurs.Free ;
        end ;

        if (NewPopUpMenu1 <> nil)
        then begin
            NewPopUpMenu1.Free ;
        end ;
    end ;

    { Initialise le pointeur du tableau à 0}
    NbList := 0 ;

    { ajoutes Mes Programmes }
    ajouterMesProgrammes ;

    if (CocheMenuRentrerDisques.Checked = True) or (CocheMenuEjecterDisques.Checked = True) or (CocheMenuDisques.Checked = True)
    then begin
        { Créer une liste de lecteur }
        ListeDesLecteurs := TDriveComboBox.Create(Self) ;
        ListeDesLecteurs.Parent := Self ;
        ListeDesLecteurs.Visible := False ;

        { Ajoute le menu des lecteurs }
        ajouterLecteur ;
    end ;

    if (CocheMenuArreter.Checked = True) or (CocheMenuVerrouiller.Checked = True) or (CocheMenuVeille.Checked = True)
    then
        { Ajoute le menu Arrêter Windows }
        ajouterMenuArretWindows ;

    { Ajoute le menu outils }
    if CocheMenuCapturerEcran.Checked or CocheMenuExecuter.Checked
    then
        ajouterMenuOutils ;

    { Ajoute le menu de l'application }
    ajouterMenuFastSysTray ;

    { Créer le menu PopUp }
    NewPopUpMenu1 := NewPopupMenu(Self, 'MonMenu', paLeft, True, ListItemDuMenuPopUp) ;

    PopUpMenu := NewPopUpMenu1 ;
    { Désactive l'auto PopUp de la feuille }
    PopUpMenu.AutoPopup := False ;
    PopUpMenu.Images := ImageList1 ;

    { Active les graphismes avancé des menus }
    if not CocheMenuGraphisme.Checked
    then begin
        { Met le fond en fuschia }
        ImageList1.BkColor := clFuchsia ;

        for i := 0 to ComponentCount - 1 do
            if Components[i] is TMenuItem
            then
                if (Components[i] as TmenuItem).Caption <> '-'
                then begin
                    (Components[i] as TmenuItem).OnDrawItem := MenueDrawItem ;
                    (Components[i] as TmenuItem).OnMeasureItem := MenueMeasureItem ;
                end ;
    end
    else begin
        ImageList1.BkColor := clNone ;
    end ;

    { ramène au premier plan pour accès menu }
    SetForegroundWindow(Handle) ;
    
    { ouvre le pop menu à cette position }
    PopUpMenu.Popup(P.x, P.y) ;

    Timer1.Enabled := True ;
end ;

{*******************************************************************************
 * Enregistre la config
 ******************************************************************************}
procedure TForm1.BoutonEnregistrerConfigurationClick(Sender: TObject);
begin
    LireEnregistrerConfig(False) ;
    Hide ;
end;

{*******************************************************************************
 * Bonton Annuler
 ******************************************************************************}
procedure TForm1.BoutonAnnulerClick(Sender: TObject);
begin
    LireEnregistrerConfig(True) ;
    Hide ;
end;

{*******************************************************************************
 * Quand on coche Lancer au démarrage de l'ordi, désactive l'autre
 ******************************************************************************}
procedure TForm1.LancerAutoOrdiClick(Sender: TObject);
begin
    if LancerAutoUser.Checked
    then
        LancerAutoUser.Checked := False ;

    LancerAutoUser.Enabled := not LancerAutoOrdi.Checked ;
end;

{*******************************************************************************
 * Quand on coche Lancer au démarrage de la session, désactive l'autre
 ******************************************************************************}
procedure TForm1.LancerAutoUserClick(Sender: TObject);
begin
    if LancerAutoOrdi.Checked
    then
        LancerAutoOrdi.Checked := False ;

    LancerAutoOrdi.Enabled := not LancerAutoUser.Checked ;
end;

{*******************************************************************************
 * Gère les onglets
 ******************************************************************************}
procedure TForm1.TabControl1Change(Sender: TObject);
begin
    case (Sender as TTabControl).TabIndex of
        0 : begin
                ShowTabMenus(True) ;
                ShowTabGeneral(False) ;
                ShowTabMesProgrammes(False) ;
                ShowTabAPropos(False) ;
            end ;
        1 : begin
                ShowTabMenus(False) ;
                ShowTabGeneral(True) ;
                ShowTabMesProgrammes(False) ;
                ShowTabAPropos(False) ;
            end ;
        2 : begin
                ShowTabMenus(False) ;
                ShowTabGeneral(False) ;
                ShowTabMesProgrammes(True) ;
                ShowTabAPropos(False) ;
            end ;
        3 : begin
                ShowTabMenus(False) ;
                ShowTabGeneral(False) ;
                ShowTabMesProgrammes(False) ;
                ShowTabAPropos(True) ;
            end ;
    end ;
end;

{*******************************************************************************
 * Désactive la coche 'Affiche les label des lecteurs'
 ******************************************************************************}
procedure TForm1.CocheMenuDisquesClick(Sender: TObject);
begin
    CocheMenuDisquesLabel.Enabled := CocheMenuDisques.Checked ;
end;


{*******************************************************************************
 * Desinne l'item du menu
 ******************************************************************************}
procedure TForm1.MenueDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect;
  Selected: Boolean);
var
  txt: string;
  B: TBitmap;

  IConRect, TextRect: TRect;
  X1, X2: integer;
  TextFormat: integer;
  HasImgLstBitmap: boolean;
  FMenuItem: TMenuItem;
  FMenu: TMenu;

begin
  FMenuItem := TMenuItem(Sender);
  FMenu := FMenuItem.Parent.GetParentMenu;

  { Suivant si le menu ce lit de droite à gauche }
  if FMenu.IsRightToLeft
  then begin
      X1 := ARect.Right - 20 ;
      X2 := ARect.Right;
  end
  else begin
      X1 := ARect.Left;
      X2 := ARect.Left + 20 ;
  end ;

  { Créer le fond de la zone zone correspondant à l'icone }
  IConRect := Rect(X1, ARect.Top, X2, ARect.Bottom);

  { Créer la zone de texte }
  TextRect := ARect;
  { Créer le texte }
  txt := ' ' + FMenuItem.Caption;

  { Créer l'image accueilant l'icone }
  B := TBitmap.Create;

  { Met le mode transparent }
  B.Transparent := True;
  //B.TransparentMode := tmAuto;
  B.TransparentColor := clFuchsia ;

  { Indique s'il y a une image d'une image liste }
  HasImgLstBitmap := false;

  if (FMenuItem.Parent.GetParentMenu.Images <>  nil)
  then begin
      if FMenuItem.ImageIndex <> -1
      then
          HasImgLstBitmap := true
      else
          HasImgLstBitmap := false;
  end;

  { S'il y a une image d'une image liste }
  if HasImgLstBitmap
  then begin
      { Lit l'image }
      FMenuItem.Parent.GetParentMenu.Images.GetBitmap(FMenuItem.ImageIndex, B) ;
  end
  else
      { Sinon, s'il }
      if FMenuItem.Bitmap.Width > 0
      then
          B.Assign(TBitmap(FMenuItem.Bitmap)) ;

  { Suivant si le menu ce lit de droite à gauche }
  if FMenu.IsRightToLeft then
    begin
      X1 := ARect.Left ;
      X2 := ARect.Right - 20 ;
    end
  else
    begin
      X1 := ARect.Left + 20;
      X2 := ARect.Right;
    end ;

  { Créer un rectangle contenant le texte }
  TextRect := Rect(X1, ARect.Top, X2, ARect.Bottom);

  { Ecrit le texte }
  ACanvas.brush.color := clMenu ; // FBackColor
  ACanvas.FillRect(TextRect);

  ACanvas.brush.color := clMenu ; //FIconBackColor ;
  ACanvas.FillRect(IconRect);

  ACanvas.Font.Color := clMenuText ; //FFontColor ;

  { Si on pointe sur l'item }
  if Selected
  then begin
      ACanvas.brush.Style := bsSolid;
      ACanvas.brush.color := clHighLight ; //FSelectedBkColor;
      ACanvas.FillRect(TextRect);
      ACanvas.Pen.color := clHighLight ; //FSelectedBkColor ;

      ACanvas.Brush.Style := bsClear ;
      ACanvas.Rectangle(TextRect.Left, TextRect.top, TextRect.Right, TextRect.Bottom);
  end;

  { Position l'icone }
  X1 := IConRect.Left + 2;

  { S'il y a une image, on l'a dessine }
  if B <> nil
  then
      ACanvas.Draw(X1, IConRect.top + 1, B) ;

  { Passe le fond en mode transparent }
  SetBkMode(ACanvas.Handle, TRANSPARENT);

  if Selected
  then
      ACanvas.Font.Color := clHighLightText ; //FSelectedFontColor ;

  { Position le texte }
  if FMenu.IsRightToLeft
  then
      ACanvas.Font.Charset := ARABIC_CHARSET ;

  if FMenu.IsRightToLeft
  then
      TextFormat := DT_RIGHT or DT_RTLREADING or DT_VCENTER or DT_SINGLELINE
  else
      TextFormat := DT_VCENTER or DT_SINGLELINE ;

  { Dessine le texte }
  TextRect := Rect(TextRect.Left, TextRect.top, TextRect.Right, TextRect.Bottom) ;

  DrawtextEx(ACanvas.Handle,
             PChar(txt),
             Length(txt),
             TextRect, TextFormat, nil);

  B.free;
end;

{*******************************************************************************
 * Renvoie la taille de l'item
 ******************************************************************************}
procedure TForm1.MenueMeasureItem(Sender: TObject; ACanvas: TCanvas; var Width, Height: Integer);
var
  W, H: integer;
begin
    W := ACanvas.TextWidth(TMenuItem(Sender).Caption);

    if pos('&', TMenuItem(Sender).Caption) > 0
    then
        W := W - ACanvas.TextWidth('&');

    if Width < W
    then
        Width := W;

    H := ACanvas.TextHeight(TMenuItem(Sender).Caption) ;
    if Height < H
    then
        Height := H;
end;

{*******************************************************************************
 * Affiche la boite d'ajout de raccourci
 ******************************************************************************}
procedure TForm1.AjouterRacClick(Sender: TObject);
Var BoiteCreerRacourci : TCreerRaccourci ;
begin
    BoiteCreerRacourci := TCreerRaccourci.Create(Self) ;
    BoiteCreerRacourci.ShowModal ;
    BoiteCreerRacourci.Free ;
end;

{*******************************************************************************
 * Affiche la boite de modificatop, de raccourci
 ******************************************************************************}
procedure TForm1.ModifierRacClick(Sender: TObject);
Var BoiteCreerRacourci : TCreerRaccourci ;
begin
    BoiteCreerRacourci := TCreerRaccourci.Create(Self) ;
    { La seule différence avec la réation, c'est qu'on indique qu'il s'agit
      d'une modif }
    BoiteCreerRacourci.IsModify := True ;
    BoiteCreerRacourci.ShowModal ;
    BoiteCreerRacourci.Free ;
end;

{*******************************************************************************
 * Active les boutons si on séléctionne un élément
 ******************************************************************************}
procedure TForm1.ListBoxRacClick(Sender: TObject);
Var status : Boolean ;
begin
    { Par défaut les boutons sont désactivés }
    Status := False ;
    
    if (ListBoxRac.ItemIndex <> -1) and (ListBoxRac.Items.Count > 0)
    then
        Status := True ;

    MonterRac.Enabled := Status ;
    ModifierRac.Enabled := Status ;
    SupprimerRac.Enabled := Status ;
    DescendreRac.Enabled := Status ;

    if Status and (ListRacCmd.Strings[ListBoxRac.ItemIndex] = '')
    then
        ModifierRac.Enabled := False ;
        
    { Si on est sur le premier éléments, on désactive le bouton monter }
    if (Status = True) and (ListBoxRac.ItemIndex < 1)
    then
        MonterRac.Enabled := False ;

    { Si on est sur le dernier élément, on désactive le bouton descendre }
    if (Status = True) and (ListBoxRac.ItemIndex = (ListBoxRac.Items.Count - 1))
    then
        DescendreRac.Enabled := False ;
end;

{*******************************************************************************
 * Ajoute un barre de séparation dans le menu Mes Programmes
 ******************************************************************************}
procedure TForm1.ajouterSeparateurClick(Sender: TObject);
begin
    ListBoxRac.Items.Add('- Barre de séparation -') ;
    ListRacCmd.Add('') ;
    ListRacArg.Add('') ;    
end;

{*******************************************************************************
 * Supprime un élément dans le menu Mes Programmes
 ******************************************************************************}
procedure TForm1.SupprimerRacClick(Sender: TObject);
begin
    if Application.MessageBox('Souhaitez-vous réelement supprimer ce raccourci ?','Suppression d''un raccourci', MB_YESNO + MB_ICONWARNING) = ID_YES
    then
        if ListBoxRac.Items.Count > 0
        then begin
            ListRacCmd.Delete(ListBoxRac.ItemIndex) ;
            ListRacArg.Delete(ListBoxRac.ItemIndex) ;
            { A mettre après car décrément imédiatement ItemIndex }
            ListBoxRac.Items.Delete(ListBoxRac.ItemIndex) ;
            ListBoxRacClick(Sender) ;

            if (ListBoxRac.ItemIndex < (ListBoxRac.Items.Count - 1))
            then
                { Si c'est le premier élément qui est supprimer, on ne
                  fait rien car sinon, on sélectionne le 2ème élément }
                if ListBoxRac.ItemIndex > 0
                then
                    ListBoxRac.ItemIndex := ListBoxRac.ItemIndex + 1
            else begin
                { Si c'était le dernier élément de la liste, on passe le focus au
                  control... }
                ListBoxRac.SetFocus ;
                { ...et on simule la touche espac, pour la sélection }
                SendMessage(ListBoxRac.Handle, WM_KEYDOWN, 32, 0) ;
                SendMessage(ListBoxRac.Handle, WM_KEYUP, 32, 0) ;
            end ;
        end ;
end;

{*******************************************************************************
 * Monte l'élément sélectionner dans Mes Programmes
 ******************************************************************************}
procedure TForm1.MonterRacClick(Sender: TObject);
begin
    if ListBoxRac.ItemIndex > 0
    then begin
        ListBoxRac.Items.Exchange(ListBoxRac.ItemIndex, ListBoxRac.ItemIndex - 1) ;
        ListRacCmd.Exchange(ListBoxRac.ItemIndex, ListBoxRac.ItemIndex - 1) ;
        ListRacArg.Exchange(ListBoxRac.ItemIndex, ListBoxRac.ItemIndex - 1) ;
        ListBoxRac.ItemIndex := ListBoxRac.ItemIndex - 1 ;
        ListBoxRacClick(Sender) ;
    end ;
end;

{*******************************************************************************
 * Descent l'élément sélectionner dans Mes Programmes
 ******************************************************************************}
procedure TForm1.DescendreRacClick(Sender: TObject);
begin
    if (ListBoxRac.ItemIndex <> -1) and (ListBoxRac.ItemIndex < (ListBoxRac.Items.Count - 1))
    then begin
        ListBoxRac.Items.Exchange(ListBoxRac.ItemIndex, ListBoxRac.ItemIndex + 1) ;
        ListRacCmd.Exchange(ListBoxRac.ItemIndex, ListBoxRac.ItemIndex + 1) ;
        ListRacArg.Exchange(ListBoxRac.ItemIndex, ListBoxRac.ItemIndex + 1) ;
        ListBoxRac.ItemIndex := ListBoxRac.ItemIndex + 1 ;
        ListBoxRacClick(Sender) ;
    end ;
end;

{*******************************************************************************
 * Enregistre la config générale dans la base de registre
 ******************************************************************************}
procedure TForm1.SauveMesProgrammesConfig() ;
Var Registre : TRegistry ;
    i : Integer ;
    NBRac : Integer ;
begin
    Registre := TRegistry.Create ;

    try
        Registre.RootKey := HKEY_CURRENT_USER ;
        Registre.OpenKey(CHEMIN_REGISTRE + '\ShortCut', True) ;

        { Enregistre, le nombre de raccourci }
        Registre.WriteInteger('ShortCutCount', ListBoxRac.Items.Count - 1) ;

        { Enregistre les raccourcis }
        NBRac := ListBoxRac.Items.Count - 1 ;
        
        For i := 0 to NBRac do
        begin
            Registre.WriteString('ShortCut' + IntToStr(i), ListBoxRac.Items[i]) ;
            Registre.WriteString('ShortCutCmd' + IntToStr(i), ListRacCmd.Strings[i]) ;
            Registre.WriteString('ShortCutArg' + IntToStr(i), ListRacArg.Strings[i]) ;
        end ;

        Registre.CloseKey ;
    finally
        Registre.Free ;
    end ;
end ;

{*******************************************************************************
 * Lit les raccourcis Mes programmes
 ******************************************************************************}
procedure TForm1.LitMesProgrammesConfig() ;
Var Registre : TRegistry ;
    i : Integer ;
    nb : Integer ;
begin
    Registre := TRegistry.Create ;

    try
        Registre.RootKey := HKEY_CURRENT_USER ;

        if Registre.KeyExists(CHEMIN_REGISTRE + '\ShortCut')
        then begin
            Registre.OpenKey(CHEMIN_REGISTRE + '\ShortCut', False) ;

            if Registre.ValueExists('ShortCutCount')
            then begin
                { Lit le nombre de raccourci }
                Nb := Registre.ReadInteger('ShortCutCount') ;

                { Lit les raccourcis }
                for i := 0 to Nb do
                begin
                    ListRacCmd.Add(Registre.ReadString('ShortCutCmd' + IntToStr(i))) ;
                    ListRacArg.Add(Registre.ReadString('ShortCutArg' + IntToStr(i))) ;
                    ListBoxRac.Items.Add(Registre.ReadString('ShortCut' + IntToStr(i))) ;
                end ;
            end ;
        end ;

        Registre.CloseKey ;
    finally
        Registre.Free ;
    end ;
end ;

{*******************************************************************************
 * Créer le menu Mes Programmes
 ******************************************************************************}
procedure TForm1.ajouterMesProgrammes ;
Var i : Integer ;
    Bmp1 : TBitmap ;
    ShInfo1 : SHFILEINFO ;
    NBRac : Integer ;
begin
    { Créer le BMP }
    Bmp1 := TBitmap.Create() ;
    { Définir la couleur de transparence }
    Bmp1.Canvas.Brush.Color := clMenu ;
    Bmp1.Canvas.Pen.Color := clMenu ;
    { Active la transparence. Prend le pixel 1:1 }
    Bmp1.Transparent := True ;
    Bmp1.Width := 16;
    Bmp1.Height := 16;

    NBRac := ListBoxRac.Items.Count - 1 ;

    for i := 0 to NBRac do
    begin
        NouveauMenu := TMenuItem.Create(Self);

        if (ListRacCmd.Strings[i] <> '')
        then begin
            { Efface l'icone pour le prochaine icone }
            Bmp1.Canvas.Rectangle(0, 0, 16, 16) ;

            { Récupère les informations liés au lecteur }
            SHGetFileInfo(PChar(ListRacCmd.Strings[i]), 0, ShInfo1, sizeOF(SHFILEINFO), SHGFI_ICON or SHGFI_SMALLICON) ;

            { Dessine l'icône }
            DrawIconEx(Bmp1.Canvas.Handle, 0, 0, ShInfo1.hIcon, 0, 0, 0, 0, DI_NORMAL) ;

            NouveauMenu.Caption := ListBoxRac.Items[i] ;
            NouveauMenu.OnClick := LancerMesProgrammes ;
            NouveauMenu.Name := 'ShortCut' + IntToStr(NbList) ;
            NouveauMenu.Tag := i ;
            NouveauMenu.Bitmap.Assign(Bmp1) ;
        end
        else begin
            { Pas de commande, donc, il s'agit d'une barre de séparation }
            NouveauMenu.Caption := '-' ;
            NouveauMenu.OnClick := nil ;
            NouveauMenu.Name := 'ShortCut' + IntToStr(NbList) ;
        end ;

        NbList :=  NbList + 1 ;
        SetLength(ListItemDuMenuPopUp, NbList) ;
        ListItemDuMenuPopUp[NbList - 1] := NouveauMenu ;
    end ;

    Bmp1.Free ;

    if ListBoxRac.Items.Count > 0
    then
        ajouterMenuSeparateur ;
end ;

{*******************************************************************************
 * Affiche l'explorateur avec le lecteur demandé
 ******************************************************************************}
procedure TForm1.LancerMesProgrammes(Sender: TObject) ;
Var msg : String ;
    i : Integer ;
    operation : String ;
begin
    { Affecte la commande à la variable msg. C'est plus pratique pour les
      messages d'erreur }
    msg := ListRacCmd.Strings[TMenuItem(Sender).Tag] ;

    { On récupère les attributs du fichier }
    i := FileGetAttr(msg) ;

    { Si -1 c'est qu'il y a une erreur. Le ficheir ne doit pas exister }
    if i <> -1
    then begin
        { Isole l'attribut Répertoire }
        i := i and faDirectory ;

        { Si différent de 0, c'est un répertoire }
        if i <> 0
        then
            operation := 'EXPLORE'
        else
            operation := 'OPEN' ;
    end
    else
        operation := 'OPEN' ;

    { Lance la commande. On ne fait pas une ligne spécifique car il n'y a pas
      d'argument donc on ne passe rien forcément }
    case ShellExecute(Handle, Pchar(operation), PChar(msg),
             PChar(ListRacArg.Strings[TMenuItem(Sender).Tag]),'',SW_SHOWNORMAL)
    of
        0                    : msg := 'Pas assez de mémoire disponible.' ;
        ERROR_FILE_NOT_FOUND : msg := 'Fichier introuvable.' ;
        ERROR_BAD_FORMAT     : msg := 'L''exécutable n''est pas un programme Win32 ou EXE valide' ;
        SE_ERR_ACCESSDENIED  : msg := 'L''accès au fichier est refusé.' ;
        SE_ERR_ASSOCINCOMPLETE : msg := 'Le programme associé est invalide.' ;
        SE_ERR_DLLNOTFOUND   : msg := 'DLL introuvable pour le programme.' ;
        SE_ERR_NOASSOC       : msg := 'Aucun programme n''est associer à l''extention ' + '(' + ExtractFileExt(msg) + ')' ;
        SE_ERR_OOM           : msg := 'Pas assez de mémoire pour appeler le programme' ;
        SE_ERR_SHARE         : msg := 'Violation de partage' ;
    else
        msg := '' ;
    end ;

    { S'il y a un message, c'est qu'il y a une erreur }
    if msg <> ''
    then
        Application.MessageBox(PChar(msg), 'Erreur', MB_OK or MB_ICONERROR) ;
end ;

{*******************************************************************************
 * Vérifie que c'est toujours nous qui avous le premier plan
 * Détruit le menu si on n'a plus le premier plan
 ******************************************************************************}
procedure TForm1.Timer1Timer(Sender: TObject);
begin
    { Est-ce toujours nous qui avont le premier plan }
    if GetForeGroundWindow() <> Handle
    then begin
        { non, on désactive le timer }
        Timer1.Enabled := False ;

        { On détruit les ressources du menu }
        if (ListeDesLecteurs <> nil)
        then begin
            ListeDesLecteurs.Free ;
        end ;

        if (NewPopUpMenu1 <> nil)
        then begin
            NewPopUpMenu1.Free ;
        end ;
    end
    else
        { On remet le compteur du timer mais à 1 seconde }
        Timer1.Interval := 1000 ;
end;

{*******************************************************************************
 * Ajoute le menu outils
 ******************************************************************************}
procedure TForm1.ajouterMenuOutils;
begin
    if CocheMenuExecuter.Checked
    then begin
        NouveauMenu := TMenuItem.Create(Self);
        NouveauMenu.Caption := 'Exécuter' ;
        NouveauMenu.OnClick := Executer ;
        NouveauMenu.Name := 'MEWP' ;
        NouveauMenu.ImageIndex := 9 ;

        NbList := NbList + 1 ;
        SetLength(ListItemDuMenuPopUp, NbList) ;

        ListItemDuMenuPopUp[NbList - 1] := NouveauMenu ;
    end ;

    if CocheMenuCapturerEcran.Checked
    then begin
        NouveauMenu := TMenuItem.Create(Self);
        NouveauMenu.Caption := 'Capture d''écran' ;
        NouveauMenu.OnClick := CopieDEcran ;
        NouveauMenu.Name := 'MCE' ;
        NouveauMenu.ImageIndex := 10 ;

        NbList := NbList + 1 ;
        SetLength(ListItemDuMenuPopUp, NbList) ;

        ListItemDuMenuPopUp[NbList - 1] := NouveauMenu ;
    end ;

    ajouterMenuSeparateur ;
end ;

{*******************************************************************************
 * Affiche l'explorateur avec le lecteur demandé
 ******************************************************************************}
procedure TForm1.Executer(Sender: TObject) ;
var Status : Boolean ;
begin
    Status := False ;

    case ShellExecute(Handle, 'OPEN', PChar(ExtractFileDir(Application.ExeName) + '\fst_run.exe'), '','',SW_SHOWNORMAL)
    of
        0                    : ;
        ERROR_FILE_NOT_FOUND : ;
        ERROR_BAD_FORMAT     : ;
        SE_ERR_ACCESSDENIED  :  ;
        SE_ERR_ASSOCINCOMPLETE :  ;
        SE_ERR_DLLNOTFOUND   : ;
        SE_ERR_NOASSOC       : ;
        SE_ERR_OOM           : ;
        SE_ERR_SHARE         : ;
    else
        Status := True ;
    end ;

    if Status = False
    then
        Application.MessageBox('Impossible de lancer le module Executer. Veuillez réinstaller Fast SysTray.', 'Erreur', MB_OK + MB_ICONERROR) ;
end ;

{*******************************************************************************
 * Affiche le site internet
 ******************************************************************************}
procedure TForm1.site_internetClick(Sender: TObject);
begin
    ShellExecute(Handle, 'OPEN', 'http://php4php.free.fr/fastsystray','','',SW_SHOWNORMAL);
end;

{*******************************************************************************
 * Copie l'écran dans le presse papier
 ******************************************************************************}
procedure TForm1.CopieDEcran(Sender: TObject) ;
var HandleDCBureau : HDC;
    Bmp1 : TBitmap ;
begin
    Bmp1 := TBitmap.Create ;
    
    { Prend le handle du bureau }
    HandleDCBureau := GetDC(GetDesktopWindow) ;

    try
        { La largeur et la hauteur de l'image est celle du bureau }
        Bmp1.Width := Screen.Width ;
        Bmp1.Height := Screen.Height;

        { Recopie l'image }
        BitBlt(Bmp1.Canvas.Handle, 0, 0, Screen.Width, Screen.Height,
               HandleDCBureau, 0, 0, SrcCopy) ;

        Clipboard.Assign(Bmp1) ;               
     finally
         ReleaseDC(GetDesktopWindow,HandleDCBureau);
     end;
end ;

{*******************************************************************************
 * Lance l'aide
 ******************************************************************************}
procedure TForm1.afficherAide(Sender: TObject) ;
begin
    ShellExecute(Handle, 'OPEN', PChar(ExtractFileDir(Application.ExeName) + '\aide\index.htm'),'','',SW_SHOWNORMAL);
end;

end.
