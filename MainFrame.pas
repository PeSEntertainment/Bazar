unit MainFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FireDAC.UI.Intf, FireDAC.FMXUI.Wait,
  FireDAC.Stan.Intf, FireDAC.Comp.UI,
  DataModule;

type
  TFrameMain = class(TFrame)
    ButtonTabulka: TButton;
    ButtonList: TButton;
    ButtonZnacky: TButton;
    ButtonBarvy: TButton;
    ButtonDetail: TButton;
    ButtonNastaveni: TButton;
  private

  public
    constructor Create(AOwner: TComponent); override;
    procedure SetParent(const Value: TFmxObject); override;
  end;

implementation

{$R *.fmx}

uses
  AppBazar;

constructor TFrameMain.Create(AOwner: TComponent);
begin
  inherited;
  ButtonTabulka.OnClick:= Bazar.ActionTabulka2;
  ButtonNastaveni.OnClick:= Bazar.ActionSetup;
  ButtonDetail.OnClick:= Bazar.ActionDetail2;
  ButtonZnacky.OnClick:= Bazar.ActionBrandsModels;
  ButtonList.OnClick:= Bazar.ActionTabulka3;
  ButtonBarvy.OnClick:= Bazar.ActionColors;
  Bazar.SUBLABEL.Visible:= True;
end;

procedure TFrameMain.SetParent(const Value: TFmxObject);
begin
  inherited;
  if Value = nil then begin
  end

  else begin
    Bazar.ButtonBack.Visible:= False;
    Bazar.ButtonHome.Visible:= False;
    Bazar.ButtonFilter.Visible:= True;

    Bazar.ButtonTable.Visible:= True;
    Bazar.ButtonList.Visible:= True;
    Bazar.ButtonDetail.Visible:= True;

    Bazar.SUBLABEL.Visible:= True;
    Bazar.RECORDS.Visible:= True;
    Bazar.RECORDS.Text:= DM.FDQueryMain.RecordCount.ToString;
  end;
end;

end.
