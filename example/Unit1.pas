unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls,
  kcMapViewer, kcMapViewerGLGeoNames, kcMapViewerDEFPC
  (*
  {$IFDEF WINDOWS}, kcMapViewerDEWin32{$ENDIF}
  {$IFDEF ENABLE_SYNAPSE}, kcMapViewerDESynapse{$ENDIF}
  *)
  ;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button2: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    ComboBox1: TComboBox;
    CbLocations: TComboBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    mv: TMapViewer;
    MVGLGeoNames1: TMVGLGeoNames;
    Panel1: TPanel;
    TrackBar1: TTrackBar;
    procedure Button2Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure CheckBox3Change(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormDblClick(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
  private
    FDownloader: TCustomDownloadEngine;
    procedure DoBeforeDownload(Url: string; str: TStream; var CanHandle: Boolean);
    procedure DoAfterDownload(Url: string; str: TStream);
    procedure UpdateLocationHistory(ALocation: String);
    procedure ReadFromIni;
    procedure WriteToIni;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

uses
  inifiles, md5, LazFileUtils;

const
  MAX_LOCATIONS_HISTORY = 50;

function CalcIniName: String;
begin
  Result := ChangeFileExt(Application.ExeName, '.ini');
end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  p: TIntPoint;
  r: TRealPoint;
begin
  p := mv.GetMouseMapPixel(X, Y);
  Label2.Caption := Format('Pixel: %d:%d', [p.X, p.Y]);
  p := mv.GetMouseMapTile(X, Y);
  Label3.Caption := Format('Tile: %d:%d', [p.X, p.Y]);
  r := mv.GetMouseMapLongLat(X, Y);
  Label4.Caption := Format('Long: %g', [r.X]);
  Label5.Caption := Format('Lat: %g', [r.Y]);

  r := mv.CenterLongLat;
  Label6.Caption := Format('Long: %g', [r.X]);
  Label7.Caption := Format('Lat: %g', [r.Y]);
end;

procedure TForm1.FormDblClick(Sender: TObject);
begin
  TrackBar1.Position := mv.Zoom;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  if Sender = TrackBar1 then
    mv.Zoom := TrackBar1.Position;
end;

procedure TForm1.DoBeforeDownload(Url: string; str: TStream;
  var CanHandle: Boolean);
var
  x: string;
  f: TFileStream;
begin
  x := 'cache'+ DirectorySeparator + MDPrint(MD5String(Url));
  if FileExistsUTF8(x) then
  begin
    f := TFileStream.Create(x, fmOpenRead);
    try
      str.Position := 0;
      str.CopyFrom(f, f.Size);
      str.Position := 0;
      CanHandle := True;
    finally
      f.Free;
    end;
  end
  else
    CanHandle := False;
end;

procedure TForm1.DoAfterDownload(Url: string; str: TStream);
var
  x: string;
  f: TFileStream;
begin
  if not DirectoryExistsUTF8('cache') then
    ForceDirectoriesUTF8('cache');
  x := 'cache' + DirectorySeparator + MDPrint(MD5String(Url));
  if (not FileExists(x)) and (not (str.Size = 0)) then
  begin
    f := TFileStream.Create(x, fmCreate);
    try
      str.Position := 0;
      f.CopyFrom(str, str.Size);
    finally
      f.Free;
    end;
  end;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  mv.Source := TMapSource(ComboBox1.ItemIndex);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FDownLoader := TMVDEFpc.Create(self);

  (*
  {$IFDEF WINDOWS}
  FDownloader := TMVDEWin32.Create(Self);
  {$ENDIF}
  {$IFDEF ENABLE_SYNAPSE}
  FDownloader := TMVDESynapse.Create(Self);
  {$ENDIF}
  *)

  FDownloader.OnAfterDownload := @DoAfterDownload;
  FDownloader.OnBeforeDownload := @DoBeforeDownload;
  mv.DownloadEngine := FDownloader;

  ReadFromIni;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  WriteToIni;
  FDownloader.Free;
end;

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
  mv.Debug := CheckBox1.Checked;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  mv.BeginUpdate;
  MVGLGeoNames1.LocationName := CbLocations.Text;
  mv.Zoom := 12;
  TrackBar1.Position := mv.Zoom;
  mv.Geolocate;
  mv.EndUpdate;
  UpdateLocationHistory(CbLocations.Text);
end;

procedure TForm1.CheckBox2Change(Sender: TObject);
begin
  mv.UseThreads := CheckBox2.Checked;
end;

procedure TForm1.CheckBox3Change(Sender: TObject);
begin
  mv.DoubleBuffering:=CheckBox3.Checked;
end;

procedure TForm1.UpdateLocationHistory(ALocation: String);
var
  idx: Integer;
begin
  idx := CbLocations.Items.IndexOf(ALocation);
  if idx <> -1 then
    CbLocations.Items.Delete(idx);
  CbLocations.Items.Insert(0, ALocation);
  while CbLocations.Items.Count > MAX_LOCATIONS_HISTORY do
    CbLocations.Items.Delete(Cblocations.items.Count-1);
  CbLocations.Text := ALocation;
end;

procedure TForm1.ReadFromIni;
var
  ini: TCustomIniFile;
  L: TStringList;
  i: Integer;
  s: String;
begin
  ini := TMemIniFile.Create(CalcIniName);
  try
    L := TStringList.Create;
    try
      ini.ReadSection('Locations', L);
      for i:=0 to L.Count-1 do begin
        s := ini.ReadString('Locations', L[i], '');
        if s <> '' then
          CbLocations.Items.Add(s);
      end;
    finally
      L.Free;
    end;
  finally
    ini.Free;
  end;
end;

procedure TForm1.WriteToIni;
var
  ini: TCustomIniFile;
  L: TStringList;
  i: Integer;
begin
  ini := TMemIniFile.Create(CalcIniName);
  try
    ini.EraseSection('Locations');
    for i := 0 to CbLocations.Items.Count-1 do
      ini.WriteString('Locations', 'Item'+IntToStr(i), CbLocations.Items[i]);
  finally
    ini.Free;
  end;
end;

end.
