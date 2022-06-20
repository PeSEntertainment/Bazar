unit AppBazar;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Controls.Presentation, System.Actions, FMX.ActnList,
  MainFrame, Table2Frame, Table3Frame, FilterFrame,
  BrandsModelsFrame, ColorsFrame, Detail2Frame, ReadWriteFrame,
  FMX.Menus,
  DataModule, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Phys,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.Stan.Async,
  FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Stan.Pool,
  FireDAC.FMXUI.Wait, FireDAC.Comp.BatchMove.DataSet, FireDAC.Comp.BatchMove,
  FireDAC.Comp.BatchMove.Text, System.ImageList, FMX.ImgList,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, System.Rtti, FMX.Grid.Style, Fmx.Bind.Grid,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, Data.Bind.Components, Data.Bind.Grid, FMX.ScrollBox,
  FMX.Grid, Data.Bind.DBScope;

type
  TBazar = class(TForm)
    Header: TToolBar;
    HEADERLABEL: TLabel;
    Panel: TPanel;
    ButtonHome: TSpeedButton;
    ButtonBack: TSpeedButton;
    StyleBook1: TStyleBook;
    RECORDS: TLabel;
    SUBLABEL: TLabel;
    Layout1: TLayout;
    ButtonDetail: TButton;
    ButtonList: TButton;
    ButtonTable: TButton;
    ButtonFilter: TButton;
    Layout2: TLayout;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ActionHome(Sender: TObject);
    procedure ActionTabulka2(Sender: TObject);
    procedure ActionTabulka3(Sender: TObject);
    procedure ActionBrandsModels(Sender: TObject);
    procedure ActionBack(Sender: TObject);
    procedure ActionFilter(Sender: TObject);
    procedure ActionColors(Sender: TObject);
    procedure ActionDetail2(Sender: TObject);
    procedure ActionSetup(Sender: TObject);
    procedure ButtonExitClick(Sender: TObject);
    procedure RECORDSClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FrameFilter: TFrameFilter;
    FrameMain: TFrameMain;
    FrameTable2: TFrameTable2;
    FrameTable3: TFrameTable3;
    FrameBrandsModels: TFrameBrandsModels;
    FrameColors: TFrameColors;
    FrameDetail2: TFrameDetail2;
    FrameReadWrite: TFrameReadWrite;
    FramesList: TList;
    procedure FrameAdd(AFrame: TFrame);
  public
    function OpenDatabase: Integer;
    procedure RECORDSSetText;
    procedure DatabaseFramesCreate;
  end;

var
  Bazar: TBazar;


implementation

{$R *.fmx}
{$R *.NmXhdpiPh.fmx ANDROID}
{$R *.SmXhdpiPh.fmx ANDROID}
{$R *.LgXhdpiPh.fmx ANDROID}
{$R *.LgXhdpiTb.fmx ANDROID}
{$R *.Windows.fmx MSWINDOWS}

uses
  System.IOUtils, FMX.DialogService;


procedure TBazar.FrameAdd(AFrame: TFrame);
begin
  if FramesList.Count>0 then TFrame(FramesList.Last).Parent:= nil;
  FramesList.Add(AFrame);
  TFrame(FramesList.Last).Parent:= Panel;
end;


function TBazar.OpenDatabase:Integer;
begin
  Result:= 0;
  var CurrentCursor:= Bazar.Cursor;
  Bazar.Cursor:= crHourGlass;  {TODO: Change cursor on Android}

  DM.FDConnection.Params.Database:= TPath.Combine(TPath.GetDocumentsPath,'bazar3.db');
  DM.FDConnection.FetchOptions.AutoFetchAll:= afAll;
  try
    DM.FDConnection.Open;
    if DM.DBIsOK then begin {TODO: control TAB existence NOT structure}
      DM.FDQueryMain.Open;
      HEADERLABEL.Text:= ExtractFileName(DM.FDConnection.Params.Database);
    end
    else Result:= -1;
  except
    Result:= -1;
  end;
  Bazar.Cursor:= CurrentCursor;
end;

procedure TBazar.RECORDSClick(Sender: TObject);
begin
  ActionFilter(Sender);
