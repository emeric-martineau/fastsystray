unit fst_sc;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, ClipBrd, XPTheme;

Const
    HookDll = 'HOOKDLL.DLL' ;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    plein_ecran: TRadioButton;
    bureau: TRadioButton;
    fenetre_active: TRadioButton;
    zone: TRadioButton;
    Label1: TLabel;
    Label2: TLabel;
    EditX: TEdit;
    EditY: TEdit;
    GroupBox2: TGroupBox;
    temporisateur: TRadioButton;
    tempo: TEdit;
    UpDown1: TUpDown;
    Timer1: TTimer;
    Capturer: TButton;
    Annuler: TButton;
    Label3: TLabel;
    EditX2: TEdit;
    Label4: TLabel;
    EditY2: TEdit;
    GroupBox3: TGroupBox;
    beeper: TCheckBox;
    pointeur: TCheckBox;
    CliqueDroit: TRadioButton;
    Clavier: TRadioButton;
    Touche: TComboBox;
    procedure zoneClick(Sender: TObject);
    procedure temporisateurClick(Sender: TObject);
    procedure AnnulerClick(Sender: TObject);
    procedure CapturerClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure tempoKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Déclarations privées}
    Curseur : HICON ;
    P: TPoint;
    procedure ConfigurerCapture ;
    procedure CapturerEcran(x1,y1,x2,y2 : Integer) ;
    procedure ReceiveMsg(var msg:TMessage); message WM_USER ;
  public
    { Déclarations publiques}
  end;

var
  Form1: TForm1;

  Function  IsPrevInstance : HWND ;

  procedure FinalisationHook; stdcall; external HookDll;
  function InitialisationHookClavier(HandelDestData : HWnd; ToucheEnPlus : ShortInt; Touche : Integer):Boolean; stdcall; external HookDll;
  function InitialisationHookSouris(HandelDestData : HWnd):Boolean; stdcall; external HookDll;

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
 * Quand on clique sur un bouton radio de Zone
 ******************************************************************************}
procedure TForm1.zoneClick(Sender: TObject);
begin
    Label1.Enabled := Zone.Checked ;
    Label2.Enabled := Zone.Checked ;
    Label3.Enabled := Zone.Checked ;
    Label4.Enabled := Zone.Checked ;
    EditY.Enabled := Zone.Checked ;
    EditX.Enabled := Zone.Checked ;
    EditY2.Enabled := Zone.Checked ;
    EditX2.Enabled := Zone.Checked ;

    if Zone.Checked
    then begin
        EditY.Color := clWindow ;
        EditX.Color := clWindow ;
        EditY2.Color := clWindow ;
        EditX2.Color := clWindow ;
    end
    else begin
        EditY.Color := clBtnFace ;
        EditX.Color := clBtnFace ;
        EditY2.Color := clBtnFace ;
        EditX2.Color := clBtnFace ;
    end
end;

{*******************************************************************************
 * Quand on clique sur un bouton de Capturer
 ******************************************************************************}
procedure TForm1.temporisateurClick(Sender: TObject);
begin
    Tempo.Enabled := Temporisateur.Checked ;
    UpDown1.Enabled := Temporisateur.Checked ;
    Touche.Enabled := Clavier.Checked ;

    if Temporisateur.Checked
    then
        Tempo.Color := clWindow
    else
        Tempo.Color := clBtnFace ;

    if Clavier.Checked
    then
        Touche.Color := clWindow
    else
        Touche.Color := clBtnFace ;

end;

{*******************************************************************************
 * Quand on clique sur Annuler
 ******************************************************************************}
procedure TForm1.AnnulerClick(Sender: TObject);
begin
    Close ;
end;

{*******************************************************************************
 * Quand on clique sur capturer
 ******************************************************************************}
procedure TForm1.CapturerClick(Sender: TObject);
Var
    ToucheEnPlus : ShortInt ;
    ToucheClavier : Integer ;
