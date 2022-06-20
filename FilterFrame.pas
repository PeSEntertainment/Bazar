unit FilterFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.ListBox, FMX.Controls.Presentation, FMX.ExtCtrls,
  DataModule, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FMX.Objects, FMX.EditBox, FMX.NumberBox, FMX.Edit;

type
  TFrameFilter = class(TFrame)
    Layout3: TLayout;
    CircleColor: TCircle;
    BARVA: TLabel;
    ZNACKA: TLabel;
    MODEL: TLabel;
    K_DISPOZICI: TCheckBox;
    RZ: TEdit;
    NAJETOOD: TNumberBox;
    CENAOD: TNumberBox;
    CheckBoxRZ: TCheckBox;
    CheckBoxCENA: TCheckBox;
    CheckBoxNAJETO: TCheckBox;
    CheckBoxROK: TCheckBox;
    CheckBoxK_DISPOZICI: TCheckBox;
    CheckBoxZNACKA: TCheckBox;
    CheckBoxMODEL: TCheckBox;
    CheckBoxBARVA: TCheckBox;
    FDQuery: TFDQuery;
    ButtonOn: TButton;
    ButtonClear: TButton;
    ButtonOff: TButton;
    ROKDO: TNumberBox;
    ROKOD: TNumberBox;
    CENADO: TNumberBox;
    NAJETODO: TNumberBox;
    Layout1: TLayout;
    LabelROK: TLabel;
    LabelCENA: TLabel;
    LabelNAJETO_KM: TLabel;
    LabelRZ: TLabel;
    NumRec: TLabel;
    procedure ZNACKAClick(Sender: TObject);
    procedure CircleColorClick(Sender: TObject);
    procedure BARVAClick(Sender: TObject);
    procedure ButtonClearClick(Sender: TObject);
    procedure ButtonOffClick(Sender: TObject);
    procedure ButtonOnClick(Sender: TObject);
    procedure CheckBoxesChange(Sender: TObject);
  private
    Filter: String;
    ZNACKAID: Integer;
    MODELID: Integer;
    BARVAID: Integer;
    SelectDemand: Integer;  // 0 zadny pozadavek, 1 BRANDSANDMODELS, 2 COLORS
    procedure AddToFilter(AChecked: Boolean; AString: String);
    procedure SetFilterOn;
    procedure SetFilterOff;
    procedure SetFilterString;
  public
     constructor Create(AOwner: TComponent); override;
     procedure SetParent(const Value: TFmxObject); override;
  end;

implementation

{$R *.fmx}

uses
  AppBazar;

{ TFrameFilter }

procedure TFrameFilter.AddToFilter(AChecked: Boolean; AString: String);
begin
  if AChecked then begin
    if Filter <> '' then Filter:= Filter + ' and ';
    Filter:= Filter + AString;
  end;

end;

procedure TFrameFilter.BARVAClick(Sender: TObject);
begin
  SelectDemand:= 2;
  IParam1:= -1;
  Bazar.ActionColors(Sender);
end;

procedure TFrameFilter.ButtonClearClick(Sender: TObject);
begin
  Filter:= '';
  CheckBoxZNACKA.IsChecked:= False; ZNACKA.Text:= 'vyber znacku'; ZNACKAID:= -1;
  CheckBoxMODEL.IsChecked:= False; MODEL.Text:= ' a model'; MODELID:= -1;
  CheckBoxBARVA.IsChecked:= False; BARVA.Text:= 'vyber barvu'; BARVAID:= -1;
  CheckBoxK_DISPOZICI.IsChecked:= False; K_DISPOZICI.IsChecked:= False;
  CheckBoxCENA.IsChecked:= False; CENAOD.Value:= 0; CENADO.Value:= 0;
  CheckBoxROK.IsChecked:= False; ROKOD.Value:= 0; ROKDO.Value:= CurrentYear;
  CheckBoxNAJETO.IsChecked:= False; NAJETOOD.Value:= 0; NAJETODO.Value:= 0;
  CheckBoxRZ.IsChecked:= False; RZ.Text:= '';
end;

procedure TFrameFilter.ButtonOffClick(Sender: TObject);
begin
  SetFilterOff;
  DM.ListNeedReload:= True;
  Bazar.ActionBack(Sender);
end;

procedure TFrameFilter.SetFilterString;
begin
  Filter:= '';
  if ZNACKAID <> -1 then AddToFilter(CheckBoxZNACKA.IsChecked, 'ZNACKAID LIKE ' + ZNACKAID.ToString);
  if MODELID <> -1  then AddToFilter(CheckBoxMODEL.IsChecked, 'MODELID LIKE ' + MODELID.ToString);
  if BARVAID <> -1  then AddToFilter(CheckBoxBARVA.IsChecked, 'BARVAID LIKE ' + BARVAID.ToString);
  if K_DISPOZICI.IsChecked then AddToFilter(CheckBoxK_DISPOZICI.IsChecked, 'K_DISPOZICI LIKE 1')
    else AddToFilter(CheckBoxK_DISPOZICI.IsChecked, 'K_DISPOZICI LIKE 0');
  AddToFilter(CheckBoxCENA.IsChecked, 'CENA BETWEEN ' + CENAOD.Value.ToString + ' AND ' + CENADO.Value.ToString);
  AddToFilter(CheckBoxROK.IsChecked, 'ROK BETWEEN ' + ROKOD.Value.ToString + ' AND ' + ROKDO.Value.ToString);
  AddToFilter(CheckBoxNAJETO.IsChecked, 'NAJETO BETWEEN ' + NAJETOOD.Value.ToString + ' AND ' + NAJETODO.Value.ToString);
  AddToFilter(CheckBoxRZ.IsChecked, 'RZ LIKE ' + QuotedStr('%' + RZ.Text + '%'));
