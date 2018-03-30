unit kcMapViewerInstall;

{$I kcMapViewer.inc}

{ If you want to use the Synapse download engine activate the define
  ENABLE_SYNAPSE in the include file and add the package laz_synapse
  to the package requirements }

interface

procedure Register;

implementation

{$R kcmapviewerreg.res}

uses
  Classes, LResources, kcMapViewer, kcMapViewerGLGeoNames, kcMapViewerDEFpc
  {$IFDEF ENABLE_SYNAPSE}, kcMapViewerDESynapse{$ENDIF ENABLE_SYNAPSE}
  {$IFDEF WINDOWS}, kcMapViewerDEWin32{$ENDIF WINDOWS}
  ;

procedure Register;
begin
  RegisterComponents('Misc',[TMapViewer, TMVGLGeoNames, TMVDEFPC
  {$IFDEF ENABLE_SYNAPSE}, TMVDESynapse{$ENDIF ENABLE_SYNAPSE}
  {$IFDEF WINDOWS}, TMVDEWin32{$ENDIF WINDOWS}]);
end;

end.
