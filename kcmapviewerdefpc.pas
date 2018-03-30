{ Map Viewer Download Engine Free Pascal HTTP Client

  Copyright (C) 2011 Maciej Kaczkowski / keit.co

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

  Taken from:
  https://forum.lazarus.freepascal.org/index.php/topic,12674.msg160255.html#msg160255

}

unit kcMapViewerDEFpc;

{$mode objfpc}{$H+}

interface

uses
  kcMapViewer, SysUtils, Classes;

type

  { TMVDEFPC }

  TMVDEFPC = class(TCustomDownloadEngine)
  protected
    procedure DoDownloadFile(const Url: string; str: TStream); override;
  end;

implementation

uses
  fphttpclient;

{ TMVDEFPC }

procedure TMVDEFPC.DoDownloadFile(const Url: string; str: TStream);
var
  FHttp: TFPHTTPClient;
begin
  inherited;
  FHttp := TFPHTTPClient.Create(nil);
  try
    FHttp.AllowRedirect := true;
    FHttp.AddHeader('User-Agent','Mozilla/5.0 (compatible; fpweb)');
    FHTTP.Get(Url, str);
    str.Position := 0;
  finally
    FHttp.Free;
  end;
end;

end.
