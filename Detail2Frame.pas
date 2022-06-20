unit Detail2Frame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.FMXUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  System.Rtti, System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, Data.Bind.Components, FMX.ListBox,
  FMX.Controls.Presentation, FMX.Edit, Data.Bind.DBScope, FireDAC.Comp.Client,
  Data.DB, FireDAC.Comp.DataSet, FMX.Colors, FMX.Objects,
  Data.Bind.Controls, FMX.Layouts, Fmx.Bind.Navigator, FMX.DateTimeCtrls,
  FMX.ScrollBox, FMX.Memo, FMX.EditBox, FMX.NumberBox, FMX.Memo.Types,
  Data.Bind.GenData, Data.Bind.ObjectScope, FMX.Effects, FMX.Filter.Effects,
  FMX.Menus, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat,
  DataModule;

type
  TFrameDetail2 = class(TFrame)
    CircleColor: TCircle;
    LOGO: TImageControl;
    BindNavigator1: TBindNavigator;
    FOTKA: TImageControl;
    LabelRZ: TLabel;
    CENA: TNumberBox;
    LabelCENA: TLabel;
    POZNAMKA: TMemo;
    K_DISPOZICI: TCheckBox;
    Layout1: TLayout;
    Layout2: TLayout;
    LayoutVIN: TLayout;
    Splitter1: TSplitter;
    Layout9: TLayout;
    LayoutData: TLayout;
    VIN: TEdit;
    Layout3: TLayout;
    LabelNAJETO_KM: TLabel;
    NAJETO: TNumberBox;
    LayoutNavigator: TLayout;
    ZNACKA: TLabel;
    MODEL: TLabel;
    BARVA: TLabel;
    PopupMenu1: TPopupMenu;
    MenuItemDelete: TMenuItem;
    ButtonVIN: TButton;
    RZ: TEdit;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkControlToField1: TLinkControlToField;
    LinkControlToField2: TLinkControlToField;
    ROK: TNumberBox;
    LabelROK: TLabel;
    LinkControlToFieldROK: TLinkControlToField;
    MESIC: TNumberBox;
    LabelMESIC: TLabel;
    LinkControlToFieldMESIC: TLinkControlToField;
    LinkControlToField3: TLinkControlToField;
    LinkControlToField4: TLinkControlToField;
    LinkControlToField5: TLinkControlToField;
    LinkControlToField6: TLinkControlToField;
    LinkPropertyToFieldText: TLinkPropertyToField;
    LinkPropertyToFieldText2: TLinkPropertyToField;
    LinkPropertyToFieldText3: TLinkPropertyToField;
    LinkPropertyToFieldFillColor: TLinkPropertyToField;
    LinkControlToField7: TLinkControlToField;
    ScrollBox1: TScrollBox;
    procedure BindNavigator1Click(Sender: TObject; Button: TNavigateButton);
    procedure VINChangeTracking(Sender: TObject);
    procedure ButtonVINClick(Sender: TObject);
    procedure LOGOClick(Sender: TObject);
    procedure CircleColorClick(Sender: TObject);
    procedure FOTKALoaded(Sender: TObject; const FileName: string);
    procedure MenuItemDeleteClick(Sender: TObject);
  private
    procedure FillFOTKA;
    procedure EmptyControls;
  public
    procedure SetParent(const Value: TFmxObject); override;
  end;

implementation

{$R *.fmx}

uses
  AppBazar, System.DateUtils;

procedure TFrameDetail2.BindNavigator1Click(Sender: TObject;
  Button: TNavigateButton);
begin
  Bazar.RECORDSSetText;
  case Button of
    nbPrior,
    nbNext,
    nbFirst,
    nbLast,
    nbDelete: begin
      DM.ListNeedReload:= True;
      FillFOTKA;
    end;
    nbInsert: begin
      EmptyControls;
      DM.ListNeedReload:= True;
      LayoutNavigator.Enabled:= False;
      LayoutVIN.Enabled:= True;
      LayoutData.Enabled:= False;
      VIN.SetFocus;
    end;
  end;
end;

procedure TFrameDetail2.ButtonVINClick(Sender: TObject);
begin
  DM.FDQueryMain.Post; // Post due VIN is unique key for table PHOTOS
  DM.FDQueryMain.Locate('VIN',VIN.Text);
  ButtonVIN.Visible:= False;
  LayoutVIN.Enabled:= False;
  LayoutData.Enabled:= True;
  LayoutNavigator.Enabled:= True;

  Bazar.ButtonBack.Visible:= True;
  Bazar.ButtonHome.Visible:= True;
  Bazar.ButtonFilter.Visible:= True;

  Bazar.ButtonTable.Visible:= True;
  Bazar.ButtonList.Visible:= True;
  Bazar.ButtonDetail.Visible:= False;
end;


procedure TFrameDetail2.CircleColorClick(Sender: TObject);
begin
 UpdateMode:= True;
 Bazar.ActionColors(Sender);
end;

