{*******************************************************************************
 * Librairie de Hook clavier du projet Fast SysTray.
 *
 * D'après le travail du site HTTP://WWW.PHIDELS.COM
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
 * Appel :
 * -------
 * InitialisationHookClavier(
 *                    le handle de la fenêtre
 *                    -
 *                    0 : pas de touche associés
 *                    1 : touche Shift
 *                    2 : touche Control
 *                    3 : touche Alt
 *                    -
 *                    Touche clavier (en virtuel VK_???)
 *                    ) ;
 *
 * InitialisationHookSouris(HandleDestData : HWnd) ;
 * 
 * FinalisationHook() ;
 *
 * Explication :
 * -------------
 * Si la(les) touche(s) désirée(s) est(sont) appuyée(s), le programme reçoit un
 * message WM_USER.
 * Envoie un message quand clique droit
 ******************************************************************************}
library HookDll;

uses SysUtils, Windows, Messages ;


type
  { type servant au file mappping }
  TDonneesHook = class
     HookHandle:HHook ;      { Handle du Hook retourné par SetWindowsHookEx }
     HandleDest:THandle ;    { Le Handle de la TForm auquel on veut envoyer le message }
     KeyMore   : ShortInt ;  { Indique si le shift doit être activé ou non }
     Key       : Integer ;   { Touche qui déclanche l'action }
  end;

Var
   DonneesHook : TDonneesHook = nil ; { Pointeur sur les données qui seront mappées: le FileView }
   HookMap : THandle = 0 ;            { Contiendra le Handle du FileMapping }

{*******************************************************************************
 * Cette fonction reçoit tout les message venant du clavier.
 * Si les touches voulues sont actionnées, elle envoie le message WM_USER à
 * l'application.
 ******************************************************************************}
function HookActionCallBackKeyBoard(Code: integer; Touche: WPARAM; KeyBoardHook: LPARAM):LRESULT; stdcall;
Var Premier : Boolean ;
begin
    Result := 0 ;
    Premier := False ;

    { HC_ACTION indique qu'e les paramètre Msg et KeyBoardHook contient des
      informations }
    if Code = HC_ACTION
    then begin

        case DonneesHook.KeyMore of
            0 : Premier := True ;
            1 : begin
                    { Touche Shift }
                    if (GetKeyState(VK_SHIFT) < 0)
                    then
                        Premier := True ;
                end ;
            2 : begin
                    { Touche Shift }
                    if (GetKeyState(VK_CONTROL) < 0)
                    then
                        Premier := True ;
                end ;
            3 : begin
                    { Touche Shift }
                    if (GetKeyState(VK_MENU) < 0)
                    then
                        Premier := True ;
                end ;
            else
                Premier := True ;    
        end ;

        { la touche voulue est-elle activé ? }
        if (Premier = True) and (Touche = DonneesHook.Key)
        then begin
            SendMessage(DonneesHook.HandleDest, WM_USER, 0, 0) ;
            { Si Result = 0, le message continue et donc l'application va
              recevoir le message clavier, ce qu'on ne veut surtout pas pour
              ne pas géner la copie d'écran }
            Result := 1 ;
        end ;
    end;

    { Si code inférieur à 0, on transmet au prochain Hook clavier }
    if (Code < 0)
    then
        Result := CallNextHookEx(DonneesHook.HookHandle, Code, Touche, KeyBoardHook) ;
end;

{*******************************************************************************
 * Fonction appelé par les programmes pour initialiser notre Hook clavier.
 * On transmet le pointeur de données, si le shift doit être activé et la touche
 ******************************************************************************}
function InitialisationHookClavier(HandleDestData : HWnd; ToucheEnPlus : ShortInt; Touche : Integer):Boolean; stdcall; export;
begin
    Result := false ;

    if (DonneesHook.HookHandle = 0) and (HandleDestData <> 0)
    then begin
        { SetWindowsHookEx permet de donner à windows le nom de la fonction
         (ici HookActionCallBack) qui sera exécutée à chaque fois qu'il reçoit
         un message de type WH_KEYBOARD }
        DonneesHook.HookHandle := SetWindowsHookEx(WH_KEYBOARD, HookActionCallBackKeyBoard, HInstance, 0) ;
        DonneesHook.HandleDest := HandleDestData ;
        DonneesHook.KeyMore := ToucheEnPlus ;
        DonneesHook.Key := Touche ;
        Result := (DonneesHook.HookHandle <> 0) ;
    end;
end;

{*******************************************************************************
 * Cette fonction reçoit tout les message venant du clavier.
 * Si les touches voulues sont actionnées, elle envoie le message WM_USER à
 * l'application.
 ******************************************************************************}
function HookActionCallBackSouris(Code: integer; Msg: WPARAM; MouseHook: LPARAM):LRESULT; stdcall;
begin
    Result := 0 ;

    { HC_ACTION indique qu'e les paramètre Msg et KeyBoardHook contient des
      informations }
    if Code = HC_ACTION
    then begin

        if (GetAsyncKeyState(VK_RBUTTON) and $8000) <> 0
        then begin
            SendMessage(DonneesHook.HandleDest, WM_USER, 0, 0) ;
            Result := 1 ;
        end ;
    end;

    { Si code inférieur à 0, on transmet au prochain Hook clavier }
    if (Code < 0)
    then
        Result := CallNextHookEx(DonneesHook.HookHandle, Code, Msg, MouseHook) ;
end;

{*******************************************************************************
 * Fonction appelé par les programmes pour initialiser notre Hook clavier.
 * On transmet le pointeur de données, si le shift doit être activé et la touche
 ******************************************************************************}
function InitialisationHookSouris(HandleDestData : HWnd) : Boolean; stdcall; export;
begin
    Result := false ;

    if (DonneesHook.HookHandle = 0) and (HandleDestData <> 0)
    then begin
        { SetWindowsHookEx permet de donner à windows le nom de la fonction
         (ici HookActionCallBack) qui sera exécutée à chaque fois qu'il reçoit
         un message de type WH_KEYBOARD }
        DonneesHook.HookHandle := SetWindowsHookEx(WH_MOUSE, HookActionCallBackSouris, HInstance, 0) ;
        DonneesHook.HandleDest := HandleDestData ;
        Result := (DonneesHook.HookHandle <> 0) ;
    end;
end;

{*******************************************************************************
 * Fonction désactivant notre Hook
 ******************************************************************************}
procedure FinalisationHook; stdcall; export;
begin
    if DonneesHook.HookHandle <> 0
    then begin
        UnhookWindowsHookEx(DonneesHook.HookHandle) ;
        DonneesHook.HookHandle := 0 ;
    end;
end;

{*******************************************************************************
 * Fonction créant un espace mémoire partagé
 ******************************************************************************}
procedure LibraryProc(AReason : Integer) ;
begin
    case AReason of
        DLL_PROCESS_ATTACH : begin
                             { Il faut d'abord créer le FileMapping.

                               Le $FFFFFFFF indique seulement que ce n'est pas
                               un fichier qui sera mappé, mais des données.

                               TDonneesHook.InstanceSize permet de donner à
                               Windows la bonne taille de mémoire à réserver }
                             HookMap := CreateFileMapping($FFFFFFFF, nil, PAGE_READWRITE, 0, TDonneesHook.InstanceSize, 'FastSysTrayCopieEcranv1.1') ;

                             { Ensuite faire un View sur tout le fichier }
                             DonneesHook := MapViewOfFile(HookMap, FILE_MAP_WRITE, 0, 0, 0);
                             end;
        DLL_PROCESS_DETACH : begin
                             { libérer les ressources prisent par notre FileMapping }
                             UnMapViewOfFile(DonneesHook) ;
                             CloseHandle(HookMap) ;
                             end ;
        DLL_THREAD_ATTACH : ;
        DLL_THREAD_DETACH : ;
    end;
end;

{*******************************************************************************
 * Début de procédure
 ******************************************************************************}
exports
  InitialisationHookClavier,
  InitialisationHookSouris,  
  FinalisationHook ;

begin
  DllProc := @LibraryProc ;
  LibraryProc(DLL_PROCESS_ATTACH) ;
end.

