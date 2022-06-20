unit ColorsFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Colors, FMX.Objects, FMX.Layouts, FMX.ListBox,
  FMX.Edit, Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.FMXUI.Wait, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, System.Rtti, FMX.Grid.Style, Fmx.Bind.Grid,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, Data.Bind.Components, Data.Bind.Grid, FMX.ScrollBox,
  FMX.Grid, Data.Bind.DBScope, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, Data.Bind.Controls, Fmx.Bind.Navigator, FireDAC.Stan.StorageXML,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat;

type
  TFrameColors = class(TFrame)
    ComboColorBox1: TComboColorBox;
    eColorName: TEdit;
    ListBox1: TListBox;
    btnAdd: TButton;
    btnSelect: TButton;
    Layout2: TLayout;
    FDTableColors: TFDTable;
    procedure eColorNameChangeTracking(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure ComboColorBox1Change(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure btnSelectClick(Sender: TObject);
  private
    RefillList: Boolean;
    procedure OnItemApplyStyleLookup(Sender: TObject);
    function ColorExist(): Boolean;
    function ColorSelected: Boolean;
    procedure FillListBox(SFilter: String);
  public
    procedure SetParent(const Value: TFmxObject); override;
end;

implementation

{$R *.fmx}

uses
  AppBazar, DataModule, StrUtils;

procedure TFrameColors.SetParent(const Value: TFmxObject);
begin
  inherited;
  if Value = nil then begin
    FDTableColors.Close;
    UpdateMode:= False;
  end

  else begin
    Bazar.RECORDS.Visible:= False;
    Bazar.ButtonList.Visible:= False;
    Bazar.ButtonTable.Visible:= False;
    Bazar.ButtonDetail.Visible:= False;
    Bazar.ButtonHome.Visible:= False;
    Bazar.ButtonFilter.Visible:= False;
    Bazar.ButtonBack.Visible:= True;
    Bazar.SUBLABEL.Visible:= False;

    RefillList:= False;
    btnAdd.Visible:= False;
    btnSelect.Visible:= False;
    FDTableColors.Open;
    FillListBox('');
  end;
end;


procedure TFrameColors.btnAddClick(Sender: TObject);
begin
  inherited;
  FDTableColors.Insert;
  FDTableColors.FieldByName('ID').AsInteger:= DM.FindFirstFreeID('COLORS');
  FDTableColors.FieldByName('SKOD').AsString:= '$'+ IntToHex(ComboColorBox1.Color,8);
  FDTableColors.FieldByName('BARVA').AsString:= eColorName.Text;
  FDTableColors.Post;
  eColorName.Text:= '';
  FillListBox('');
end;


procedure TFrameColors.btnSelectClick(Sender: TObject);
begin
  if FDTableColors.Locate('BARVA', eColorName.Text) then begin
    IParam1:= FDTableColors.FieldByName('ID').AsInteger;
    if UpdateMode then begin
      var SavedVIN:= DM.FDQueryMain.FieldByName('VIN').AsString;
      DM.FDQueryMain.Edit;
      DM.FDQueryMain.FieldByName('BARVAID').AsInteger:= IParam1;
      DM.FDQueryMain.Post;
      DM.FDQueryMain.Refresh;
      DM.FDQueryMain.Locate('VIN', SavedVIN);
    end;
    Bazar.ActionBack(Sender);
   end;
end;

function TFrameColors.ColorExist: Boolean;
begin
  Result:= False;
  if FDTableColors.Locate('BARVA', eColorName.Text) then Result:= True
  else if FDTableColors.Locate('SKOD', '$'+IntToHex(ComboColorBox1.Color,8)) then Result:= True;
end;


function TFrameColors.ColorSelected: Boolean;
begin
  Result:= False;
  if FDTableColors.Locate('BARVA', eColorName.Text) and FDTableColors.Locate('SKOD', '$'+IntToHex(ComboColorBox1.Color,8)) then Result:= True;
end;


procedure TFrameColors.ComboColorBox1Change(Sender: TObject);
begin
  inherited;
  btnAdd.Visible:= not (eColorName.Text.IsEmpty or ColorExist);
  btnSelect.Visible:= ColorSelected;
end;


procedure TFrameColors.eColorNameChangeTracking(Sender: TObject);
begin
  inherited;
  btnAdd.Visible:= not (eColorName.Text.IsEmpty or ColorExist);
  btnSelect.Visible:= ColorSelected;
  if RefillList then FillListBox(eColorName.Text);
  RefillList:= True;
end;

procedure TFrameColors.FillListBox(SFilter: String);
var
  NewColor: TListBoxItem;
  K: Integer;
begin
  ListBox1.Clear;
  ListBox1.BeginUpdate;
  FDTableColors.First;
  for K := 0 to FDTableColors.RecordCount-1 do begin
    if (SFilter = '') or ContainsText(FDTableColors.FieldByName('BARVA').AsString,SFilter) then begin
      NewColor:= TListBoxItem.Create(nil);
      NewColor.Parent:= ListBox1;
      NewColor.Stored:= False;
      NewColor.Locked:= True;
      NewColor.Text:= FDTableColors.FieldByName('BARVA').AsString;
      NewColor.Tag:= FDTableColors.FieldByName('SKOD').AsInteger;
      NewColor.StyleLookup:= 'colorlistboxitemstyle';
      NewColor.OnApplyStyleLookup:= OnItemApplyStyleLookup;
    end;
    FDTableColors.Next;
  end;
  ListBox1.EndUpdate;
end;

procedure TFrameColors.ListBox1Click(Sender: TObject);
begin
  if ListBox1.Selected <> nil then begin
    ComboColorBox1.Color:= ListBox1.Selected.Tag;
    RefillList:= False;
    eColorName.Text:= ListBox1.Selected.Text;
  end;
end;

procedure TFrameColors.OnItemApplyStyleLookup(Sender: TObject);
var
  C: TShape;
begin
  if TListBox(Sender).FindStyleResource<TShape>('color', C) then C.Fill.Color := TListBoxItem(Sender).Tag;
end;

end.
