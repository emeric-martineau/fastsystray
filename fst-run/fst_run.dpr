program fst_run;

uses
  Forms,
  run in 'run.pas' {Form_fst_run};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Exécuter (Fast SysTray)';
  Application.CreateForm(TForm_fst_run, Form_fst_run);
  Application.Run;
end.
