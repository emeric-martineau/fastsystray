{*******************************************************************************
 * Copyright (C) 2004 MARTINEAU Emeric (php4php@free.fr)
 *
 * Fast SysTray - Module Ex�cuter.
 *
 * Version 1.1.0
 *
 * Le module Ex�cuter reprand les m�mes fonctionnalit�s que la boit de dialogue
 * Ex�cuter de Windows mais �tend son fonctionnement avec la possibilit� de ne
 * pas m�moriser la commande tap�e et d'effacer la liste.
 *
 * ATTENTION : Ce programme ne fait pas exactement la m�me chose que l'Ex�cuter
 * de Windows.
 * Lorsqu'il enregistre les commandes dans la base de registre, il aligne les
 * Valeur a,b,c et ne s'emb�te pas � les mettre dans le bon ordre.
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
unit run;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, XPTheme, Registry, ShellAPI ;

type
  TForm_fst_run = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    ComboBox1: TComboBox;
    Label2: TLabel;
    OK: TButton;
    Annuler: TButton;
    Parcourir: TButton;
    OpenDialog1: TOpenDialog;
    NePasEnregistrer: TCheckBox;
    EffacerHistorique: TButton;
    procedure AnnulerClick(Sender: TObject);
    procedure ParcourirClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EffacerHistoriqueClick(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure OKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    CloseWindowsAfterRun : Boolean ; 
    { D�clarations priv�es }
    function  StrCopyN(chaine : String; valMax : Integer) : String ;
    function  StrCopyToN(chaine : String; startPos : Integer) : String ;
    procedure SeparerCommandeArguments(ligne : String; var commande : String; var arguments : String) ;
    function  Lancer(commande : String; arguments : String) : Boolean ;
  public
    { D�clarations publiques }
  end;

var
  Form_fst_run: TForm_fst_run;
  Function  IsPrevInstance : HWND ;
  
implementation

{$R *.DFM}

{*******************************************************************************
 * cette fonction renvoie 0 s'il n'y a pas d'instance du m�me programme d�j�
 * lanc�e sinon le handle de l'instance d�j� lanc�e c'est � dire une valeur <>0
 * cette fonction est appel� dans le source du projet. voir ce source pour
 * comprendre.
 ******************************************************************************}
Function IsPrevInstance : HWND ;
Var ClassName:Array[0..255] of char;
    TitreApplication:string;
Begin
    result := 0 ;
    TitreApplication := Application.Title ;
    { on change le titre car sinon, on trouverait toujours une application d�j�
      lanc�e (la notre!) }
    Application.Title := '' ;
    try
        { met dans ClassName le nom de la class de l'application }
        GetClassName(Application.handle, ClassName, 254) ;
        { renvoie le Handle de la premi�re fen�tre de Class (type) ClassName et
          de titre TitreApplication (0 s'il n'y en a pas) }
        result := FindWindow(ClassName,PChar(TitreApplication)) ;
    finally
        { restauration du vrai titre }
        Application.Title := TitreApplication ;
    end;
end;

{*******************************************************************************
 * Bouton Annuler
 ******************************************************************************}
procedure TForm_fst_run.AnnulerClick(Sender: TObject);
begin
    Close ;
end;

{*******************************************************************************
 * Bouton parcourir
 ******************************************************************************}
procedure TForm_fst_run.ParcourirClick(Sender: TObject);
begin
    OpenDialog1.InitialDir := ExtractFileDir(ComboBox1.Text) ;

    { Affiche la boite de dialogue pour les commande }
    if OpenDialog1.Execute
    then
        ComboBox1.Text := OpenDialog1.FileName ;
end;

{*******************************************************************************
 * Cr�ation de la feuille
 ******************************************************************************}
procedure TForm_fst_run.FormCreate(Sender: TObject);
Var Registre : TRegistry ;
    MRUList : String ;
    i : Integer ;
    NbMRUList : Integer ;
    tmp : String ;
    Rectangle : TRect ;
begin
  { Utilisation de SystemParametersInfo pour r�cup�rer la surface (rectangle) de
    travail de l'�cran disponible }
  SystemParametersInfo (SPI_GETWORKAREA,0,@Rectangle,0);

    Registre := TRegistry.Create;

    try
        Registre.RootKey := HKEY_CURRENT_USER ;

        if Registre.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU', False)
        then begin
            { S'il y a la clef MRUList de pr�sent on lit ce qu'elle contient }
            if Registre.ValueExists('MRUList')
            then begin
                MRUList := Registre.ReadString('MRUList') ;
                NbMRUList := Length(MRUList) ;

                { Pour chaque lettre }
                for i := 1 to NbMRUList do
                    { On v�rifie que la valeur associ�e � la lettre existe }
                    if Registre.ValueExists(MRUList[i])
                    then begin
                        { A la fin de la chaine, il y a toujours '\1'. Pourquoi ? }
                        tmp := Registre.ReadString(MRUList[i]) ;
                        tmp := StrCopyN(tmp, Length(tmp) - 2) ;

                        { Si la valeur existe on l'ajoute � la liste }
                        ComboBox1.Items.Add(tmp) ;
                    end ;

                { Configure le texte }
                ComboBox1.Text := ComboBox1.Items[0] ;
            end ;
            
            Registre.CloseKey;
        end ;
    finally
    end;

    { Fermer la fen�tre apr�s ex�cution }
    try
        Registre.CloseKey ;
        Registre.OpenKey('Software\Fast SysTray', True) ;

        { Fermer la fen�tre executer }
        if Registre.ValueExists('MenuFermerFenetreExec')
        then
            CloseWindowsAfterRun := Registre.ReadBool('MenuFermerFenetreExec')
        else begin
            CloseWindowsAfterRun := True ;
        end ;

        Registre.CloseKey ;
    finally
    end ;

    try
        Registre.CloseKey ;
        Registre.OpenKey('Software\Fast SysTray', True) ;

        { Fermer la fen�tre executer }
        if Registre.ValueExists('PositionFenetreExec')
        then begin
            case Registre.ReadInteger('PositionFenetreExec') of
                0 : begin //en haut � gauche
                        Left := Rectangle.Left ;
                        Top := Rectangle.Top ;
                    end ;
                1 : begin //en bas � gauche
                        Left := Rectangle.Left ;
                        Top := Rectangle.Bottom - Height ;
                    end ;
                2 : begin //en haut � droite
                        Left := Rectangle.Right - Width ;
                        Top := Rectangle.Top ;
                    end ;
                3 : begin //en bas � droite
                        Left := Rectangle.Right - Width ;
                        Top := Rectangle.Bottom - Height ;
                    end ;
                4 : Position := poDesktopCenter ; //au milieu du bureau  (poDesktopCenter)
                5 : Position := poScreenCenter ; //au milieu de l'�cran (poScreenCenter)
                6 : Position := poDefaultPosOnly ; //laisser Windows positionner la fen�tre (poDefaultPosOnly)

            end ;
        end ;

        Registre.CloseKey ;
    finally
        Registre.Free ;
    end ;

    { D�sactive le bouton OK }
    if Length(ComboBox1.Text) <= 0
    then
        OK.Enabled := False ;

end;

{*******************************************************************************
 * Copie les X premiers caract�res d'une chaine.
 * Si la chaine est plus courte que ce qu'on veut copier, c'est la chaine qui
 * est retourn�.
 *
 * Entr�e : chaine � copier, nombre de caract�res � copier
 * Sortie : aucune
 * Retour : la chaine voulue
 ******************************************************************************}
function TForm_fst_run.StrCopyN(chaine : String; valMax : Integer) : String ;
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

{*******************************************************************************
 * Copie du caract�re X � la fin de la chaine.
 * Si la position est supp�rieur � la taille de la chaine, une chaine vide est
 * retourn�e.
 *
 * Entr�e : chaine � copier, position de d�but de copie
 * Sortie : aucune
 * Retour : la chaine voulue
 ******************************************************************************}
function TForm_fst_run.StrCopyToN(chaine : String; startPos : Integer) : String ;
Var i : Integer ;
    lenChaine : Integer ;
begin
    Result := '' ;

    lenChaine := Length(chaine) ;

    if (lenChaine >= startPos)
    then
        for i := startPos to lenChaine do
            Result := Result + chaine[i]
    else
        Result := '' ;
end ;

{*******************************************************************************
 * Effacer l'historique
 ******************************************************************************}
procedure TForm_fst_run.EffacerHistoriqueClick(Sender: TObject);
Var Registre : TRegistry ;
    ListeValeurs : TStringList ;
    NbVal : Integer ;
    i : Integer ;
begin
    if Application.MessageBox('Voulez-vous r�ellement effacer l''historique des commandes ?' +
                              #10#13'Cette op�ration est irr�versible.'#10#13 +
                              'ATTENTION ! Pour que certaines versions de Windows prennent en compte le changement, l''explorateur doit �tre relanc�.'
                              , 'Effacer l''historique', MB_YESNO + MB_ICONQUESTION) = ID_YES
    then begin
        Registre := TRegistry.Create;

        try
            Registre.RootKey := HKEY_CURRENT_USER ;

            if Registre.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU', False)
            then begin
                { Cr�er l'objet reccueillant la liste des valeurs }
                ListeValeurs := TStringList.Create ;

                { R�cup�re les valeurs }
                Registre.GetValueNames(ListeValeurs) ;

                NbVal := ListeValeurs.Count - 1 ;

                For i := 0 to NbVal do
                    Registre.DeleteValue(ListeValeurs.Strings[i]) ;

            end ;

            ComboBox1.Items.Clear ;
            ComboBox1.Text := '' ;
            Ok.Enabled := False ;
        finally
            Registre.CloseKey;
            Registre.Free;
        end;
    end ;
end;

{*******************************************************************************
 * Quand le texte change
 ******************************************************************************}
procedure TForm_fst_run.ComboBox1Change(Sender: TObject);
begin
    if Length(ComboBox1.Text) > 0
    then
        OK.Enabled := True
    else
        OK.Enabled := False ;
end ;

{*******************************************************************************
 * Bouton OK
 ******************************************************************************}
procedure TForm_fst_run.OKClick(Sender: TObject);
Var commande : String ;
    arguments : String ;
begin
    SeparerCommandeArguments(ComboBox1.Text, commande, arguments) ;

    if (not NePasEnregistrer.Checked) and (Lancer(commande, arguments))
    then begin
        { Cherche l'occurence dans la liste pour voir si la commande est d�j�
          connue }
        if ComboBox1.ItemIndex = -1
        then
            ComboBox1.ItemIndex := ComboBox1.Items.IndexOf(ComboBox1.Text) ;

        { Si ItemIndex encore � -1 c'est qu'il s'agit d'une nouvelle commande }
        if ComboBox1.ItemIndex = -1
        then begin
             { Ajoute la commande � la liste }
             ComboBox1.Items.Insert(0, ComboBox1.Text) ;
             { On supprime l'�l�ment 26. Si la liste est remplit, on supprime ce
               qui d�passe }
             ComboBox1.Items.Delete(26) ;
        end
        else begin
            { Il ne s'agit pas d'une nouvelle commande, alors on remonte celle
              s�lectionner dans la liste pour qu'elle devienne la premi�re }
            ComboBox1.Items.Move(ComboBox1.ItemIndex, 0) ;
            ComboBox1.ItemIndex := 0 ;
        end ;

        if CloseWindowsAfterRun
        then
            Close ;
    end ;

end;

{*******************************************************************************
 * S�pare la commande de l'argument
 ******************************************************************************}
procedure TForm_fst_run.SeparerCommandeArguments(ligne : String; var commande : String; var arguments : String) ;
Var Separateur : String ;
    i : Integer ;
    Pos : Integer ;
Begin
    Pos := -1 ;

    if (ligne[1] = '"') or (ligne[1] = '''')
    then
        Separateur := ligne[1]
    else
        Separateur := ' ' ;

    { Recherche la position du s�parateur }    
    for i := 2 to length(ligne) do
        if ligne[i] = Separateur
        then begin
             Pos := i ;
             break ;
        end ;

    if Pos = -1
    then
        Pos := length(ligne) +1 ;
            
    { Copie la commande }
    commande := StrCopyN(ligne, Pos - 1) ;

    { Enl�ve le 1er s�parateur }
    if Separateur <> ' '
    then begin
        commande := StrCopyToN(commande, 2) ;
        { Permet de supprimer l'espace apr�s le " ou ' }
        Pos := Pos + 1 ;
    end ;

    if Pos = -1
    then
        arguments := StrCopyToN(ligne, Pos + 1) ;
end ;

{*******************************************************************************
 * Affiche l'explorateur avec le lecteur demand�
 ******************************************************************************}
function TForm_fst_run.Lancer(commande : String; arguments : String) : Boolean ;
Var msg : String ;
    i : Integer ;
    operation : String ;
begin
    { On met le curseur }
    Cursor := crHourGlass ;

    { Par d�faut la commande n'a pu �tre lanc� }
    Result := False ;

    { On r�cup�re les attributs du fichier }
    i := FileGetAttr(msg) ;

    { Si -1 c'est qu'il y a une erreur. Le ficheir ne doit pas exister }
    if i <> -1
    then begin
        { Isole l'attribut R�pertoire }
        i := i and faDirectory ;

        { Si diff�rent de 0, c'est un r�pertoire }
        if i <> 0
        then
            operation := 'EXPLORE'
        else
            operation := 'OPEN' ;
   end
   else
       operation := 'OPEN' ;

    { Lance la commande. On ne fait pas une ligne sp�cifique car il n'y a pas
      d'argument donc on ne passe rien forc�ment }
    case ShellExecute(Handle, Pchar(operation), PChar(commande),
                 PChar(arguments),'',SW_SHOWNORMAL)
    of
        0                    : msg := 'Pas assez de m�moire disponible.' ;    
        ERROR_FILE_NOT_FOUND : msg := 'Fichier introuvable.' ;
        ERROR_BAD_FORMAT     : msg := 'L''ex�cutable n''est pas un programme Win32 ou EXE valide' ;
        SE_ERR_ACCESSDENIED  : msg := 'L''acc�s au fichier est refus�.' ;
        SE_ERR_ASSOCINCOMPLETE : msg := 'Le programme associ� est invalide.' ;
        SE_ERR_DLLNOTFOUND   : msg := 'DLL introuvable pour le programme.' ;
        SE_ERR_NOASSOC       : begin
                                   ShellExecute(0, 'open', 'rundll32.exe', PChar('shell32.dll,OpenAs_RunDLL ' + commande), Pchar(commande), SW_SHOWNORMAL) ;
                                   msg := '' ;
                               end ;
        SE_ERR_OOM           : msg := 'Pas assez de m�moire pour appeler le programme' ;
        SE_ERR_SHARE         : msg := 'Violation de partage' ;
    else
        msg := '' ;
        Result := True ;
    end ;

    { On remet le curseur }
    Cursor := crDefault ;

    { S'il y a un message, c'est qu'il y a une erreur }
    if msg <> ''
    then
        Application.MessageBox(PChar(msg), 'Erreur', MB_OK or MB_ICONERROR) ;
end ;

{*******************************************************************************
 * Fermeture de la fen�tre et enregistrement des commandes
 ******************************************************************************}
procedure TForm_fst_run.FormClose(Sender: TObject;
  var Action: TCloseAction);
Var Registre : TRegistry ;
    i : Integer ;
    ListMRU : String ;  
begin
    Registre := TRegistry.Create;

    try
        Registre.RootKey := HKEY_CURRENT_USER ;

        if Registre.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU', False)
        then begin
            for i :=0 to (ComboBox1.Items.Count - 1) do
            begin
                ListMRU := ListMRU + Chr(97 + i) ;
                Registre.WriteString(Chr(97 + i), ComboBox1.Items[i] + '\1') ;
            end ;

            Registre.WriteString('MRUList', ListMRU) ;
            Registre.CloseKey;
        end ;
    finally
        Registre.Free;
    end;

end;

end.
