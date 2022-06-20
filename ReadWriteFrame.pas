unit ReadWriteFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Phys,
  FireDAC.FMXUI.Wait, Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  FireDAC.Comp.BatchMove.DataSet, FireDAC.Comp.BatchMove,
  FireDAC.Comp.BatchMove.Text, System.Rtti, FMX.Grid.Style, Fmx.Bind.Grid,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, Data.Bind.Controls, FMX.Layouts, Fmx.Bind.Navigator,
  Data.Bind.Components, Data.Bind.Grid, FMX.ScrollBox, FMX.Grid,
  Data.Bind.DBScope, FMX.Controls.Presentation, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FMX.ListBox, FMX.Edit, FMX.EditBox, FMX.NumberBox, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, Data.Bind.GenData,
  Data.Bind.ObjectScope, FireDAC.Phys.SQLiteWrapper.Stat,
  DataModule;

type
  TFrameReadWrite = class(TFrame)
    ButtonRead: TButton;
    ButtonWrite: TButton;
    BindNavigator1: TBindNavigator;
    ListBox1: TListBox;
    ButtonAdresar: TButton;
    ButtonTablesCreate: TButton;
    ButtonTableDelete: TButton;
    ButtonGenCars: TButton;
    NumberBoxCars: TNumberBox;
    Layout2: TLayout;
    Layout4: TLayout;
    ButtonOK: TButton;
    DBFILENAME: TEdit;
    ButtonSelectFile: TButton;
    INFO: TLabel;
    CSVDIRECTORY: TEdit;
    Layout3: TLayout;
    Label1: TLabel;
    Layout1: TLayout;
    GridBindSourceDB1: TGrid;
    BindingsList1: TBindingsList;
    FDQuery: TFDQuery;
    Layout5: TLayout;
    Layout6: TLayout;
    Layout7: TLayout;
    BindSourceDB2: TBindSourceDB;
    LinkGridToDataSourceBindSourceDB2: TLinkGridToDataSource;
    procedure ButtonReadClick(Sender: TObject);
    procedure ButtonWriteClick(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure ButtonAdresarClick(Sender: TObject);
    procedure ButtonTablesCreateClick(Sender: TObject);
    procedure ButtonTableDeleteClick(Sender: TObject);
    procedure ButtonGenCarsClick(Sender: TObject);
    procedure NumberBoxCarsChange(Sender: TObject);
    procedure GridBindSourceDB1HeaderClick(Column: TColumn);
    procedure ButtonSelectFileClick(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
    procedure DBFILENAMEChange(Sender: TObject);
    procedure CSVDIRECTORYChange(Sender: TObject);
    procedure ButtonTestClick(Sender: TObject);
  private
    { Private declarations }
    NumCars: Integer;
    DefaultFontColor: Integer;
    procedure TableDelete(ATableName: String);
    procedure TableCreate(ATableName, AElements: String);
    procedure TableReCreate(ATableName, AElements: String);
    procedure TableRead(ATableName: String);
    function DBIsOK(): Boolean;
    function TableInDB(ATableName: String): Boolean;
    function TestAndSet: Integer;
    procedure FillTables;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure SetParent(const Value: TFmxObject); override;
  end;

implementation

{$R *.fmx}

uses
  System.DateUtils, FMX.DialogService, AppBazar;

procedure TFrameReadWrite.TableCreate(ATableName, AElements: String);
var
  Query: TFDQuery;
begin
  Query:= TFDQuery.Create(nil);
  Query.Connection:= DM.FDConnection;
  Query.SQL.Text:= 'CREATE TABLE ' + ATableName + ' ' + AElements;
  try
    Query.ExecSQL;
  except
    on E: Exception do begin
      {TODO: Some problem}
      end;
  end;
  Query.Free;

end;

procedure TFrameReadWrite.TableDelete(ATableName: String);
begin
  var Query:= TFDQuery.Create(nil);
  Query.Connection:= DM.FDConnection;
  Query.SQL.Text:= 'DROP TABLE IF EXISTS ' + ATableName;
  try
    Query.ExecSQL;
  except
    on E: Exception do begin
      {TODO: DATABASE NOT EXIST}
      end;
  end;
  Query.Free;
end;

procedure TFrameReadWrite.TableRead(ATableName: String);
var
  TextReader: TFDBatchMoveTextReader;
  DataSetWriter: TFDBatchMoveDataSetWriter;
  BatchMove: TFDBatchMove;
begin
  FDQuery.SQL.Text:= 'select * from ' + ATableName;
  FDQuery.Close; FDQuery.Open;

  TextReader:= nil;
  DataSetWriter:= nil;
  BatchMove:= nil;
  try
    DataSetWriter := TFDBatchMoveDataSetWriter.Create(nil);
    TextReader := TFDBatchMoveTextReader.Create(nil);
    BatchMove := TFDBatchMove.Create(nil);

    DataSetWriter.DataSet := FDQuery;
    DataSetWriter.Optimise:= False;

    TextReader.FileName := DM.CVSDirectory + '\' + ATableName+'.csv';
    TextReader.DataDef.WithFieldNames := True;
    TextReader.DataDef.Separator := ',';
    BatchMove.Options := [poClearDestNoUndo, poCreateDest];

    BatchMove.Reader := TextReader;
    BatchMove.Writer := DataSetWriter;
    BatchMove.Execute;

  finally
    DataSetWriter.Free;
    TextReader.Free;
    BatchMove.Free;
  end;
end;

procedure TFrameReadWrite.ButtonAdresarClick(Sender: TObject);
begin
{$IFDEF ANDROID}
  ShowMessage('Zapiš jméno adresáøe se soubory CSV');
  CSVDIRECTORY.SetFocus;
{$ENDIF}

{$IFDEF MSWINDOWS}
  SelectDirectory('Select document folder', System.SysUtils.GetHomePath, DM.CVSDirectory);
  CSVDIRECTORY.Text := DM.CVSDirectory;
{$ENDIF}
end;

procedure TFrameReadWrite.ButtonGenCarsClick(Sender: TObject);
var
  SPoznamka: String;
  QueryModels: TFDQuery;
  ModelID: Integer;
  ModelsCount: Integer;
  ColorsCount: Integer;
begin

  TableDelete('CARS');
  TableCreate('CARS', '(VIN text NOT NULL, RZ text, ZNACKAID int, MODELID int, BARVAID int, ROK int, MESIC int, NAJETO int, CENA integer, K_DISPOZICI int, POZNAMKA text)');
  FDQuery.SQL.Text:= 'insert into CARS (VIN, RZ, ZNACKAID, MODELID, BARVAID, ROK, MESIC, NAJETO, CENA, K_DISPOZICI, POZNAMKA) VALUES (:V, :R, :Z, :M, :B, :RO, :ME, :N, :C, :K, :P)';

  var QueryColors:= TFDQuery.Create(nil);
  QueryColors.Connection:= DM.FDConnection;
  QueryColors.SQL.Text:= 'select SKOD from COLORS';
  QueryColors.Open;
  ColorsCount:= QueryColors.RecordCount;
  QueryColors.Close;
  QueryColors.Free;

  QueryModels:= TFDQuery.Create(nil);
  QueryModels.Connection:= DM.FDConnection;
  QueryModels.SQL.Text:= 'select ID, BRANDID from MODELS';
  QueryModels.Open;
  ModelsCount:= QueryModels.RecordCount;


  for var I := 1 to NumCars do begin
    // VIN
    FDQuery.ParamByName('V').AsString := 'VIN00000000'+ I.ToString;
    // RZ
    FDQuery.ParamByName('R').AsString := random(9).ToString + Char(65+Random(25))+ random(9).ToString +
                ' ' + random(9).ToString + random(9).ToString + '-' + random(9).ToString + random(9).ToString;
    // MODELID
    ModelID:= 1+random(ModelsCount);
    FDQuery.ParamByName('M').AsInteger := ModelID;
    // ZNACKAID
    if QueryModels.Locate('ID', ModelID, []) then begin
      FDQuery.ParamByName('Z').AsInteger := QueryModels.FieldByName('BRANDID').AsInteger;
    end
    else begin
      ShowMessage('Models/brands database fail');
      FDQuery.ParamByName('Z').AsInteger := 1;
    end;
    // BARVAID
    FDQuery.ParamByName('B').AsInteger := 1+random(ColorsCount);

    FDQuery.ParamByName('RO').AsInteger := 1965 + random(57);
    FDQuery.ParamByName('ME').AsInteger := 1+random(12);
    FDQuery.ParamByName('N').AsInteger := random(500)*1000;
    FDQuery.ParamByName('C').AsInteger := random(2000)*1000;
    FDQuery.ParamByName('K').AsInteger := random(2);
    SPoznamka:= '';
    for var K := 0 to Random(100) do begin   // num words
      for var J := 0 to Random(10) do begin  // word lenght
         SPoznamka:= SPoznamka + Char(97 + Random(25));
      end;
      if Random(7) < 6 then SPoznamka:= SPoznamka + ' '
      else SPoznamka:= SPoznamka + Char(10);
    end;
    FDQuery.ParamByName('P').AsString := SPoznamka;

    FDQuery.ExecSQL;
  end;
  QueryModels.Close;
  QueryModels.Free;
end;

procedure TFrameReadWrite.ButtonOKClick(Sender: TObject);
begin
    DM.FDQueryMain.Close;
    DM.FDQueryMain.Open;
    if UpdateMode then begin
      Bazar.DatabaseFramesCreate;
      UpdateMode:= False;
    end;
    Bazar.HEADERLABEL.Text:= ExtractFileName(DM.FDConnection.Params.Database);
    Bazar.ActionHome(Sender);
end;

procedure TFrameReadWrite.ButtonReadClick(Sender: TObject);
begin
  TableRead(ListBox1.Items[ListBox1.ItemIndex]);
end;

procedure TFrameReadWrite.ButtonSelectFileClick(Sender: TObject);
var
  NewFileName: TFileName;
begin

{$IFDEF ANDROID}
  ShowMessage('Zapiš jméno databázového souboru vèetnì celé cesty');
{$ENDIF}

{$IFDEF MSWINDOWS}
  NewFileName:= '';
  var OpenDialog := TOpenDialog.Create(self);
  OpenDialog.InitialDir:= DM.CVSDirectory;
  OpenDialog.Title:= 'Vyber databázový soubor';
  openDialog.Filter := 'All files (*.*)|*.*';
  if openDialog.Execute then NewFileName:= openDialog.FileName;
  OpenDialog.Free;

  if NewFileName <> '' then begin
    if not FileExists(NewFileName) then begin
      TDialogService.MessageDialog('Soubor neexistuje. Vytvoøit?', TMsgDlgType.mtConfirmation, FMX.Dialogs.mbYesNo, TMsgDlgBtn.mbNo, 0,
        procedure(const AResult: System.UITypes.TModalResult)
        begin
          if AResult = mrYES then begin
            FileCreate(NewFileName);
          end;
        end
        );
    end;
    DM.FDConnection.Close;
    DM.FDConnection.Params.Database:= NewFileName;
    DM.FDConnection.Open;
    Bazar.HEADERLABEL.Text:= ExtractFileName(DM.FDConnection.Params.Database);
  end;
  TestAndSet;
{$ENDIF}

end;

procedure TFrameReadWrite.ButtonTableDeleteClick(Sender: TObject);
begin
  TableDelete(ListBox1.Items[ListBox1.ItemIndex]);
  ListBox1.Clear;
  DM.FDConnection.GetTableNames('', '', '', ListBox1.Items, [osMy],[tkTable]);
  ListBox1.ItemIndex:= 0;
  ListBox1Click(nil);
  TestAndSet;
end;

procedure TFrameReadWrite.ButtonTablesCreateClick(Sender: TObject);
begin
  TableReCreate('BRANDS', '(ID int NOT NULL, ZNACKA text NOT NULL, LOGO blob)');
  TableReCreate('COLORS','(ID int NOT NULL, SKOD text NOT NULL, BARVA text NOT NULL)');
  TableReCreate('MODELS','(ID int NOT NULL, BRANDID int NOT NULL, MODEL text NOT NULL, INFO text)');
  TableReCreate('PHOTOS','(VIN text NOT NULL, FOTKA blob)');
  TableReCreate('CARS', '(VIN text NOT NULL, RZ text, ZNACKAID int, MODELID int, BARVAID int, ROK int, MESIC int, NAJETO int, CENA int, K_DISPOZICI int, POZNAMKA text)');

  ListBox1.Clear;
  DM.FDConnection.GetTableNames('', '', '', ListBox1.Items, [osMy],[tkTable]);
  ListBox1.ItemIndex:= 0;
  ListBox1Click(nil);
  TestAndSet;
end;


procedure TFrameReadWrite.ButtonTestClick(Sender: TObject);
begin
  {$IFDEF ANDROID}
  TestAndSet;
  {$ENDIF}
end;

procedure TFrameReadWrite.ButtonWriteClick(Sender: TObject);
var
  TextWriter: TFDBatchMoveTextWriter;
  DataReader: TFDBatchMoveDataSetReader;
  BatchMove: TFDBatchMove;
begin

  DataReader := nil;
  TextWriter := nil;
  BatchMove := nil;

  try
    DataReader := TFDBatchMoveDataSetReader.Create(nil);
    TextWriter := TFDBatchMoveTextWriter.Create(nil);
    BatchMove := TFDBatchMove.Create(nil);

    DataReader.DataSet := FDQuery;
    DataReader.Rewind := true;

    TextWriter.FileName := DM.CVSDirectory + '\' + ListBox1.Items[ListBox1.ItemIndex]+'.csv';
    TextWriter.DataDef.WithFieldNames := true;
    TextWriter.DataDef.Separator := ',';
    BatchMove.Options := [poClearDestNoUndo, poCreateDest];

    BatchMove.Reader := DataReader;
    BatchMove.Writer := TextWriter;
    BatchMove.Execute;

  finally
    DataReader.DataSet:= nil;
    DataReader.Free;
    TextWriter.Free;
    BatchMove.Free;
  end;

end;

constructor TFrameReadWrite.Create(AOwner: TComponent);
begin
  inherited;
  DefaultFontColor:= INFO.TextSettings.FontColor;
  CSVDIRECTORY.Text:= DM.CVSDirectory;
  NumCars:= 1000;
  NumberBoxCars.Value:= NumCars;
end;

procedure TFrameReadWrite.CSVDIRECTORYChange(Sender: TObject);
begin
  {$IFDEF ANDROID}
  DM.CVSDirectory:= CSVDIRECTORY.Text;
  TestAndSet;
  {$ENDIF}
end;

procedure TFrameReadWrite.GridBindSourceDB1HeaderClick(Column: TColumn);
begin
  FDQuery.IndexFieldNames:= Column.Header;
  FDQuery.IndexesActive:= True;
end;


function TFrameReadWrite.TestAndSet: Integer;
begin
  DBFILENAME.Text:= DM.FDConnection.Params.Database;
  if FileExists(DM.FDConnection.Params.Database) then begin
    try
      DM.FDConnection.Close;
      DM.FDConnection.Open;
      if DBIsOK then begin
        DM.FDQueryMain.Open;
        INFO.Text:= 'Databazovy soubor je OK';
        FillTables;
        ButtonOK.SetFocus;
        INFO.TextSettings.FontColor:= DefaultFontColor;
        Layout2.Enabled:= True;
        BindNavigator1.Enabled:= True;
        GridBindSourceDB1.Enabled:= True;
        ButtonOK.Visible:= True;
        Result:= 0;
      end
      else begin
       INFO.Text:= 'Databazovy soubor je neúplný';
       ButtonTablesCreate.SetFocus;
       INFO.TextSettings.FontColor:= TAlphaColors.Yellowgreen;
       Layout2.Enabled:= True;
       BindNavigator1.Enabled:= True;
       GridBindSourceDB1.Enabled:= True;
       ButtonOK.Visible:= False;
       Bazar.ButtonBack.Visible:= False;
       FillTables;
       Result:= -1;
      end;
    except
       INFO.Text:= 'Databazovy soubor je špatný';
       ButtonTablesCreate.SetFocus;
       INFO.TextSettings.FontColor:= TAlphaColors.Yellowgreen;
       Layout2.Enabled:= True;
       BindNavigator1.Enabled:= True;
       GridBindSourceDB1.Enabled:= True;
       ButtonOK.Visible:= False;
       Bazar.ButtonBack.Visible:= False;
       FillTables;
       Result:= -2;
    end;
  end
  else begin
    INFO.Text:= 'Soubor neexistuje';
    INFO.TextSettings.FontColor:= TAlphaColors.Red;
    ButtonOK.Visible:= False;
    Bazar.ButtonBack.Visible:= False;
    Layout2.Enabled:= False;
    BindNavigator1.Enabled:= False;
    GridBindSourceDB1.Enabled:= False;
    ListBox1.Clear;
    ButtonSelectFile.SetFocus;
    Result:= -3;
  end;

end;



procedure TFrameReadWrite.ListBox1Click(Sender: TObject);
begin
  FDQuery.Close;
  FDQuery.SQL.Text:= 'select * from ' + ListBox1.Items[ListBox1.ItemIndex];
  FDQuery.IndexesActive:= False;
  FDQuery.Open;
end;

procedure TFrameReadWrite.NumberBoxCarsChange(Sender: TObject);
begin
  NumCars:= Trunc(NumberBoxCars.Value);
end;


procedure TFrameReadWrite.DBFILENAMEChange(Sender: TObject);
begin
  {$IFDEF ANDROID}
  DM.FDConnection.Params.Database:=DBFILENAME.Text;
  TestAndSet;
  {$ENDIF}
end;

function TFrameReadWrite.DBIsOK: Boolean;
begin
  Result:= False;
  if (TableInDB('CARS') and TableInDB('PHOTOS') and TableInDB('COLORS') and
      TableInDB('BRANDS') and TableInDB('MODELS')) then Result:= True;
end;


procedure TFrameReadWrite.FillTables;
begin
  try
    DM.FDConnection.GetTableNames('', '', '', ListBox1.Items, [osMy],[tkTable]);
    if ListBox1.Count>0 then begin
      ListBox1.ItemIndex:= 0;
      ListBox1Click(nil);
    end;
  except
    ShowMessage('FillTables wrong');
    {TODO: osetrit chybu}
  end;
end;

function TFrameReadWrite.TableInDB(ATableName: String): Boolean;
begin
  var List:= TStringList.Create;
  DM.FDConnection.GetTableNames('', '', ATableName, List);
  Result:= List.Count = 1;
  List.Free;
end;


procedure TFrameReadWrite.SetParent(const Value: TFmxObject);
begin
  inherited;
  if Value = nil then begin

  end

  else begin
    Bazar.ButtonBack.Visible:= False;
    Bazar.ButtonHome.Visible:= False;
    Bazar.RECORDS.Visible:= False;
    Bazar.ButtonTable.Visible:= False;
    Bazar.ButtonList.Visible:= False;
    Bazar.ButtonDetail.Visible:= False;
    Bazar.ButtonFilter.Visible:= False;
    Bazar.SUBLABEL.Visible:= False;

    DBFILENAME.Text:= DM.FDConnection.Params.Database;
    CSVDIRECTORY.Text:= DM.CVSDirectory;
    {$IFDEF ANDROID}
      DBFILENAME.Enabled:= True;
      CSVDIRECTORY.Enabled:= True;
    {$ENDIF}
    {$IFDEF MSWINDOWS}
      DBFILENAME.Enabled:= False;
      CSVDIRECTORY.Enabled:= False;
    {$ENDIF}

    TestAndSet;
  end;
end;

procedure TFrameReadWrite.TableReCreate(ATableName, AElements: String);
begin
  TableDelete(ATableName);
  TableCreate(ATableName, AElements);
  TableRead(ATableName);
end;


end.
