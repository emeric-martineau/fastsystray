program FastsysTray;

uses
  Forms,
  main in 'main.pas' {Form1},
  Windows,
  Messages,
  BoiteCreerRacourci in 'BoiteCreerRacourci.pas' {CreerRaccourci};

{$R *.RES}
begin
  Application.Initialize;
  Application.ShowMainForm := False ;
  Application.Title := 'FastSysTray';
  Application.CreateForm(TForm1, Form1);
  Application.Run ;
end.
