Unit CyprWin;

(*                                                                      *)
(* AUTHOR: Michael G. Slack                    DATE WRITTEN: 1998/03/25 *)
(*                                                                      *)
(* Program used to test the Tcypher component.                          *)
(*                                                                      *)

Interface

 Uses Classes, Forms, Graphics, StdCtrls, Buttons, Cypher;

 Type TCypherWin = Class(TForm)
                    Label1      : TLabel;
                    EPlainTxt   : TEdit;
                    Label2      : TLabel;
                    EEncryptTxt : TEdit;
                    Label3      : TLabel;
                    EKeyStr     : TEdit;
                    Label4      : TLabel;
                    EKeyCode    : TEdit;
                    EncBtn      : TBitBtn;
                    DecBtn      : TBitBtn;
                    ExitBtn     : TBitBtn;
                    Cypher1     : TCypher;
                    Procedure CypherWinOnShow(Sender : TObject);
                    Procedure EncBtnOnClick(Sender : TObject);
                    Procedure DecBtnOnClick(Sender : TObject);
                   Private
                    {Insert private declarations here}
                   Public
                    PROCEDURE ChangeLabels;
                    PROCEDURE Change_Key;
                   End;

 Var CypherWin : TCypherWin;

(************************************************************************)

Implementation

 USES SysUtils;

(************************************************************************)

 Procedure TCypherWin.CypherWinOnShow(Sender : TObject);
  Begin
   ChangeLabels;
  End;

(************************************************************************)

 Procedure TCypherWin.EncBtnOnClick(Sender : TObject);
    VAR TT : TESTR;
  Begin
   Change_Key;
   TT := Trim(EPlainTxt.Text);
   IF TT <> ''
    THEN BEGIN {encrypt string - show results}
          Cypher1.PlainStr := EPlainTxt.Text;
          ChangeLabels;
         END; {then}
  End;

(************************************************************************)

 Procedure TCypherWin.DecBtnOnClick(Sender : TObject);
    VAR TT : TESTR;
  Begin
   Change_Key;
   TT := Trim(EEncryptTxt.Text);
   IF TT <> ''
    THEN BEGIN {decrypt string - show results}
          Cypher1.CypherStr := TT;
          ChangeLabels;
         END; {then}
  End;

(************************************************************************)

 PROCEDURE TCypherWin.ChangeLabels;
  BEGIN
   EKeyStr.Text := Cypher1.KeyStr;
   EKeyCode.Text := IntToStr(Cypher1.Key);
   EPlainTxt.Text := Cypher1.PlainStr;
   EEncryptTxt.Text := Cypher1.CypherStr;
  END;

(************************************************************************)

 PROCEDURE TCypherWin.Change_Key;
    VAR Pw : TESTR;
        Ky : LONGINT;
        TT : STRING[20];
        E  : INTEGER;
  BEGIN
   Pw := Trim(EKeyStr.Text);
   TT := Trim(EKeyCode.Text);
   IF (TT = '') AND (Pw = '') THEN Exit;
   IF TT <> '' THEN Val(TT,Ky,E) ELSE E := 1;
   IF (E = 0) AND (Ky <> Cypher1.Key)
    THEN Cypher1.Key := Ky {set key field then}
   ELSE BEGIN {password/key string set?}
         IF (Pw <> '') AND (Pw <> Cypher1.KeyStr)
          THEN Cypher1.KeyStr := Pw;
        END; {else}
  END;

(************************************************************************)

Initialization
 RegisterClasses([TCypherWin, TLabel, TEdit, TBitBtn, TCypher]);
End.
