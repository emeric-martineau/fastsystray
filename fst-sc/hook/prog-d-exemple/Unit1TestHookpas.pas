unit Unit1TestHookpas;
//http://phidels.com
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

const

  HookDll = 'HOOKDLL.DLL' ;

type
  TProcCallBack = procedure(Msg:Integer); stdcall;
  TForm1 = class(TForm)
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    LabelnNumMessage: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private

  public
    // procedure qui sera déclenchée lorsqu'un message WM_COPYDATA arrivera
    procedure OnWmCopyData(var msg:TMessage); message WM_USER ; //WM_COPYDATA;
  end;

var
  Form1: TForm1;
  MouseHookStruct:TMouseHookStruct;

procedure FinalisationHook; stdcall; external HookDll;
function InitialisationHookClavier(HandelDestData : HWnd; ToucheEnPlus : ShortInt; Touche : Integer):Boolean; stdcall; external HookDll;
function InitialisationHookSouris(HandelDestData : HWnd):Boolean; stdcall; external HookDll;

implementation





{$R *.DFM}


procedure TForm1.OnWmCopyData(var msg: TMessage);
// procedure qui sera déclenchée lorsqu'un message WM_COPYDATA arrivera
// de la part de la dll HookDll
// ca va nous permettre de récupérer les données
begin
    Label2.Caption := 'OK' ;
end;



procedure TForm1.FormCreate(Sender: TObject);
begin
Caption := IntToStr(Handle) ;
//  if not InitialisationHookClavier(Handle, 3, VK_F11)
  if not InitialisationHookSouris(Handle)
  then
      ShowMessage('erreur à la création du Hook') ;
   //initialise le hook en faisant passer le handle de Form1 en paramètre
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FinalisationHook;
end;

end.
