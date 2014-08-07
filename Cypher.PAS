UNIT Cypher;

(*                                                                      *)
(* AUTHOR: Michael G. Slack                    DATE WRITTEN: 1998/02/19 *)
(* ENVIRONMENT: Sibyl                                                   *)
(*                                                                      *)
(* Unit defines a simple encryption/decryption component for a single   *)
(* string.  Code was based on/uses code from a component developed for  *)
(* Delphi by Gordon Bamber (TEncrypt/TBCrypt).                          *)
(* Thoughts for future expansion are setting up a cypher type property  *)
(* (Blowfish, RC4, RC5, MD5, etc.).  Also thought of are methods to     *)
(* encrypt/decrypt a tstringlist (memo), encrypt/decrypt a stream, or   *)
(* encrypt/decrypt a 'file'.                                            *)
(*                                                                      *)
(* -------------------------------------------------------------------- *)
(*                                                                      *)
(* REVISED: 1998/02/20 - Initial version compete.                       *)
(*          1998/03/04 - Fixed bugs, added key property.  (1.01)        *)
(*          1998/03/22 - Changed all LONGWORD to LONGINT.  Added an     *)
(*                       'Abs' call to the CodeKey function.  (1.02)    *)
(*                                                                      *)

INTERFACE

 USES Classes, Forms;

 CONST MaxEStrLen = 255;

 TYPE PESTR = ^TESTR;
      TESTR = STRING[MaxEStrLen];
      {Declare string cypher class}
      TCypher = CLASS(TComponent)
                 PRIVATE
                  FKeyStr : TESTR;
                  FKey : LONGINT;
                  FPlainStr : TESTR;
                  FCypherStr : TESTR;
                  FUNCTION MakeCodeStr(S : TESTR) : TESTR;
                  FUNCTION EncryptStr : TESTR;
                  FUNCTION DecryptStr : TESTR;
                  FUNCTION CodeKey(VAR S) : LONGINT;
                 PROTECTED
                  PROCEDURE SetupComponent; OVERRIDE;
                  PROCEDURE SetCypherStr(S : TESTR);
                  PROCEDURE SetPlainStr(S : TESTR);
                  PROCEDURE SetKey(V : LONGINT);
                  PROCEDURE SetKeyStr(S : TESTR);
                  FUNCTION  GetVersion : STRING;
                 PUBLIC
                  DESTRUCTOR Destroy; OVERRIDE;
                  PROPERTY PlainStr : TESTR Read FPlainStr
                                            Write SetCypherStr;
                  PROPERTY CypherStr : TESTR Read FCypherStr
                                             Write SetPlainStr;
                 PUBLISHED
                  PROPERTY Key : LONGINT Read FKey
                                         Write SetKey;
                  PROPERTY KeyStr : TESTR Read FKeyStr
                                          Write SetKeyStr;
                  PROPERTY Version : STRING Read GetVersion;
                 END;

(************************************************************************)

 EXPORTS TCypher,'Custom','Cypher.BMP';

(************************************************************************)

IMPLEMENTATION

 CONST IVersion : STRING[12] = 'Version 1.02';
       DefKCode : LONGINT = 4321;

 TYPE PLARRY = ^TLARRY;
      TLARRY = ARRAY[1..(MaxEStrLen DIV 4)] OF LONGINT;

(************************************************************************)

 FUNCTION TCypher.MakeCodeStr(S : TESTR) : TESTR;
     (* function to create a encoder string of same length as string *)

    VAR L, I : INTEGER;

  BEGIN (*tcypher.makecodestr*)
   Result := ''; L := Length(S);
   IF L = 0 THEN Exit;
   RandSeed := (FKey * L) DIV BYTE(S[L]);
   SetLength(Result,L);
   FOR I := 1 TO L DO
    Result[I] := Chr(32 + Random(95)); {makes chars between 32 and 127}
  END; (*tcypher.makecodestr*)

