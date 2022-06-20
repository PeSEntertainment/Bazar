unit Table2.Form;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  DataModule, System.Rtti, FMX.Grid.Style, Fmx.Bind.Grid,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, Data.Bind.Components, Data.Bind.Grid,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Grid, Data.Bind.DBScope;

type
  TFormTable2 = class(TForm)
    BindSourceDB1: TBindSourceDB;
    StringGridBindSourceDB1: TStringGrid;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    BindingsList1: TBindingsList;
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormTable2: TFormTable2;

implementation

{$R *.fmx}


procedure TFormTable2.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
var
  I: Integer;
begin
  I:= 1;
end;

end.
