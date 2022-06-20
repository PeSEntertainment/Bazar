unit DataModule;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.FMXUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TDM = class(TDataModule)
    FDConnection: TFDConnection;
    FDQueryMain: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure FDQueryMainAfterDelete(DataSet: TDataSet);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    CVSDirectory: String;
    ListNeedReload: Boolean;
    function DBIsOK(): Boolean;
    function TableInDB(ATableName: String): Boolean;
    function FindFirstFreeID(ATableName: String): Integer;
  end;

var
  DM: TDM;
  UpdateMode: Boolean = False; // Post data / CreateFrames
  IParam1: Integer;   // ZNACKAID / BARVAID
  IParam2: Integer;   // MODELID

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

uses
  System.IOUtils;

{$R *.dfm}

procedure TDM.DataModuleDestroy(Sender: TObject);
begin
{TODO nekorektni chovani na androidu
  FDQueryMain.Close;
  FDConnection.Close;
}
end;

function TDM.DBIsOK: Boolean;
begin
  Result:= False;
  if (TableInDB('CARS') and TableInDB('PHOTOS') and TableInDB('COLORS') and
      TableInDB('BRANDS') and TableInDB('MODELS')) then Result:= True;
end;

function TDM.TableInDB(ATableName: String): Boolean;
begin
  var List:= TStringList.Create;
  DM.FDConnection.GetTableNames('', '', ATableName, List);
  Result:= List.Count = 1;
  List.Free;
end;


function TDM.FindFirstFreeID(ATableName: String): Integer;
var
  Query: TFDQuery;
  I: Integer;
begin
  Query:= TFDQuery.Create(nil);
  Query.Connection:= DM.FDConnection;
  Query.SQL.Text:= 'select ID from ' + ATableName + ' ORDER BY ID';
  Query.Open;
  Result:= 1;
  Query.First;
  for  I := 1 to Query.RecordCount do begin
    if Result <> Query.FieldByName('ID').AsInteger then exit
    else begin
      Inc(Result);
      Query.Next
    end;
  end;
  Query.Free;
end;

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  ListNeedReload:= False;
  CVSDirectory := TPath.GetDocumentsPath;

{TODO umisteni nacteni tady vede k nekorektnimu chovani na androidu
  FDConnection.Params.Database:= TPath.Combine(TPath.GetDocumentsPath,'bazar3.db');
  FDConnection.FetchOptions.AutoFetchAll:= afAll;
  FDConnection.Open;
  FDQueryMain.Open;
}
end;

procedure TDM.FDQueryMainAfterDelete(DataSet: TDataSet);
begin
  FDQueryMain.Refresh; // because of RecordCount refresh
end;

end.
