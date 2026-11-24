unit MainVCL;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Daisy.Theme, Daisy.Charts,
  Daisy.VCL.Control, Daisy.VCL.FormStyler, Daisy.VCL.Labels, Daisy.VCL.Select, Daisy.VCL.CheckBox,
  Daisy.VCL.PageControl, Daisy.VCL.ThemeController, Daisy.VCL.Chart;

type
  TFormCharts = class(TForm)
    pnlTop: TPanel;
    lblTheme: TLabel;
    chkTitleBar: TDaisyCheckBox;
    chkRTL: TDaisyCheckBox;
    selTheme: TDaisySelect;
    themeCtl: TDaisyThemeController;
    pcMain: TDaisyPageControl;
    Styler: TDaisyFormStyler;
    tsLine: TDaisyTabSheet;
    tsColumn: TDaisyTabSheet;
    tsBar: TDaisyTabSheet;
    tsPie: TDaisyTabSheet;
    tsDonut: TDaisyTabSheet;
    tsRadial: TDaisyTabSheet;
    lblLine: TDaisyLabel;
    lblArea: TDaisyLabel;
    chLine: TDaisyChart;
    chArea: TDaisyChart;
    lblColumn: TDaisyLabel;
    lblColumnStacked: TDaisyLabel;
    chColumn: TDaisyChart;
    chColumnStacked: TDaisyChart;
    lblBar: TDaisyLabel;
    lblBarLabels: TDaisyLabel;
    chBar: TDaisyChart;
    chBarLabels: TDaisyChart;
    lblPie: TDaisyLabel;
    lblPieRight: TDaisyLabel;
    chPie: TDaisyChart;
    chPieRight: TDaisyChart;
    lblDonut: TDaisyLabel;
    lblDonutThin: TDaisyLabel;
    chDonut: TDaisyChart;
    chDonutThin: TDaisyChart;
    lblRadial: TDaisyLabel;
    lblRadialSingle: TDaisyLabel;
    chRadial: TDaisyChart;
    chRadialSingle: TDaisyChart;
    procedure ThemeSelectChange(Sender: TObject);
    procedure RTLChange(Sender: TObject);
    procedure ThemeControllerChange(Sender: TObject);
    procedure chkTitleBarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  end;

var
  FormCharts: TFormCharts;

implementation

{$R *.dfm}

procedure TFormCharts.FormShow(Sender: TObject);
begin
  Styler.ThemedTitleBar := chkTitleBar.Checked;
end;

procedure TFormCharts.ThemeControllerChange(Sender: TObject);
begin
  selTheme.ItemIndex := Ord(DaisyThemes.Current) - 1;
end;

procedure TFormCharts.RTLChange(Sender: TObject);
const
  Modes: array[Boolean] of TBiDiMode = (bdLeftToRight, bdRightToLeft);
begin
  if BiDiMode = Modes[chkRTL.Checked] then
    Exit;
  TDaisyControl.ApplyBiDiMode(Self, Modes[chkRTL.Checked]);
end;

procedure TFormCharts.ThemeSelectChange(Sender: TObject);
begin
  Styler.ApplyTheme(TDaisyThemeKind(selTheme.ItemIndex + 1));
end;

procedure TFormCharts.chkTitleBarClick(Sender: TObject);
begin
  Styler.ThemedTitleBar := chkTitleBar.Checked;
end;

end.