begin
    { Cache l'application }
    Visible := False ;
    Application.ShowMainForm := False ;

    { Temporisateur }
    if Temporisateur.Checked
    then begin
        Timer1.Interval := StrToInt(Tempo.Text) * 1000 ;
        Timer1.Enabled := True ;
    end
    { Clique droit }
    else if CliqueDroit.Checked
    then begin
        if not InitialisationHookSouris(Handle)
        then begin
            Application.MessageBox('Impossible d''initialiser le hook souris', 'Erreur', MB_OK) ;
            Visible := True ;
            Application.ShowMainForm := True ;
        end
        else
            FinalisationHook ;
    end
    { Clavier } 
    else if Clavier.Checked
    then begin
        { Identifie les touches en fonction de la liste }
        case Touche.ItemIndex of
            0..11 : begin
                        ToucheEnPlus := 0 ;
                        ToucheClavier := VK_F1 + Touche.ItemIndex ;
                    end ;
            12..23 : begin
                        ToucheEnPlus := 1 ;
                        ToucheClavier := VK_F1 + Touche.ItemIndex - 12 ;
                    end ;
            24..35 : begin
                        ToucheEnPlus := 2 ;
                        ToucheClavier := VK_F1 + Touche.ItemIndex - 24 ;
                    end ;
            36..47 : begin
                        ToucheEnPlus := 3 ;
                        ToucheClavier := VK_F1 + Touche.ItemIndex - 36 ;
                    end ;
            else
                ToucheEnPlus := 0 ;
                ToucheClavier := VK_F1 ;
        end ;

        if not InitialisationHookClavier(Handle, ToucheEnPlus, ToucheClavier)
        then begin
            Application.MessageBox('Impossible d''initialiser le hook souris', 'Erreur', MB_OK) ;
            Visible := True ;
            Application.ShowMainForm := True ;
        end
        else
            FinalisationHook ;
    end ;
end;

{*******************************************************************************
 * Configurer et lance la capture
 ******************************************************************************}
procedure TForm1.ConfigurerCapture ;
Var x1, y1, x2, y2 : integer ;
    Rectangle : TRect ;
begin
    Curseur := GetCursor() ;
    GetCursorPos(P) ;

    if Plein_Ecran.Checked
    then begin
        x1 := Screen.DesktopLeft ;
        y1 := Screen.DesktopTop ;
        x2 := Screen.DesktopWidth ;
        y2 := Screen.DesktopHeight ;
    end
    else if Bureau.Checked
    then begin
        SystemParametersInfo (SPI_GETWORKAREA,0,@Rectangle,0);

        x1 := Rectangle.Left ;
        y1 := Rectangle.Top ;
        x2 := Rectangle.Right ;
        y2 := Rectangle.Bottom ;
    end
    else if Fenetre_Active.Checked
    then begin
        GetWindowRect(GetForeGroundWindow, Rectangle) ;

        x1 := Rectangle.Left ;
        y1 := Rectangle.Top ;
        x2 := Rectangle.Right ;
        y2 := Rectangle.Bottom ;

        { Vérifie que les valeurs ne dépasse pas le burreau }
        SystemParametersInfo (SPI_GETWORKAREA,0,@Rectangle,0);

        if x1 < Rectangle.Left
        then
            x1 := Rectangle.Left ;

        if y1 < Rectangle.Top
        then
            y1 := Rectangle.Top ;

        if x2 > Rectangle.Right
        then
            x2 := Rectangle.Right ;

        if y2 > Rectangle.Bottom
        then
            y2 := Rectangle.Bottom ;
    end
    else begin
        x1 := StrToInt(EditX.Text) ;
        y1 := StrToInt(EditY.Text) ;
        x2 := StrToInt(EditX2.Text) ;
        y2 := StrToInt(EditY2.Text) ;
    end ;    

    CapturerEcran(x1, y1, x2, y2) ;

    if beeper.Checked
    then
        MessageBeep($FFFFFFFF) ;
    
    Visible := True ;
    Application.ShowMainForm := True ;
end ;

{*******************************************************************************
 * Capture l'écran
 ******************************************************************************}
procedure TForm1.CapturerEcran(x1, y1, x2, y2 : Integer) ;
var HandleDCBureau : HDC;
    Bmp1 : TBitmap ;
begin
    { Cache l'application car si on utilise les hooks, elle réapparait }
    Visible := False ;
    Application.ShowMainForm := False ;

    Bmp1 := TBitmap.Create ;

    { Prend le handle du bureau }
    HandleDCBureau := GetDC(GetDesktopWindow) ;

    try
        { La largeur et la hauteur de l'image est celle du bureau }
        Bmp1.Width := x2 - x1 ;
        Bmp1.Height := y2 - y1;

        { Recopie l'image }
        BitBlt(Bmp1.Canvas.Handle, 0, 0, Bmp1.Width , Bmp1.Height,
               HandleDCBureau, x1, y1, SrcCopy) ;

        if Pointeur.Checked
        then
            DrawIconEx(Bmp1.Canvas.Handle, P.x, P.y, Curseur, 0, 0, 0, 0, DI_NORMAL) ;

        Clipboard.Assign(Bmp1) ;
     finally
         ReleaseDC(GetDesktopWindow,HandleDCBureau);
     end;
end ;

{*******************************************************************************
 * Quand le timer se déclenche
 ******************************************************************************}
procedure TForm1.Timer1Timer(Sender: TObject);
begin
    Timer1.Enabled := False ;
    ConfigurerCapture ;
end;

{*******************************************************************************
 * Vérifie la validité de ce qui est saisie
 ******************************************************************************}
procedure TForm1.tempoKeyPress(Sender: TObject; var Key: Char);
begin
    { Si ce n'est pas une touche de contrôle }
    if Ord(Key) > 27
    then begin
        { si la touche n'est pas un chiffre }
        if (Ord(Key) < 48) or (Ord(Key) > 57)
        then begin
            Key := #0 ;
            MessageBeep($FFFFFFFF) ;
        end
        else if TEdit(Sender).Name = 'tempo'
        then
            if (StrToInt(Tempo.Text + Key) > 60) or (StrToInt(Tempo.Text + Key) < 1)
            then begin
                Key := #0 ;
                MessageBeep($FFFFFFFF) ;
            end ;
    end ;
end;

{*******************************************************************************
 * Recoit le message de copie
 ******************************************************************************}
procedure TForm1.ReceiveMsg(var msg:TMessage);
begin
    ConfigurerCapture ;
end ;

{*******************************************************************************
 * Enlève le hook clavier
 ******************************************************************************}
procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
end;

{*******************************************************************************
 * Création de la feuille
 ******************************************************************************}
procedure TForm1.FormCreate(Sender: TObject);
begin
    Touche.Color := clBtnFace ;
    Touche.Enabled := False ;
    Touche.ItemIndex := 0 ;
end;

end.
