{*******************************************************************************
 * Copyright (C) 2004 MARTINEAU Emeric (php4php@free.fr)
 *
 * Fast SysTray - Module Exécuter.
 *
 * Version 1.1.0
 *
 * Le module Exécuter reprand les mêmes fonctionnalités que la boit de dialogue
 * Exécuter de Windows mais étend son fonctionnement avec la possibilité de ne
 * pas mémoriser la commande tapée et d'effacer la liste.
 *
 * ATTENTION : Ce programme ne fait pas exactement la même chose que l'Exécuter
 * de Windows.
 * Lorsqu'il enregistre les commandes dans la base de registre, il aligne les
 * Valeur a,b,c et ne s'embête pas à les mettre dans le bon ordre.
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
    { Déclarations privées }
    function  StrCopyN(chaine : String; valMax : Integer) : String ;
    function  StrCopyToN(chaine : String; startPos : Integer) : String ;
    procedure SeparerCommandeArguments(ligne : String; var commande : String; var arguments : String) ;
    function  Lancer(commande : String; arguments : String) : Boolean ;
  public
    { Déclarations publiques }
  end;

var
  Form_fst_run: TForm_fst_run;
  Function  IsPrevInstance : HWND ;
  
implementation

{$R *.DFM}

{*******************************************************************************
 * cette fonction renvoie 0 s'il n'y a pas d'instance du même programme déjà
 * lancée sinon le handle de l'instance déjà lancée c'est à dire une valeur <>0
 * cette fonction est appelé dans le source du projet. voir ce source pour
 * comprendre.
 ******************************************************************************}
Function IsPrevInstance : HWND ;
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
 * Création de la feuille
 ******************************************************************************}
procedure TForm_fst_run.FormCreate(Sender: TObject);
Var Registre : TRegistry ;
    MRUList : String ;
    i : Integer ;
    NbMRUList : Integer ;
    tmp : String ;
    Rectangle : TRect ;
