unit BoiteCreerRacourci;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FileCtrl, ComObj, ShlObj, ActiveX, ShellAPI ;

type
  TCreerRaccourci = class(TForm)
    Label1: TLabel;
    parcourir: TButton;
    programme: TEdit;
    Label2: TLabel;
    texte: TEdit;
    ok: TButton;
    Annuler: TButton;
    OpenDialog1: TOpenDialog;
    Label3: TLabel;
    arguments: TEdit;
    IsReperoire: TCheckBox;
    procedure AnnulerClick(Sender: TObject);
    procedure parcourirClick(Sender: TObject);
    procedure VerificationZoneTexte(Sender: TObject);
    procedure okClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure IsReperoireClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Déclarations privées}
    function VerifierRaccourci() : boolean ;
    function StrCopyN(chaine : String; valMax : Integer) : String ;    
  public
    { Déclarations publiques}
    IsModify : Boolean ;
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;    
  end;

var
  CreerRaccourci: TCreerRaccourci;

implementation

uses main;

{$R *.DFM}

{*******************************************************************************
 * Si on clique sur Annuler, on ferme la fenêtre sans rien faire d'autre
 ******************************************************************************}
procedure TCreerRaccourci.AnnulerClick(Sender: TObject);
begin
    Close ;
end;

{*******************************************************************************
 * On a cliqué sur le bouton parcourir
 ******************************************************************************}
procedure TCreerRaccourci.parcourirClick(Sender: TObject);
Var S : String ;
    I  : IShellLink ;
    Ip : IPersistFile ;
    w  : win32_find_dataa ;
    pc : array[0..MAX_PATH-1] of Char ;
    argumentsString : String ;
    lien : String ;