end;

procedure TBazar.RECORDSSetText;
begin
  RECORDS.Text:= DM.FDQueryMain.RecNo.ToString + '/' + DM.FDQueryMain.RecordCount.ToString;
end;

procedure TBazar.ActionBack(Sender: TObject);
begin
  if FramesList.Count > 0 then begin
    TFrame(FramesList.Last).Parent:= nil;
    FramesList.Delete(FramesList.Count-1);
    if FramesList.Count > 1 then begin
     TFrame(FramesList.Last).Parent:= Panel;
    end
    else // uz tam nic neni tak pridej domovskou stranku
      ActionHome(Sender);
  end
  else ActionHome(Sender);
end;

procedure TBazar.ActionBrandsModels(Sender: TObject);
begin
  FrameAdd(FrameBrandsModels);
end;

procedure TBazar.ActionColors(Sender: TObject);
begin
  FrameAdd(FrameColors);
end;

procedure TBazar.ActionDetail2(Sender: TObject);
begin
  FrameAdd(FrameDetail2);
end;

procedure TBazar.ActionFilter(Sender: TObject);
begin
  FrameAdd(FrameFilter);
end;

procedure TBazar.ActionSetup(Sender: TObject);
begin
  FrameAdd(FrameReadWrite);
end;

procedure TBazar.ActionTabulka2(Sender: TObject);
begin
  FrameAdd(FrameTable2);
end;

procedure TBazar.ActionTabulka3(Sender: TObject);
begin
  FrameAdd(FrameTable3);
end;

procedure TBazar.ActionHome(Sender: TObject);
begin
  if FramesList.Count > 0 then begin // stisknuto tlacitko Home ne Back musi se vypnout posledni frame
    TFrame(FramesList.Last).Parent:= nil;
    FramesList.Clear;
  end;
  FramesList.Add(FrameMain);
  FrameMain.Parent:= Panel;
end;

procedure TBazar.ButtonExitClick(Sender: TObject);
begin
  Application.Terminate;
end;


procedure TBazar.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  CClose: Boolean;
begin
  CClose:= True;
  TDialogService.MessageDialog('Opravdu ukonèit?', TMsgDlgType.mtConfirmation, FMX.Dialogs.mbYesNo, TMsgDlgBtn.mbNo, 0,
    procedure(const AResult: System.UITypes.TModalResult)
    begin
      if AResult = mrNo then CClose:= False;
    end
  );
  CanClose:= CClose;
end;

procedure TBazar.DatabaseFramesCreate;
begin
  FrameTable2:= TFrameTable2.Create(Self);
  FrameTable3:= TFrameTable3.Create(Self);
  FrameDetail2:= TFrameDetail2.Create(Self);
  FrameBrandsModels:= TFrameBrandsModels.Create(Self);
  FrameColors:= TFrameColors.Create(Self);
  FrameFilter:= TFrameFilter.Create(Self);
end;

procedure TBazar.FormCreate(Sender: TObject);
begin
  ButtonDetail.OnClick:= ActionDetail2;
  ButtonFilter.OnClick:= ActionFilter;
  ButtonHome.OnClick:= ActionHome;
  ButtonList.OnClick:= ActionTabulka3;
  ButtonTable.OnClick:= ActionTabulka2;
  ButtonBack.OnClick:= ActionBack;

  FrameMain:= TFrameMain.Create(Self);
  FrameReadWrite:= TFrameReadWrite.Create(Self);
  FramesList:= TList.Create;

  if OpenDatabase = 0 then begin
      DatabaseFramesCreate;
      ActionHome(Sender);
      RECORDSSetText;
    end
    else begin
      UpdateMode:= True;
      ActionSetup(Sender);
    end;
end;

procedure TBazar.FormDestroy(Sender: TObject);
begin
  FrameFilter.Free;
  FramesList.Free;
  FrameReadWrite.Free;
  FrameDetail2.Free;
  FrameColors.Free;
  FrameBrandsModels.Free;
  FrameTable3.Free;
  FrameTable2.Free;
  FrameMain.Free;
end;

end.
