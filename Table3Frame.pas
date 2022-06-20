unit Table3Frame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  DataModule, Data.Bind.EngExt, Fmx.Bind.DBEngExt, System.Rtti,
  System.Bindings.Outputs, Fmx.Bind.Editors, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, Data.Bind.Components,
  FMX.ListView, Data.Bind.Grid, Data.Bind.DBScope, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FMX.Grid.Style,
  Fmx.Bind.Grid, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Grid,
  FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys,
  FireDAC.FMXUI.Wait, System.Math.Vectors, FMX.Controls3D, FMX.Layers3D,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, Data.Bind.Controls, FMX.Layouts,
  Fmx.Bind.Navigator;

type
  TFrameTable3 = class(TFrame)
    ListView1: TListView;
    Splitter3D1: TSplitter3D;
    BindNavigator1: TBindNavigator;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkFillControlToField1: TLinkFillControlToField;
    procedure ListView1ItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
    procedure BindNavigator1Click(Sender: TObject; Button: TNavigateButton);
  private

  public
    procedure SetParent(const Value: TFmxObject); override;
  end;

implementation

{$R *.fmx}

uses
  AppBazar;


procedure TFrameTable3.BindNavigator1Click(Sender: TObject;
  Button: TNavigateButton);
begin

  case Button of
    nbFirst: begin
      ListView1.ItemIndex:= 0;
      ListView1.ScrollTo(ListView1.ItemIndex);
    end;

    nbPrior: begin
     if ListView1.ItemIndex > 0 then
        ListView1.ItemIndex:= ListView1.ItemIndex - 1;
    end;

    nbNext: begin
      if ListView1.ItemIndex < ListView1.ItemCount-1 then
         ListView1.ItemIndex:= ListView1.ItemIndex + 1;
    end;

    nbLast: begin
      ListView1.ItemIndex := ListView1.ItemCount-1;
    end;

    nbEdit: begin
      Bazar.ActionDetail2(Sender);
    end;

    nbDelete: begin
       DM.ListNeedReload:= True;
       SetParent(Parent);
    end;

    nbInsert: begin
      UpdateMode:= True;
      Bazar.ActionDetail2(Sender);
    end;

  end;
  Bazar.RECORDSSetText;

end;


procedure TFrameTable3.ListView1ItemClickEx(const Sender: TObject;
  ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
begin
  if ItemIndex<>-1 then begin
    DM.FDQueryMain.RecNo:= ItemIndex+1;
    Bazar.ActionDetail2(Sender);
  end;
end;



procedure TFrameTable3.SetParent(const Value: TFmxObject);
begin
  inherited;
  if Value = nil then begin
  end

  else begin
    Bazar.ButtonBack.Visible:= True;
    Bazar.ButtonHome.Visible:= True;

    Bazar.ButtonTable.Visible:= True;
    Bazar.ButtonList.Visible:= False;
    Bazar.ButtonDetail.Visible:= True;

    Bazar.ButtonFilter.Visible:= True;
    Bazar.RECORDS.Visible:= True;
    Bazar.SUBLABEL.Visible:= True;

    if DM.ListNeedReload then begin
      BindSourceDB1.DataSet:= nil;
      BindSourceDB1.DataSet:= DM.FDQueryMain;
      DM.ListNeedReload:= False;
    end;

    ListView1.ScrollTo(DM.FDQueryMain.RecNo-1);
    ListView1.ItemIndex:= DM.FDQueryMain.RecNo-1;

    Bazar.RECORDSSetText;
  end;
end;


end.
