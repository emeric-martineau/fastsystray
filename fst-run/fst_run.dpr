program fst_run;

uses
  Forms, Windows,
  run in 'run.pas' {Form_fst_run};

{$R *.RES}
Var Fenetre : HWND ;

begin
  Application.Initialize;
  Application.Title := 'Ex?cuter (Fast SysTray)';

  Fenetre := IsPrevinstance ;

  If Fenetre <> 0
  then begin
      SetFocus(Fenetre) ;
      SetForegroundWindow(Fenetre) ;
      
      Application.Terminate ;
  end
  else begin
    Application.CreateForm(TForm_fst_run, Form_fst_run);
    Application.Run;
  end ;
end.
