unit Daisy.VCL.TitleBarPanel;

{
  TDaisyTitleBarPanel - not part of daisyUI. It is the VCL TTitleBarPanel (so it gets the form's
  custom title bar, the system caption buttons and every other control dropped on it) that also
  follows the Daisy theme: while TDaisyControl.ThemedTitleBar is True (the TDaisyFormStyler's
  ThemedTitleBar) it colours the form's CustomTitleBar from the current theme and restyles it
  whenever the theme changes. When ThemedTitleBar is False the title bar keeps the system colours.
  Daisy controls (dock, text input, toggle, swap, buttons, badges, labels ...) can be placed on it.

  At run time the panel connects itself to the form (CustomTitleBar.Control and Enabled) when
  AutoAttach is True and the form has no title bar control yet. Needs Windows 10 or later.
}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.UITypes, Vcl.Controls, Vcl.Forms,
  Vcl.TitleBarCtrls, Daisy.Theme, Daisy.VCL.Control;

type
  TDaisyTitleBarPanel = class(TCustomTitleBarPanel)
  strict private
    FAutoAttach: Boolean;
    procedure TitleBarThemeChanged(Sender: TObject);
    procedure AttachToForm;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMPrintClient(var Message: TMessage); message WM_PRINTCLIENT;
  protected
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    // Colours the form's CustomTitleBar from the current theme (or restores the system colours)
    procedure ApplyTheme;
  published
    // At run time makes this panel the form's CustomTitleBar.Control (and enables the custom
    // title bar) when the form does not have one yet
    property AutoAttach: Boolean read FAutoAttach write FAutoAttach default True;
    property OnPaint;
    property CustomButtons;
  end;

implementation

{ TDaisyTitleBarPanel }

constructor TDaisyTitleBarPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAutoAttach := True;
  if not (csDesigning in ComponentState) then
    TDaisyControl.AddTitleBarListener(TitleBarThemeChanged);
end;

destructor TDaisyTitleBarPanel.Destroy;
var
  LForm: TCustomForm;
begin
  // Deleting the panel in the designer must not leave an enabled custom title bar without a
  // control, which the designer draws as a hatched area. Detach while the panel is still intact.
  if csDesigning in ComponentState then
  begin
    LForm := GetParentForm(Self);
    if (LForm <> nil) and not (csDestroying in LForm.ComponentState) and
      (LForm.CustomTitleBar.Control = Self) then
    begin
      LForm.CustomTitleBar.Control := nil;
      LForm.CustomTitleBar.Enabled := False;
    end;
  end;
  // The inherited destructors free the canvas and then detach from the form's title bar, which
  // repaints the form and its children (the designer does this when the panel is deleted). Flag
  // the panel as destroying first so nothing paints through the freed canvas.
  Destroying;
  TDaisyControl.RemoveTitleBarListener(TitleBarThemeChanged);
  inherited Destroy;
end;

procedure TDaisyTitleBarPanel.WMPaint(var Message: TWMPaint);
begin
  if not (csDestroying in ComponentState) then
    inherited;
end;

procedure TDaisyTitleBarPanel.WMPrintClient(var Message: TMessage);
begin
  if not (csDestroying in ComponentState) then
    inherited;
end;

procedure TDaisyTitleBarPanel.Loaded;
begin
  inherited Loaded;
  if csDesigning in ComponentState then
    Exit;
  AttachToForm;
  ApplyTheme;
  // the form finishes loading after its components and may reset the title bar colours
  TThread.ForceQueue(nil, ApplyTheme);
end;

procedure TDaisyTitleBarPanel.AttachToForm;
var
  LForm: TCustomForm;
begin
  LForm := GetParentForm(Self);
  if FAutoAttach and (LForm <> nil) and (LForm.CustomTitleBar.Control = nil) then
  begin
    LForm.CustomTitleBar.Control := Self;
    LForm.CustomTitleBar.Enabled := True;
  end;
end;

procedure TDaisyTitleBarPanel.TitleBarThemeChanged(Sender: TObject);
begin
  ApplyTheme;
end;

procedure TDaisyTitleBarPanel.ApplyTheme;
var
  LForm: TCustomForm;
  LTheme: TDaisyTheme;
  LBack, LFore: TAlphaColor;
begin
  if (csDesigning in ComponentState) or (csDestroying in ComponentState) then
    Exit;
  LForm := GetParentForm(Self);
  if (LForm = nil) or (csDestroying in LForm.ComponentState) or
    (LForm.CustomTitleBar.Control <> Self) then
    Exit;
  with LForm.CustomTitleBar do
    if not TDaisyControl.ThemedTitleBar then
      SystemColors := True
    else
    begin
      LTheme := DaisyGetTheme(dtInherit);
      LBack := LTheme.Base100;
      LFore := LTheme.BaseContent;
      // the colour properties only take a value while SystemColors is False
      SystemColors := False;
      StyleColors := False;
      BackgroundColor := DaisyToColor(LBack);
      InactiveBackgroundColor := DaisyToColor(LBack);
      ForegroundColor := DaisyToColor(LFore);
      InactiveForegroundColor := DaisyToColor(DaisyMix(LFore, LBack, 0.5));
      ButtonBackgroundColor := DaisyToColor(LBack);
      ButtonForegroundColor := DaisyToColor(LFore);
      ButtonHoverBackgroundColor := DaisyToColor(DaisyMix(LBack, LFore, 0.1));
      ButtonHoverForegroundColor := DaisyToColor(LFore);
      ButtonPressedBackgroundColor := DaisyToColor(DaisyMix(LBack, LFore, 0.2));
      ButtonPressedForegroundColor := DaisyToColor(LFore);
      ButtonInactiveBackgroundColor := DaisyToColor(LBack);
      ButtonInactiveForegroundColor := DaisyToColor(DaisyMix(LFore, LBack, 0.5));
    end;
  LForm.CustomTitleBar.Invalidate;
  Invalidate;
end;

end.
