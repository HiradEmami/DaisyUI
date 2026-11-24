program Charts01FMXDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  Daisy.Theme in '..\..\Source\Common\Daisy.Theme.pas',
  Daisy.Items in '..\..\Source\Common\Daisy.Items.pas',
  Daisy.Animation in '..\..\Source\Common\Daisy.Animation.pas',
  Daisy.SVG in '..\..\Source\Common\Daisy.SVG.pas',
  Daisy.Widgets in '..\..\Source\Common\Daisy.Widgets.pas',
  Daisy.TextEdit in '..\..\Source\Common\Daisy.TextEdit.pas',
  Daisy.Charts in '..\..\Source\Common\Daisy.Charts.pas',
  Daisy.FMX.Control in '..\..\Source\FMX\Daisy.FMX.Control.pas',
  Daisy.FMX.FormStyler in '..\..\Source\FMX\Daisy.FMX.FormStyler.pas',
  Daisy.FMX.Labels in '..\..\Source\FMX\Daisy.FMX.Labels.pas',
  Daisy.FMX.Select in '..\..\Source\FMX\Daisy.FMX.Select.pas',
  Daisy.FMX.CheckBox in '..\..\Source\FMX\Daisy.FMX.CheckBox.pas',
  Daisy.FMX.PageControl in '..\..\Source\FMX\Daisy.FMX.PageControl.pas',
  Daisy.FMX.ThemeController in '..\..\Source\FMX\Daisy.FMX.ThemeController.pas',
  Daisy.FMX.Chart in '..\..\Source\FMX\Daisy.FMX.Chart.pas',
  MainFMX in 'MainFMX.pas' {FormCharts};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormCharts, FormCharts);
  Application.Run;
end.
