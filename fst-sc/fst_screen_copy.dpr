program fst_screen_copy;

uses
  Forms, Windows,
  fst_sc in 'fst_sc.pas' {Form1};

{$R *.RES}

Var Fenetre : HWND ;

begin
  Application.Initialize;
  Application.Title := 'Fast SysTray - Copie d''écran';

  Fenetre := IsPrevinstance ;

  If Fenetre <> 0
  then begin
      SetFocus(Fenetre) ;
      SetForegroundWindow(Fenetre) ;
      
      Application.Terminate ;
  end
  else begin
    Application.CreateForm(TForm1, Form1);
    Application.Run;
  end ;
end.
