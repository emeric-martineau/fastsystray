unit BoiteCreerRacourci;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FileCtrl ;

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
  private
    { D�clarations priv�es}
    function VerifierRaccourci() : boolean ;
  public
    { D�clarations publiques}
    IsModify : Boolean ;
  end;

var
  CreerRaccourci: TCreerRaccourci;

implementation

uses main;

{$R *.DFM}

{*******************************************************************************
 * Si on clique sur Annuler, on ferme la fen�tre sans rien faire d'autre
 ******************************************************************************}
procedure TCreerRaccourci.AnnulerClick(Sender: TObject);
begin
    Close ;
end;

{*******************************************************************************
 * On a cliqu� sur le bouton parcourir
 ******************************************************************************}
procedure TCreerRaccourci.parcourirClick(Sender: TObject);
Var S : String ;
begin
    { Si on indique que c'est un r�pertoire }
    if IsReperoire.Checked
    then begin
        { Affiche la boite de dialogue de r�pertoire }
        if SelectDirectory('S�lectionnez un r�pertoire ou un lecteur.', '', S)
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
            Programme.Text := OpenDialog1.FileName ;
            Texte.Text := ExtractFileName(OpenDialog1.FileName) ;
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
 * On a cliqu� sur le bouton OK
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
            { Non, on ajoute � la fin de la liste }
            Form1.ListRacCmd.Add(Programme.Text) ;
            Form1.ListRacArg.Add(Arguments.Text) ;
            Form1.ListBoxRac.Items.Add(Texte.Text) ;
        end ;

        { Ferme la fen�tre }
        Close ;
    end ;
end;

{*******************************************************************************
 * Quand la feuille est affich�e, on r�cup�re les valeurs
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

        { On r�cup�re les attributs du fichier }
        i := FileGetAttr(Programme.Text) ;

        { Si -1 c'est qu'il y a une erreur. Le ficheir ne doit pas exister }
        if i <> -1
        then begin
            { Isole l'attribut R�pertoire }
            i := i and faDirectory ;

            { Si diff�rent de 0, c'est un r�pertoire }
            if i <> 0
            then begin
                IsReperoire.Checked := True ;
                IsReperoireClick(Sender) ;
            end ;
        end ;
    end ;
end;

{*******************************************************************************
 * Quand on clique sur c'est un r�pertoire, on d�sactive la zone d'arguments
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

function TCreerRaccourci.VerifierRaccourci() : boolean ;
begin
    Result := True ;

    { V�rifie sir le fichier ou r�pertoire existe }
    if not ((FileExists(Programme.Text) and not IsReperoire.Checked) or
       (DirectoryExists(Programme.Text) and IsReperoire.Checked))
    then
        if Application.MessageBox('Le fichier ou r�pertoire indiqu� est introuvable. Voulez-vous tout de m�me valider le raccourci ?', 'Avertissement', MB_YESNO + MB_ICONWARNING) = IDNO
        then
            Result := False ;
end ;

end.