begin
  { Utilisation de SystemParametersInfo pour récupérer la surface (rectangle) de
    travail de l'écran disponible }
  SystemParametersInfo (SPI_GETWORKAREA,0,@Rectangle,0);

    Registre := TRegistry.Create;

    try
        Registre.RootKey := HKEY_CURRENT_USER ;

        if Registre.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU', False)
        then begin
            { S'il y a la clef MRUList de présent on lit ce qu'elle contient }
            if Registre.ValueExists('MRUList')
            then begin
                MRUList := Registre.ReadString('MRUList') ;
                NbMRUList := Length(MRUList) ;

                { Pour chaque lettre }
                for i := 1 to NbMRUList do
                    { On vérifie que la valeur associée à la lettre existe }
                    if Registre.ValueExists(MRUList[i])
                    then begin
                        { A la fin de la chaine, il y a toujours '\1'. Pourquoi ? }
                        tmp := Registre.ReadString(MRUList[i]) ;
                        tmp := StrCopyN(tmp, Length(tmp) - 2) ;

                        { Si la valeur existe on l'ajoute à la liste }
                        ComboBox1.Items.Add(tmp) ;
                    end ;

                { Configure le texte }
                ComboBox1.Text := ComboBox1.Items[0] ;
            end ;
            
            Registre.CloseKey;
        end ;
    finally
    end;

    { Fermer la fenêtre après exécution }
    try
        Registre.CloseKey ;
        Registre.OpenKey('Software\Fast SysTray', True) ;

        { Fermer la fenêtre executer }
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

        { Fermer la fenêtre executer }
        if Registre.ValueExists('PositionFenetreExec')
        then begin
            case Registre.ReadInteger('PositionFenetreExec') of
                0 : begin //en haut à gauche
                        Left := Rectangle.Left ;
                        Top := Rectangle.Top ;
                    end ;
                1 : begin //en bas à gauche
                        Left := Rectangle.Left ;
                        Top := Rectangle.Bottom - Height ;
                    end ;
                2 : begin //en haut à droite
                        Left := Rectangle.Right - Width ;
                        Top := Rectangle.Top ;
                    end ;
                3 : begin //en bas à droite
                        Left := Rectangle.Right - Width ;
                        Top := Rectangle.Bottom - Height ;
                    end ;
                4 : Position := poDesktopCenter ; //au milieu du bureau  (poDesktopCenter)
                5 : Position := poScreenCenter ; //au milieu de l'écran (poScreenCenter)
                6 : Position := poDefaultPosOnly ; //laisser Windows positionner la fenêtre (poDefaultPosOnly)

            end ;
        end ;

        Registre.CloseKey ;
    finally
        Registre.Free ;
    end ;

    { Désactive le bouton OK }
    if Length(ComboBox1.Text) <= 0
    then
        OK.Enabled := False ;

end;

{*******************************************************************************
 * Copie les X premiers caractères d'une chaine.
 * Si la chaine est plus courte que ce qu'on veut copier, c'est la chaine qui
 * est retourné.
 *
 * Entrée : chaine à copier, nombre de caractères à copier
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
 * Copie du caractère X à la fin de la chaine.
 * Si la position est suppérieur à la taille de la chaine, une chaine vide est
 * retournée.
 *
 * Entrée : chaine à copier, position de début de copie
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
    if Application.MessageBox('Voulez-vous réellement effacer l''historique des commandes ?' +
                              #10#13'Cette opération est irréversible.'#10#13 +
                              'ATTENTION ! Pour que certaines versions de Windows prennent en compte le changement, l''explorateur doit être relancé.'
                              , 'Effacer l''historique', MB_YESNO + MB_ICONQUESTION) = ID_YES
    then begin
        Registre := TRegistry.Create;

        try
            Registre.RootKey := HKEY_CURRENT_USER ;

            if Registre.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU', False)
            then begin
                { Créer l'objet reccueillant la liste des valeurs }
                ListeValeurs := TStringList.Create ;

                { Récupère les valeurs }
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
        { Cherche l'occurence dans la liste pour voir si la commande est déjà
          connue }
        if ComboBox1.ItemIndex = -1
        then
            ComboBox1.ItemIndex := ComboBox1.Items.IndexOf(ComboBox1.Text) ;

        { Si ItemIndex encore à -1 c'est qu'il s'agit d'une nouvelle commande }
        if ComboBox1.ItemIndex = -1
        then begin
             { Ajoute la commande à la liste }
             ComboBox1.Items.Insert(0, ComboBox1.Text) ;
             { On supprime l'élément 26. Si la liste est remplit, on supprime ce
               qui dépasse }
             ComboBox1.Items.Delete(26) ;
        end
        else begin
            { Il ne s'agit pas d'une nouvelle commande, alors on remonte celle
              sélectionner dans la liste pour qu'elle devienne la première }
            ComboBox1.Items.Move(ComboBox1.ItemIndex, 0) ;
            ComboBox1.ItemIndex := 0 ;
        end ;

        if CloseWindowsAfterRun
        then
            Close ;
    end ;

end;

{*******************************************************************************
 * Sépare la commande de l'argument
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

    { Recherche la position du séparateur }    
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

    { Enlève le 1er séparateur }
    if Separateur <> ' '
    then begin
        commande := StrCopyToN(commande, 2) ;
        { Permet de supprimer l'espace après le " ou ' }
        Pos := Pos + 1 ;
    end ;

    if Pos = -1
    then
        arguments := StrCopyToN(ligne, Pos + 1) ;
end ;

{*******************************************************************************
 * Affiche l'explorateur avec le lecteur demandé
 ******************************************************************************}
function TForm_fst_run.Lancer(commande : String; arguments : String) : Boolean ;
Var msg : String ;
    i : Integer ;
    operation : String ;
begin
    { On met le curseur }
    Cursor := crHourGlass ;

    { Par défaut la commande n'a pu être lancé }
    Result := False ;

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
    case ShellExecute(Handle, Pchar(operation), PChar(commande),
                 PChar(arguments),'',SW_SHOWNORMAL)
    of
        0                    : msg := 'Pas assez de mémoire disponible.' ;    
        ERROR_FILE_NOT_FOUND : msg := 'Fichier introuvable.' ;
        ERROR_BAD_FORMAT     : msg := 'L''exécutable n''est pas un programme Win32 ou EXE valide' ;
        SE_ERR_ACCESSDENIED  : msg := 'L''accès au fichier est refusé.' ;
        SE_ERR_ASSOCINCOMPLETE : msg := 'Le programme associé est invalide.' ;
        SE_ERR_DLLNOTFOUND   : msg := 'DLL introuvable pour le programme.' ;
        SE_ERR_NOASSOC       : begin
                                   ShellExecute(0, 'open', 'rundll32.exe', PChar('shell32.dll,OpenAs_RunDLL ' + commande), Pchar(commande), SW_SHOWNORMAL) ;
                                   msg := '' ;
                               end ;
        SE_ERR_OOM           : msg := 'Pas assez de mémoire pour appeler le programme' ;
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
 * Fermeture de la fenêtre et enregistrement des commandes
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
