unit MainFMX;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, FMX.Types,
  FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls, FMX.Layouts,
  FMX.Controls.Presentation, Daisy.Theme, Daisy.Charts, Daisy.FMX.Control, Daisy.FMX.FormStyler,
  Daisy.FMX.Labels, Daisy.FMX.Select, Daisy.FMX.CheckBox, Daisy.FMX.PageControl,
  Daisy.FMX.ThemeController, Daisy.FMX.Chart;

type
  TFormCharts = class(TForm)
    Styler: TDaisyFmxFormStyler;
    lyTop: TLayout;
    lblTheme: TLabel;
    chkTitleBar: TDaisyFmxCheckBox;
    chkRTL: TDaisyFmxCheckBox;
    selTheme: TDaisyFmxSelect;
    themeCtl: TDaisyFmxThemeController;
    pcMain: TDaisyFmxPageControl;
    tsLine: TDaisyFmxTabSheet;
    tsColumn: TDaisyFmxTabSheet;
    tsBar: TDaisyFmxTabSheet;
    tsPie: TDaisyFmxTabSheet;
    tsDonut: TDaisyFmxTabSheet;
    tsRadial: TDaisyFmxTabSheet;
    lblLine: TDaisyFmxLabel;
    lblArea: TDaisyFmxLabel;
    chLine: TDaisyFmxChart;
    chArea: TDaisyFmxChart;
    lblColumn: TDaisyFmxLabel;
    lblColumnStacked: TDaisyFmxLabel;
    chColumn: TDaisyFmxChart;
    chColumnStacked: TDaisyFmxChart;
    lblBar: TDaisyFmxLabel;
    lblBarLabels: TDaisyFmxLabel;
    chBar: TDaisyFmxChart;
    chBarLabels: TDaisyFmxChart;
    lblPie: TDaisyFmxLabel;
    lblPieRight: TDaisyFmxLabel;
    chPie: TDaisyFmxChart;
    chPieRight: TDaisyFmxChart;
    lblDonut: TDaisyFmxLabel;
    lblDonutThin: TDaisyFmxLabel;
    chDonut: TDaisyFmxChart;
    chDonutThin: TDaisyFmxChart;
    lblRadial: TDaisyFmxLabel;
    lblRadialSingle: TDaisyFmxLabel;
    chRadial: TDaisyFmxChart;
    chRadialSingle: TDaisyFmxChart;
    procedure ThemeSelectChange(Sender: TObject);
    procedure RTLChange(Sender: TObject);
    procedure ThemeControllerChange(Sender: TObject);
    procedure chkTitleBarChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  end;

var
  FormCharts: TFormCharts;

implementation

{$R *.fmx}

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
  TDaisyControl.ApplyBiDiMode(Self, Modes[chkRTL.Checked]);
end;

procedure TFormCharts.ThemeSelectChange(Sender: TObject);
begin
  Styler.ApplyTheme(TDaisyThemeKind(selTheme.ItemIndex + 1));
end;

procedure TFormCharts.chkTitleBarChange(Sender: TObject);
begin
  Styler.ThemedTitleBar := chkTitleBar.Checked;
end;

end.