procedure TFrameDetail2.VINChangeTracking(Sender: TObject);
begin
  if LayoutVIN.Enabled then begin
    ButtonVIN.Visible:= False;
    VIN.TextSettings.FontColor:= TAlphaColors.Black;
    if VIN.Text.Length<>17 then begin
      VIN.TextSettings.FontColor:= TAlphaColors.Orange;
    end;
    var FDQueryVIN:= TFDQuery.Create(nil);
    FDQueryVIN.Connection:= DM.FDConnection;
    FDQueryVIN.SQL.Text:= 'select VIN from CARS where VIN LIKE ' + QuotedStr(VIN.Text);
    FDQueryVIN.Open;
    ButtonVIN.Visible:= (FDQueryVIN.RecordCount = 0) and (not VIN.Text.Equals(''));
    FDQueryVIN.Free;
  end;
end;


procedure TFrameDetail2.FillFOTKA;
begin
  var Stream:= DM.FDQueryMain.CreateBlobStream(DM.FDQueryMain.FieldByName('FOTKA'), bmRead);
  if Stream.Size > 0 then begin
    Stream.Position := 0;
    FOTKA.Bitmap.LoadFromStream(Stream);
  end
  else FOTKA.Bitmap:= nil;
  Stream.Free;
end;

procedure TFrameDetail2.FOTKALoaded(Sender: TObject; const FileName: string);
var
  MS: TMemoryStream;
  FDQueryPhotos: TFDQuery;
begin
  if FOTKA.Bitmap.Width>0 then begin
    MS:= TMemoryStream.Create;
    FOTKA.Bitmap.SaveToStream(MS);
    MS.Position:= 0;

    FDQueryPhotos:= TFDQuery.Create(nil);
    FDQueryPhotos.Connection:= DM.FDConnection;
    FDQueryPhotos.SQL.Text:= 'select VIN from PHOTOS where VIN LIKE :VIN';
    FDQueryPhotos.ParamByName('VIN').AsString:= DM.FDQueryMain.FieldByName('VIN').AsString;
    FDQueryPhotos.Open();
    if FDQueryPhotos.RecordCount>0 then begin //update
      FDQueryPhotos.SQL.Text:= 'update PHOTOS set FOTKA = :FOTKA where VIN = :VIN';
    end
    else begin //create rec
      FDQueryPhotos.SQL.Text:= 'insert into PHOTOS (VIN, FOTKA) VALUES (:VIN, :FOTKA)';
    end;
    FDQueryPhotos.ParamByName('FOTKA').LoadFromStream(MS,ftBlob);
    FDQueryPhotos.ExecSQL;
    FDQueryPhotos.Free;
    MS.Free;
    DM.FDQueryMain.Refresh;
  end;
end;

procedure TFrameDetail2.LOGOClick(Sender: TObject);
begin
  UpdateMode:= True;
  Bazar.ActionBrandsModels(Sender);
end;

procedure TFrameDetail2.MenuItemDeleteClick(Sender: TObject);
begin
  var FDQueryPhotos:= TFDQuery.Create(nil);
  FDQueryPhotos.Connection:= DM.FDConnection;
  FDQueryPhotos.SQL.Text:= 'delete from PHOTOS where VIN LIKE :VIN';
  FDQueryPhotos.ParamByName('VIN').AsString:= DM.FDQueryMain.FieldByName('VIN').AsString;
  FDQueryPhotos.ExecSQL;
  FDQueryPhotos.Free;
  FOTKA.Bitmap:= nil;
  DM.FDQueryMain.Refresh;
end;

procedure TFrameDetail2.EmptyControls;
begin
  ZNACKA.Text:= '';
  MODEL.Text:= '';
  RZ.Text:= '';
  BARVA.Text:= '';
  CENA.Value:= 0;
  NAJETO.Value:= 0;
  MESIC.Value:= 1;
  ROK.Value:= CurrentYear;
  FOTKA.Bitmap:= nil;
  K_DISPOZICI.IsChecked:= False;
end;


procedure TFrameDetail2.SetParent(const Value: TFmxObject);
begin
  inherited;
  if Value = nil then begin

  end

  else begin
    Bazar.RECORDS.Visible:= True;
    Bazar.SUBLABEL.Visible:= True;
    ButtonVIN.Visible:= False;
    Bazar.RECORDSSetText;

    if UpdateMode then begin
      Bazar.ButtonBack.Visible:= False;
      Bazar.ButtonHome.Visible:= False;
      Bazar.ButtonFilter.Visible:= False;
      Bazar.ButtonTable.Visible:= False;
      Bazar.ButtonList.Visible:= False;
      Bazar.ButtonDetail.Visible:= False;
      UpdateMode:= False;
      BindNavigator1Click(nil, nbInsert);
    end
    else begin
      Bazar.ButtonBack.Visible:= True;
      Bazar.ButtonHome.Visible:= True;
      Bazar.ButtonFilter.Visible:= True;
      Bazar.ButtonTable.Visible:= True;
      Bazar.ButtonList.Visible:= True;
      Bazar.ButtonDetail.Visible:= False;
      LayoutNavigator.Enabled:= True;
      FillFOTKA;
    end;
  end;
end;


end.
