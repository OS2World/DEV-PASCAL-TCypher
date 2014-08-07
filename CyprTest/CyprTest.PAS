Program CyprTest;

 Uses Forms, Graphics, CyprWin;

{$r CyprTest.SCU}

Begin
 Application.Create;
 Application.CreateForm(TCypherWin, CypherWin);
 Application.Run;
 Application.Destroy;
End.
