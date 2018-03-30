program Project1;

{$mode objfpc}{$H+}
{$define UseCThreads}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Forms, Interfaces, sysutils,
  Unit1 in 'Unit1.pas', kcmapviewerpckg {Form1},
  kcMapViewer in 'kcMapViewer.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
