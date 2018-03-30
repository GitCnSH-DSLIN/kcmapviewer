{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit kcMapViewerPckg;

{$warn 5023 off : no warning about unused units}
interface

uses
  kcMapViewerInstall, kcMapViewerGLGeoNames, kcThreadPool, kcMapViewerDEFpc, 
  kcMapViewer, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('kcMapViewerInstall', @kcMapViewerInstall.Register);
end;

initialization
  RegisterPackage('kcMapViewerPckg', @Register);
end.