(************************************************************************)

 FUNCTION TCypher.EncryptStr : TESTR;
     (* function to encrypt string *)

    VAR Temp : TESTR;
        L, I : INTEGER;
        Cnt  : BYTE;

  BEGIN (*tcypher.encryptstr*)
   Temp := MakeCodeStr(FPlainStr);
   L := Length(FPlainStr);
   SetLength(Result,L);
   Result[L] := FPlainStr[L];
   FOR I := 1 TO (L-1) DO
    BEGIN {encrypt string}
     Cnt := BYTE(FPlainStr[I]) XOR BYTE(Temp[I]);
     Inc(Cnt,128 * Ord(Cnt < 32));
     Result[I] := CHAR(Cnt);
    END; {for i}
   Cnt := BYTE(FPlainStr[L]) XOR (L AND 127);
   Inc(Cnt,128 * Ord(Cnt < 32));
   Result[L] := CHAR(Cnt);
  END; (*tcypher.encryptstr*)

(************************************************************************)

 FUNCTION TCypher.DecryptStr : TESTR;
     (* function to decrypt string *)

    VAR Temp, T2 : TESTR;
        L, I     : INTEGER;
        Cnt      : BYTE;

  BEGIN (*tcypher.decryptstr*)
   T2 := FCypherStr; L := Length(T2);
   Cnt := BYTE(T2[L]) AND 127;
   T2[L] := CHAR(Cnt XOR L);
   Temp := MakeCodeStr(T2);
   SetLength(Result,L);
   Result[L] := T2[L];
   FOR I := 1 TO (L-1) DO
    BEGIN {decrypt string}
     Cnt := BYTE(T2[I]);
     Dec(Cnt,128 * Ord(BYTE(T2[I]) > 127));
     Result[I] := CHAR(Cnt XOR BYTE(Temp[I]));
    END; {for i}
  END; (*tcypher.decryptstr*)

(************************************************************************)

 FUNCTION TCypher.CodeKey(VAR S) : LONGINT;
     (* function to create random 'seed' value from keystr *)

    VAR Len : BYTE ABSOLUTE S;
        pp  : PLARRY;
        Tmp : LONGINT;
        II  : INTEGER;

  BEGIN (*tcypher.codekey*)
   Tmp := 0; pp := PLARRY(@S);
   FOR II := 1 TO (Len DIV 4) DO
    Tmp := Tmp XOR pp^[II];
   Result := Abs(Tmp);
  END; (*tcypher.codekey*)

(************************************************************************)

 PROCEDURE TCypher.SetupComponent;
  BEGIN
   INHERITED SetupComponent;
   FKey := DefKCode; {default key code}
   FKeyStr := ''; FCypherStr := ''; FPlainStr := '';
  END;

(************************************************************************)

 PROCEDURE TCypher.SetCypherStr(S : TESTR);
     (* procedure to encrypt plain text string for property *)

  BEGIN (*tcypher.setcypherstr*)
   FPlainStr := S;
   IF S <> ''
    THEN FCypherStr := EncryptStr
   ELSE FCypherStr := '';
  END; (*tcypher.setcypherstr*)

(************************************************************************)

 PROCEDURE TCypher.SetPlainStr(S : TESTR);
     (* procedure to decrypt encrypted string for property *)

  BEGIN (*tcypher.setplainstr*)
   FCypherStr := S;
   IF S <> ''
    THEN FPlainStr := DecryptStr
   ELSE FPlainStr := '';
  END; (*tcypher.setplainstr*)

(************************************************************************)

 PROCEDURE TCypher.SetKey(V : LONGINT);
     (* procedure to set keycode property *)

  BEGIN (*tcypher.setkey*)
   FKey := V;
   FKeyStr := ''; {clear out key string - set keycode manually}
  END; (*tcypher.setkey*)

(************************************************************************)

 PROCEDURE TCypher.SetKeyStr(S : TESTR);
     (* procedure to set key string for property *)

  BEGIN (*tcypher.setkeystr*)
   FKeyStr := S;
   IF S <> ''
    THEN FKey := CodeKey(S)
   ELSE FKey := DefKCode;   {reset key to default}
  END; (*tcypher.setkeystr*)

(************************************************************************)

 FUNCTION TCypher.GetVersion : STRING;
     (* function to return component version to property *)

  BEGIN (*tcypher.getversion*)
   Result := IVersion;
  END; (*tcypher.getversion*)

(************************************************************************)

 DESTRUCTOR TCypher.Destroy;
  BEGIN
   INHERITED Destroy;
  END;

(************************************************************************)

INITIALIZATION
 RegisterClasses([TCypher]);
END. (*of unit*)
