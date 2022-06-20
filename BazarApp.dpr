program BazarApp;

uses
  System.StartUpCopy,
  FMX.Forms,
  AppBazar in 'AppBazar.pas' {Bazar},
  MainFrame in 'MainFrame.pas' {FrameMain: TFrame},
  Table3Frame in 'Table3Frame.pas' {FrameTable3: TFrame},
  BrandsModelsFrame in 'BrandsModelsFrame.pas' {FrameBrandsModels: TFrame},
  Table2Frame in 'Table2Frame.pas' {FrameTable2: TFrame},
  ColorsFrame in 'ColorsFrame.pas' {FrameColors: TFrame},
  Detail2Frame in 'Detail2Frame.pas' {FrameDetail2: TFrame},
  ReadWriteFrame in 'ReadWriteFrame.pas' {FrameReadWrite: TFrame},
  DataModule in 'DataModule.pas' {DM: TDataModule},
  FilterFrame in 'FilterFrame.pas' {FrameFilter: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TBazar, Bazar);
  Application.Run;
end.
