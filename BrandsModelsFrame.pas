unit BrandsModelsFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Rtti, FMX.Grid.Style, Fmx.Bind.Grid, System.Bindings.Outputs,
  Fmx.Bind.Editors, Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components,
  Data.Bind.Grid, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Grid,
  Data.Bind.DBScope, Data.Bind.Controls, FMX.Layouts, Fmx.Bind.Navigator,
  FMX.Edit, FireDAC.Comp.Client, Datasnap.DBClient, Datasnap.Provider, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.FMXUI.Wait, FireDAC.Comp.DataSet,
  FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat,
  DataModule;

type
  TFrameBrandsModels = class(TFrame)
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    DataSourceBrands: TDataSource;
    FDTableModels: TFDTable;
    BindSourceDB2: TBindSourceDB;
    GridBindSourceDB2: TGrid;
    LinkGridToDataSourceBindSourceDB2: TLinkGridToDataSource;
    BindNavigator2: TBindNavigator;
    ImageControlLOGO: TImageControl;
    Layout2: TLayout;
    ButtonAdd: TButton;
    EditZnacka: TEdit;
    LinkControlToField1: TLinkControlToField;
    FDTableBrands: TFDTable;
    FDTableBrandsID: TIntegerField;
    FDTableBrandsZNACKA: TWideMemoField;
    FDTableBrandsLOGO: TBlobField;
    GridBindSourceDB1: TGrid;
    LinkGridToDataSourceBindSourceDB12: TLinkGridToDataSource;
    ButtonChoose: TButton;
    EditModel: TEdit;
    Layout4: TLayout;
    Layout3: TLayout;
    LinkControlToField3: TLinkControlToField;
    Layout1: TLayout;
    procedure ButtonAddClick(Sender: TObject);
    procedure ButtonChooseClick(Sender: TObject);
    procedure FDTableModelsAfterInsert(DataSet: TDataSet);
    procedure FDTableBrandsBeforePost(DataSet: TDataSet);
    procedure GridBindSourceDB1CellClick(const Column: TColumn;
      const Row: Integer);
    procedure EditZnackaChangeTracking(Sender: TObject);
  private

  public
    procedure SetParent(const Value: TFmxObject); override;
  end;

implementation

{$R *.fmx}

uses
  AppBazar;


procedure TFrameBrandsModels.ButtonAddClick(Sender: TObject);
begin
  FDTableBrands.Insert;
  FDTableBrands.FieldByName('ID').AsInteger:= DM.FindFirstFreeID('BRANDS');
  FDTableBrands.FieldByName('ZNACKA').AsString:= EditZnacka.Text;
  FDTableBrands.Post;
end;

procedure TFrameBrandsModels.ButtonChooseClick(Sender: TObject);
begin
  IParam1:= FDTableModels.FieldByName('BRANDID').AsInteger;
  IParam2:= FDTableModels.FieldByName('ID').AsInteger;
  if UpdateMode then begin
    var SavedVIN:= DM.FDQueryMain.FieldByName('VIN').AsString;
//    var SavedRecNo:= DM.FDQueryMain.RecNo;
    DM.FDQueryMain.Edit;
    DM.FDQueryMain.FieldByName('ZNACKAID').AsInteger:= IParam1;
    DM.FDQueryMain.FieldByName('MODELID').AsInteger:= IParam2;
    DM.FDQueryMain.Post;
    DM.FDQueryMain.Refresh;
//    DM.FDQueryMain.RecNo:= SavedRecNo;
    DM.FDQueryMain.Locate('VIN',SavedVIN);
  end;
  Bazar.ActionBack(Sender);
end;

procedure TFrameBrandsModels.EditZnackaChangeTracking(Sender: TObject);
begin
  if (EditZnacka.Text <> '') then begin
    if FDTableBrands.Locate('ZNACKA', EditZnacka.Text) then begin
      FDTableBrands.Filtered:= False;
      ButtonAdd.Visible:= False;
      end
    else begin
       FDTableBrands.Filtered:= False;
       FDTableBrands.Filter:= 'ZNACKA LIKE ' + QuotedStr('%'+EditZnacka.Text+'%');
       ButtonAdd.Visible:= True;
       FDTableBrands.Filtered:= True;
    end;
  end
  else begin
    ButtonAdd.Visible:= False;
    FDTableBrands.Filtered:= False;
  end;
end;

procedure TFrameBrandsModels.FDTableBrandsBeforePost(DataSet: TDataSet);
begin
  if ImageControlLogo.Bitmap.Width>0 then begin
    var MS := TMemoryStream.Create;
    try
      ImageControlLOGO.Bitmap.SaveToStream(MS);
      MS.Position:= 0;
      TBlobField(DataSet.FieldByName('LOGO')).LoadFromStream(MS);
    finally
    end;
    MS.Free;
  end;
end;


procedure TFrameBrandsModels.FDTableModelsAfterInsert(DataSet: TDataSet);
begin
  FDTableModels.FieldByName('ID').AsInteger:= DM.FindFirstFreeID('MODELS');
end;

procedure TFrameBrandsModels.GridBindSourceDB1CellClick(const Column: TColumn;
  const Row: Integer);
begin
  EditZnacka.Text:= FDTableBrands.FieldByName('ZNACKA').AsString;
end;


procedure TFrameBrandsModels.SetParent(const Value: TFmxObject);
begin
  inherited;
  if Value = nil then begin
    FDTableModels.Close;
    FDTableBrands.Close;
    UpdateMode:= False;
  end

  else begin
    try
      FDTableBrands.Open;
      FDTableModels.Open;
      ButtonAdd.Visible:= False;
      BindSourceDB1.DataSet.First;
      EditZnacka.Text:= BindSourceDB1.DataSet.FieldByName('ZNACKA').AsString;
    except

    end;
    Bazar.RECORDS.Visible:= False;
    Bazar.ButtonList.Visible:= False;
    Bazar.ButtonTable.Visible:= False;
    Bazar.ButtonDetail.Visible:= False;
    Bazar.ButtonHome.Visible:= False;
    Bazar.ButtonFilter.Visible:= False;
    Bazar.ButtonBack.Visible:= True;
  end;
end;


end.