end;

procedure TFrameFilter.ButtonOnClick(Sender: TObject);
begin
  SetFilterString;
  if Filter <> '' then begin
    DM.FDQueryMain.Filter:= Filter;
    SetFilterOn;
  end
  else begin
    SetFilterOff;
  end;
  DM.ListNeedReload:= True;
  Bazar.ActionBack(Sender);
end;

procedure TFrameFilter.CheckBoxesChange(Sender: TObject);
begin
  SetFilterString;
  DM.FDQueryMain.Filter:= Filter;
  DM.FDQueryMain.Filtered:= True;
  DM.FDQueryMain.FetchOptions.RecordCountMode:= cmVisible;
  NumRec.Text:= DM.FDQueryMain.RecordCount.ToString;
end;

procedure TFrameFilter.CircleColorClick(Sender: TObject);
begin
  SelectDemand:= 2;
  IParam1:= -1;
  Bazar.ActionColors(Sender);
end;

constructor TFrameFilter.Create(AOwner: TComponent);
begin
  inherited;
  ButtonClearClick(nil);
end;

procedure TFrameFilter.SetFilterOff;
begin
  DM.FDQueryMain.Filtered:= False;
  Bazar.SUBLABEL.Text:= 'filtr není aktivní';
  DM.FDQueryMain.FetchOptions.RecordCountMode:= cmTotal;
  Bazar.ButtonFilter.FontColor:= TAlphaColors.Gray;
  Bazar.ButtonFilter.IconTintColor:= TAlphaColors.Gray;
end;

procedure TFrameFilter.SetFilterOn;
begin
  DM.FDQueryMain.Filtered:= False;
  DM.FDQueryMain.Filtered:= True;
  Bazar.SUBLABEL.Text:= 'filtr aktivní';
  Bazar.ButtonFilter.FontColor:= TAlphaColors.Red;
  Bazar.ButtonFilter.IconTintColor:= TAlphaColors.Red;
  DM.FDQueryMain.FetchOptions.RecordCountMode:= cmVisible;
end;

procedure TFrameFilter.SetParent(const Value: TFmxObject);
begin
  inherited;
  if Value = nil then begin

  end

  else begin
    Bazar.ButtonList.Visible:= False;
    Bazar.ButtonTable.Visible:= False;
    Bazar.ButtonDetail.Visible:= False;
    Bazar.ButtonHome.Visible:= False;
    Bazar.ButtonFilter.Visible:= False;
    NumRec.Text:= DM.FDQueryMain.RecordCount.ToString;
    Bazar.SUBLABEL.Visible:= True;

    if SelectDemand > 0 then  begin //vraci se z nejakeho s vyberem hodnot
      if IParam1 > -1 then begin // vratilo se s nejakou volbou
        if SelectDemand = 1 then begin  // BRANDSANDMODELS
           ZNACKAID:= IParam1; MODELID:= IParam2;
           FDQuery.SQL.Text:= 'select ZNACKA from BRANDS where ID LIKE :ID';
           FDQuery.ParamByName('ID').AsInteger:= IParam1;
           FDQuery.Open;
           ZNACKA.Text:= FDQuery.FieldByName('ZNACKA').AsString;
           FDQuery.Close;
           FDQuery.SQL.Text:= 'select MODEL from MODELS where ID LIKE :ID';
           FDQuery.ParamByName('ID').AsInteger:= IParam2;
           FDQuery.Open;
           MODEL.Text:= FDQuery.FieldByName('MODEL').AsString;
           FDQuery.Close;
        end
        else begin // COLORS
           BARVAID:= IParam1;
           FDQuery.SQL.Text:= 'select BARVA, SKOD from COLORS where ID LIKE :ID';
           FDQuery.ParamByName('ID').AsInteger:= IParam1;
           FDQuery.Open;
           BARVA.Text:= FDQuery.FieldByName('BARVA').AsString;
           CircleColor.Fill.Color:= FDQuery.FieldByName('SKOD').AsInteger;
           FDQuery.Close;
        end;
      end;
      SelectDemand:= 0;
    end;
  end;
end;

procedure TFrameFilter.ZNACKAClick(Sender: TObject);
begin
  SelectDemand:= 1;
  IParam1:= -1;
  Bazar.ActionBrandsModels(Sender);
end;

end.
