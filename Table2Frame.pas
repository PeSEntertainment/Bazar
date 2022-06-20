unit Table2Frame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Rtti, FMX.Grid.Style, Fmx.Bind.Grid, System.Bindings.Outputs,
  Fmx.Bind.Editors, Data.Bind.EngExt, Fmx.Bind.DBEngExt, FMX.DateTimeCtrls,
  FMX.EditBox, FMX.NumberBox, Data.Bind.Components, FMX.Edit, Data.Bind.Grid,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Grid, Data.Bind.DBScope,
  FMX.Layouts, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FMX.Menus, FMX.Memo, Data.Bind.Controls,
  Fmx.Bind.Navigator, FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Phys, FireDAC.FMXUI.Wait, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat,
  DataModule;


type
  TFrameTable2 = class(TFrame)
    PopupMenu1: TPopupMenu;
    MenuItemSome: TMenuItem;
    BindNavigator1: TBindNavigator;
    StringGridBindSourceDB1: TStringGrid;
    Layout1: TLayout;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    procedure StringGridBindSourceDB1HeaderClick(Column: TColumn);
    procedure BindNavigator1Click(Sender: TObject; Button: TNavigateButton);
    procedure StringGridBindSourceDB1CellClick(const Column: TColumn;
      const Row: Integer);
  private
    procedure StringGridDB1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetParent(const Value: TFmxObject); override;
  end;

implementation

{$R *.fmx}
uses
  AppBazar;

procedure TFrameTable2.BindNavigator1Click(Sender: TObject;
  Button: TNavigateButton);
begin
  Bazar.RECORDSSetText;
  case Button of
    nbEdit: begin
      Bazar.ActionDetail2(Sender);
    end;

    nbDelete: begin
       DM.ListNeedReload:= True;
    end;

    nbInsert: begin
      UpdateMode:= True;
      Bazar.ActionDetail2(Sender);
    end;
  end;
end;

constructor TFrameTable2.Create(AOwner: TComponent);
begin
  inherited;
  StringGridBindSourceDB1.OnMouseDown:= StringGridDB1MouseDown; // add because not published by default
end;


procedure TFrameTable2.SetParent(const Value: TFmxObject);
begin
  inherited;
  if Value = nil then begin
  end

  else begin
    Bazar.ButtonBack.Visible:= True;
    Bazar.ButtonHome.Visible:= True;
    Bazar.ButtonFilter.Visible:= True;

    Bazar.ButtonTable.Visible:= False;
    Bazar.ButtonList.Visible:= True;
    Bazar.ButtonDetail.Visible:= True;

    Bazar.RECORDS.Visible:= True;
    Bazar.RECORDSSetText;
  end;
end;

procedure TFrameTable2.StringGridDB1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Col, Row: Integer;
begin
  if Button = TMouseButton.mbRight then begin  //assign Cell values and call popup menu
    StringGridBindSourceDB1.CellByPoint(X,Y,Col,Row);
    if (Col>-1) and (Row>-1) then begin
      PopupMenu1.Popup(Screen.MousePos.X,Screen.MousePos.Y);
    end;
  end;
end;

procedure TFrameTable2.StringGridBindSourceDB1CellClick(const Column: TColumn;
  const Row: Integer);
begin
  inherited;
  Bazar.RECORDSSetText;
  if Column.Header = 'BARVA' then begin
    UpdateMode:= True;
    Bazar.ActionColors(nil);
  end
  else if (Column.Header = 'MODEL') or (Column.Header = 'ZNACKA') then begin
    UpdateMode:= True;
    Bazar.ActionBrandsModels(nil);
  end;
end;


procedure TFrameTable2.StringGridBindSourceDB1HeaderClick(Column: TColumn);
begin
  DM.ListNeedReload:= True;
  DM.FDQueryMain.IndexesActive:= True;

  if DM.FDQueryMain.IndexFieldNames.Equals(Column.Header) then begin
    DM.FDQueryMain.IndexFieldNames:= Column.Header+':D';
  end

  else begin
    DM.FDQueryMain.IndexFieldNames:= Column.Header;
  end;

end;


end.
