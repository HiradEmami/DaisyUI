program Charts01VCLDemo;

uses
  Vcl.Forms,
  Daisy.Theme in '..\..\Source\Common\Daisy.Theme.pas',
  Daisy.Items in '..\..\Source\Common\Daisy.Items.pas',
  Daisy.Animation in '..\..\Source\Common\Daisy.Animation.pas',
  Daisy.SVG in '..\..\Source\Common\Daisy.SVG.pas',
  Daisy.Widgets in '..\..\Source\Common\Daisy.Widgets.pas',
  Daisy.TextEdit in '..\..\Source\Common\Daisy.TextEdit.pas',
  Daisy.Charts in '..\..\Source\Common\Daisy.Charts.pas',
  Daisy.VCL.Control in '..\..\Source\VCL\Daisy.VCL.Control.pas',
  Daisy.VCL.FormStyler in '..\..\Source\VCL\Daisy.VCL.FormStyler.pas',
  Daisy.VCL.Labels in '..\..\Source\VCL\Daisy.VCL.Labels.pas',
  Daisy.VCL.Select in '..\..\Source\VCL\Daisy.VCL.Select.pas',
  Daisy.VCL.CheckBox in '..\..\Source\VCL\Daisy.VCL.CheckBox.pas',
  Daisy.VCL.PageControl in '..\..\Source\VCL\Daisy.VCL.PageControl.pas',
  Daisy.VCL.ThemeController in '..\..\Source\VCL\Daisy.VCL.ThemeController.pas',
  Daisy.VCL.Chart in '..\..\Source\VCL\Daisy.VCL.Chart.pas',
  MainVCL in 'MainVCL.pas' {FormCharts};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormCharts, FormCharts);
  Application.Run;
end.