begin
    { Si on indique que c'est un répertoire }
    if IsReperoire.Checked
    then begin
        { Affiche la boite de dialogue de répertoire }
        if SelectDirectory('Sélectionnez un répertoire ou un lecteur.', '', S)
        then begin
            Programme.Text := S ;

            S := ExtractFileName(S) ;

            { Si quand on fait l'extraction du nom, on a rien on met le programme }
            if S <> ''
            then
                Texte.Text := ExtractFileName(S)
            else
                Texte.Text := Programme.Text ;
        end ;
    end
    else
        { Affiche la boite de dialogue pour les commande }
        if OpenDialog1.Execute
        then begin
            { Mémorise le nom du fichier ou du lien }
            lien := OpenDialog1.FileName ;

            { Vérifie si c'est un lien }
            if UpperCase(ExtractFileExt(OpenDialog1.FileName)) = '.LNK'
            then begin
                I := CreateComObject(CLSID_ShellLink)as IShellLink ;
                Ip := I as IPersistFile ;
                Ip.load(StringToOleStr(OpenDialog1.FileName), STGM_READ) ;

                { Récupère le fichier }
                I.GetPath(pc, max_path, w, SLGP_UNCPRIORITY) ;
                OpenDialog1.FileName := pc ;

                { Récupère les arguments }
                I.GetArguments(pc, max_path) ;
                argumentsString := pc ;
            end
            else
                argumentsString := '' ;


            Programme.Text := OpenDialog1.FileName ;
            Arguments.Text := argumentsString ;

            { Récupérer le label. NomFichier-Extention}
            lien := ExtractFileName(lien) ;
            Texte.Text := StrCopyN(lien, length(lien) - length(ExtractFileExt(lien))) ;
        end ;
end;

{*******************************************************************************
 * Appeler que on modifie le texte de Programme et de Texte pour activer ou non
 * le bouton OK.
 ******************************************************************************}
procedure TCreerRaccourci.VerificationZoneTexte(Sender: TObject);
begin
    if (Length(Programme.Text) > 0) and (Length(Texte.Text) > 0)
    then
        Ok.Enabled := True
    else
        Ok.Enabled := False ;
end;

{*******************************************************************************
 * On a cliqué sur le bouton OK
 ******************************************************************************}
procedure TCreerRaccourci.okClick(Sender: TObject);
begin
    if VerifierRaccourci()
    then begin
        { S'agit-il d'une modification }
        if IsModify
        then begin
            { Oui, on modifie les champs actuels }
            Form1.ListRacCmd.Strings[Form1.ListBoxRac.ItemIndex] := Programme.Text ;
            Form1.ListRacArg.Strings[Form1.ListBoxRac.ItemIndex] := Arguments.Text ;
            Form1.ListBoxRac.Items[Form1.ListBoxRac.ItemIndex] := Texte.Text ;
        end
        else begin
            { Non, on ajoute à la fin de la liste }
            Form1.ListRacCmd.Add(Programme.Text) ;
            Form1.ListRacArg.Add(Arguments.Text) ;
            Form1.ListBoxRac.Items.Add(Texte.Text) ;
        end ;

        { Ferme la fenêtre }
        Close ;
    end ;
end;

{*******************************************************************************
 * Quand la feuille est affichée, on récupère les valeurs
 ******************************************************************************}
procedure TCreerRaccourci.FormShow(Sender: TObject);
Var i : Integer ;
begin
    if IsModify
    then begin
        Programme.Text := Form1.ListRacCmd.Strings[Form1.ListBoxRac.ItemIndex] ;
        Arguments.Text := Form1.ListRacArg.Strings[Form1.ListBoxRac.ItemIndex] ;        
        Texte.Text := Form1.ListBoxRac.Items[Form1.ListBoxRac.ItemIndex] ;

        Caption := 'Modification d''un raccourci' ;
        
        { On récupère les attributs du fichier }
        i := FileGetAttr(Programme.Text) ;

        { Si -1 c'est qu'il y a une erreur. Le ficheir ne doit pas exister }
        if i <> -1
        then begin
            { Isole l'attribut Répertoire }
            i := i and faDirectory ;

            { Si différent de 0, c'est un répertoire }
            if i <> 0
            then begin
                IsReperoire.Checked := True ;
                IsReperoireClick(Sender) ;
            end ;
        end ;
    end ;
end;

{*******************************************************************************
 * Quand on clique sur c'est un répertoire, on désactive la zone d'arguments
 ******************************************************************************}
procedure TCreerRaccourci.IsReperoireClick(Sender: TObject);
begin
    arguments.Enabled := not TCheckBox(Sender).Checked ;

    if arguments.Enabled
    then
        arguments.Color := clWindow
    else
        arguments.Color := clBtnFace ;

    arguments.Text := '' ;
end;

{*******************************************************************************
 * Vérifie l'existance du fichier
 ******************************************************************************}
function TCreerRaccourci.VerifierRaccourci() : boolean ;
begin
    Result := True ;

    { Vérifie sir le fichier ou répertoire existe }
    if not ((FileExists(Programme.Text) and not IsReperoire.Checked) or
       (DirectoryExists(Programme.Text) and IsReperoire.Checked))
    then
        if Application.MessageBox('Le fichier ou répertoire indiqué est introuvable. Voulez-vous tout de même valider le raccourci ?', 'Avertissement', MB_YESNO + MB_ICONWARNING) = IDNO
        then
            Result := False ;
end ;

{*******************************************************************************
 * Copie les X premiers caractères d'une chaine.
 * Si la chaine est plus courte que ce qu'on veut copier, c'est la chaine qui
 * est retourné.
 *
 * Entrée : chaine à copier, nombre de caractères à copier
 * Sortie : aucune
 * Retour : la chaine voulue
 ******************************************************************************}
function TCreerRaccourci.StrCopyN(chaine : String; valMax : Integer) : String ;
Var i : Integer ;
begin
    Result := '' ;

    if (Length(chaine) >= valMax)
    then
        for i := 1 to valMax do
            Result := Result + chaine[i]
    else
        Result := chaine ;
end ;

procedure TCreerRaccourci.FormCreate(Sender: TObject);
begin
    // Indique que l'on peut faire du drag&drop sur la feuille
    DragAcceptFiles(Self.Handle,true);
end;

{******************************************************************************
 * Procédure appelée quand on drop quelque chose
 ******************************************************************************}
procedure TCreerRaccourci.WMDropFiles(var Msg: TWMDropFiles);
var
  NomDuFichier : array[0..MAX_PATH] of char;
  S : String ;

begin
  try
    if DragQueryFile(Msg.Drop, 0, NomDuFichier, sizeof(NomDuFichier)) > 0
    then begin
        Programme.Text := String(NomDuFichier) ;

        S := ExtractFileName(Programme.Text) ;

        { Si quand on fait l'extraction du nom, on a rien on met le programme }
        if S <> ''
        then
            Texte.Text := ExtractFileName(S)
        else
            Texte.Text := Programme.Text ;
    end ;

  finally
    DragFinish(Msg.Drop);
  end;
end;

end.
