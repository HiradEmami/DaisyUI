unit Daisy.FMX.TitleBarPanel;

{
  TDaisyFmxTitleBarPanel - not part of daisyUI. FMX has no custom title bar, so this panel is one:
  a themed bar that is aligned to the top of the form, draws the form's caption and the minimize /
  maximize / close buttons, drags the window when its empty area is dragged (double-click toggles
  maximize) and hosts any other control: dock, text input, toggle, swap, buttons, badges, labels ...

  With HideNativeTitleBar the form's native title bar is removed at run time (BorderStyle := None) and
  this panel replaces it. A borderless form cannot be resized from its edges.
  Without it the native title bar stays, and the form styler's ThemedTitleBar colours it; the panel is
  then only a themed container.
  While TDaisyControl.ThemedTitleBar is False the panel uses neutral light colours instead of the theme.
}

interface

uses
  System.Classes, System.Types, System.UITypes, System.SysUtils, FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms,
  Daisy.Theme, Daisy.FMX.Control;

type
  TDaisyFmxTitleButton = (dtbMinimize, dtbMaximize, dtbClose);
  TDaisyFmxTitleButtons = set of TDaisyFmxTitleButton;

  TDaisyFmxTitleBarPanel = class(TDaisyControl)
  strict private
    FShowCaption: Boolean;
    FCaptionAlignment: TTextAlign;
    FSystemButtons: TDaisyFmxTitleButtons;
    FHideNativeTitleBar: Boolean;
    procedure SetShowCaption(const Value: Boolean);
    procedure SetCaptionAlignment(const Value: TTextAlign);
    procedure SetSystemButtons(const Value: TDaisyFmxTitleButtons);
    procedure SetHideNativeTitleBar(const Value: Boolean);
    procedure TitleBarThemeChanged(Sender: TObject);
    function ParentForm: TCommonCustomForm;
    // Gives the borderless form back the drop shadow and thin border of a normal window
    procedure ApplyWindowFrame;
    function DrawsChrome: Boolean;
    function ButtonRect(AButton: TDaisyFmxTitleButton): TRectF;
    function ButtonsWidth: Single;
    procedure DrawButton(AButton: TDaisyFmxTitleButton; const AColors: TDaisyColors);
  protected
    function DefaultCornerRadius: Integer; override;
    function DefaultShadowSize: Integer; override;
    function DefaultContentPadding: Integer; override;
    function DefaultStyleColors(AState: TDaisyState): TDaisyColors; override;
    function TrackedItemAt(const APoint: TPointF): Integer; override;
    procedure TrackedItemChanged; override;
    procedure DrawContent(const AColors: TDaisyColors; const ARect: TRectF); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property ShowCaption: Boolean read FShowCaption write SetShowCaption default True;
    property CaptionAlignment: TTextAlign read FCaptionAlignment write SetCaptionAlignment
      default TTextAlign.Leading;
    property SystemButtons: TDaisyFmxTitleButtons read FSystemButtons write SetSystemButtons
      default [dtbMinimize, dtbMaximize, dtbClose];
    // Removes the form's native title bar at run time (the panel replaces it)
    property HideNativeTitleBar: Boolean read FHideNativeTitleBar write SetHideNativeTitleBar
      default True;
    property Align default TAlignLayout.Top;
  end;

implementation

uses
{$IFDEF MSWINDOWS}
  Winapi.Windows, Winapi.Dwmapi, Winapi.UxTheme, FMX.Platform.Win,
{$ENDIF}
  System.Math;

const
  CButtonWidth = 46;
  CGlyphSize = 10;
  CCaptionMargin = 12;
  CCloseRed = TAlphaColor($FFC42B1C);

{ TDaisyFmxTitleBarPanel }

constructor TDaisyFmxTitleBarPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FShowCaption := True;
  FCaptionAlignment := TTextAlign.Leading;
  FSystemButtons := [dtbMinimize, dtbMaximize, dtbClose];
  FHideNativeTitleBar := True;
  SetBounds(Position.X, Position.Y, 320, 32);
  Align := TAlignLayout.Top;
  if not (csDesigning in ComponentState) then
    TDaisyControl.AddTitleBarListener(TitleBarThemeChanged);
end;

destructor TDaisyFmxTitleBarPanel.Destroy;
begin
  TDaisyControl.RemoveTitleBarListener(TitleBarThemeChanged);
  inherited Destroy;
end;

procedure TDaisyFmxTitleBarPanel.Loaded;
var
  LForm: TCommonCustomForm;
begin
  inherited Loaded;
  // the Variant property is hidden; clear any value left in an older form file
  Variant := dvDefault;
  if FHideNativeTitleBar and not (csDesigning in ComponentState) then
  begin
    LForm := ParentForm;
    if (LForm <> nil) and (LForm.BorderStyle <> TFmxFormBorderStyle.None) then
      LForm.BorderStyle := TFmxFormBorderStyle.None;
    ApplyWindowFrame;
  end;
end;

procedure TDaisyFmxTitleBarPanel.ApplyWindowFrame;
{$IFDEF MSWINDOWS}
const
  DWMWA_WINDOW_CORNER_PREFERENCE = 33;
  DWMWA_BORDER_COLOR = 34;
  DWMWCP_ROUND = 2;
  DWMWA_COLOR_DEFAULT = $FFFFFFFF;
var
  LForm: TCommonCustomForm;
  LWnd: HWND;
  LMargins: TMargins;
  LCorner: Integer;
  LBorder: DWORD;
  LColor: TAlphaColorRec;
begin
  if (csDesigning in ComponentState) or not DrawsChrome then
    Exit;
  LForm := ParentForm;
  if LForm = nil then
    Exit;
  LWnd := FormToHWND(LForm);
  if LWnd = 0 then
    Exit;
  // a one pixel frame extension is what makes DWM draw the shadow of a window without a frame
  LMargins.cxLeftWidth := 1;
  LMargins.cxRightWidth := 1;
  LMargins.cyTopHeight := 1;
  LMargins.cyBottomHeight := 1;
  DwmExtendFrameIntoClientArea(LWnd, LMargins);
  LCorner := DWMWCP_ROUND;
  DwmSetWindowAttribute(LWnd, DWMWA_WINDOW_CORNER_PREFERENCE, @LCorner, SizeOf(LCorner));
  if TDaisyControl.ThemedTitleBar then
  begin
    LColor := TAlphaColorRec(Theme.BorderColor);
    LBorder := DWORD(LColor.R) or (DWORD(LColor.G) shl 8) or (DWORD(LColor.B) shl 16);
  end
  else
    LBorder := DWMWA_COLOR_DEFAULT;
  DwmSetWindowAttribute(LWnd, DWMWA_BORDER_COLOR, @LBorder, SizeOf(LBorder));
end;
{$ELSE}
begin
end;
{$ENDIF}

function TDaisyFmxTitleBarPanel.ParentForm: TCommonCustomForm;
begin
  Result := nil;
  if (Root <> nil) and (Root.GetObject is TCommonCustomForm) then
    Result := TCommonCustomForm(Root.GetObject);
end;

// The caption and buttons are drawn when this panel stands in for the native title bar
function TDaisyFmxTitleBarPanel.DrawsChrome: Boolean;
var
  LForm: TCommonCustomForm;
begin
  if csDesigning in ComponentState then
    Exit(FHideNativeTitleBar);
  LForm := ParentForm;
  Result := (LForm <> nil) and (LForm.BorderStyle = TFmxFormBorderStyle.None);
end;

procedure TDaisyFmxTitleBarPanel.TitleBarThemeChanged(Sender: TObject);
begin
  ApplyWindowFrame;
  Repaint;
end;

procedure TDaisyFmxTitleBarPanel.SetShowCaption(const Value: Boolean);
begin
  if FShowCaption <> Value then
  begin
    FShowCaption := Value;
    Repaint;
  end;
end;

procedure TDaisyFmxTitleBarPanel.SetCaptionAlignment(const Value: TTextAlign);
begin
  if FCaptionAlignment <> Value then
  begin
    FCaptionAlignment := Value;
    Repaint;
  end;
end;

procedure TDaisyFmxTitleBarPanel.SetSystemButtons(const Value: TDaisyFmxTitleButtons);
begin
  if FSystemButtons <> Value then
  begin
    FSystemButtons := Value;
    Repaint;
  end;
end;

procedure TDaisyFmxTitleBarPanel.SetHideNativeTitleBar(const Value: Boolean);
begin
  if FHideNativeTitleBar <> Value then
  begin
    FHideNativeTitleBar := Value;
    Repaint;
  end;
end;

function TDaisyFmxTitleBarPanel.DefaultCornerRadius: Integer;
begin
  Result := 0;
end;

function TDaisyFmxTitleBarPanel.DefaultShadowSize: Integer;
begin
  Result := 0;
end;

function TDaisyFmxTitleBarPanel.DefaultContentPadding: Integer;
begin
  Result := 0;
end;

function TDaisyFmxTitleBarPanel.DefaultStyleColors(AState: TDaisyState): TDaisyColors;
var
  LTheme: TDaisyTheme;
begin
  LTheme := Theme;
  Result := DaisyResolveColors(LTheme, dvDefault, dsSolid, dstNormal);
  Result.Border := TAlphaColors.Null;
  if not Enabled then
    Exit;
  if not TDaisyControl.ThemedTitleBar then
  begin
    Result.Background := TAlphaColor($FFF3F3F3);
    Result.Text := TAlphaColors.Black;
  end
  else
  begin
    Result.Background := LTheme.Base100;
    Result.Text := LTheme.BaseContent;
  end;
end;

function TDaisyFmxTitleBarPanel.ButtonsWidth: Single;
var
  LButton: TDaisyFmxTitleButton;
begin
  Result := 0;
  if DrawsChrome then
    for LButton in FSystemButtons do
      Result := Result + CButtonWidth;
end;

// Buttons sit at the right end in the order minimize, maximize, close
function TDaisyFmxTitleBarPanel.ButtonRect(AButton: TDaisyFmxTitleButton): TRectF;
var
  LButton: TDaisyFmxTitleButton;
  LRight: Single;
begin
  LRight := Width;
  for LButton := High(TDaisyFmxTitleButton) downto Low(TDaisyFmxTitleButton) do
    if LButton in FSystemButtons then
    begin
      if LButton = AButton then
        Exit(RectF(LRight - CButtonWidth, 0, LRight, Height));
      LRight := LRight - CButtonWidth;
    end;
  Result := TRectF.Empty;
end;

function TDaisyFmxTitleBarPanel.TrackedItemAt(const APoint: TPointF): Integer;
var
  LButton: TDaisyFmxTitleButton;
begin
  Result := -1;
  if DrawsChrome then
    for LButton in FSystemButtons do
      if ButtonRect(LButton).Contains(APoint) then
        Exit(Ord(LButton));
end;

procedure TDaisyFmxTitleBarPanel.TrackedItemChanged;
begin
  Repaint;
end;

procedure TDaisyFmxTitleBarPanel.DrawButton(AButton: TDaisyFmxTitleButton;
  const AColors: TDaisyColors);
var
  LRect, LGlyph: TRectF;
  LForeground, LBack: TAlphaColor;
  LMaximized: Boolean;
  LForm: TCommonCustomForm;
begin
  LRect := ButtonRect(AButton);
  LForeground := AColors.Text;
  if TrackedItem = Ord(AButton) then
  begin
    if AButton = dtbClose then
    begin
      LBack := CCloseRed;
      LForeground := TAlphaColors.White;
    end
    else
      LBack := DaisyMix(AColors.Background, AColors.Text, 0.12);
    Canvas.Fill.Kind := TBrushKind.Solid;
    Canvas.Fill.Color := LBack;
    Canvas.FillRect(LRect, 0, 0, [], AbsoluteOpacity);
  end;

  LGlyph := RectF(0, 0, CGlyphSize, CGlyphSize);
  LGlyph.SetLocation(Round((LRect.Left + LRect.Right - CGlyphSize) / 2),
    Round((LRect.Top + LRect.Bottom - CGlyphSize) / 2));
  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Color := LForeground;
  Canvas.Stroke.Thickness := 1;
  Canvas.Stroke.Dash := TStrokeDash.Solid;
  case AButton of
    dtbMinimize:
      Canvas.DrawLine(PointF(LGlyph.Left, LGlyph.CenterPoint.Y + 0.5),
        PointF(LGlyph.Right, LGlyph.CenterPoint.Y + 0.5), AbsoluteOpacity);
    dtbMaximize:
      begin
        LForm := ParentForm;
        LMaximized := (LForm <> nil) and (LForm.WindowState = TWindowState.wsMaximized);
        if LMaximized then
        begin
          Canvas.DrawRect(RectF(LGlyph.Left, LGlyph.Top + 2.5, LGlyph.Right - 2, LGlyph.Bottom - 0.5),
            0, 0, [], AbsoluteOpacity);
          Canvas.DrawLine(PointF(LGlyph.Left + 2.5, LGlyph.Top + 2.5),
            PointF(LGlyph.Left + 2.5, LGlyph.Top + 0.5), AbsoluteOpacity);
          Canvas.DrawLine(PointF(LGlyph.Left + 2.5, LGlyph.Top + 0.5),
            PointF(LGlyph.Right - 0.5, LGlyph.Top + 0.5), AbsoluteOpacity);
          Canvas.DrawLine(PointF(LGlyph.Right - 0.5, LGlyph.Top + 0.5),
            PointF(LGlyph.Right - 0.5, LGlyph.Bottom - 2.5), AbsoluteOpacity);
          Canvas.DrawLine(PointF(LGlyph.Right - 0.5, LGlyph.Bottom - 2.5),
            PointF(LGlyph.Right - 2, LGlyph.Bottom - 2.5), AbsoluteOpacity);
        end
        else
          Canvas.DrawRect(RectF(LGlyph.Left + 0.5, LGlyph.Top + 0.5, LGlyph.Right - 0.5,
            LGlyph.Bottom - 0.5), 0, 0, [], AbsoluteOpacity);
      end;
    dtbClose:
      begin
        Canvas.DrawLine(LGlyph.TopLeft, LGlyph.BottomRight, AbsoluteOpacity);
        Canvas.DrawLine(PointF(LGlyph.Right, LGlyph.Top), PointF(LGlyph.Left, LGlyph.Bottom),
          AbsoluteOpacity);
      end;
  end;
end;

procedure TDaisyFmxTitleBarPanel.DrawContent(const AColors: TDaisyColors; const ARect: TRectF);
var
  LButton: TDaisyFmxTitleButton;
  LCaption: TRectF;
  LForm: TCommonCustomForm;
begin
  if not DrawsChrome then
    Exit;
  for LButton in FSystemButtons do
    DrawButton(LButton, AColors);
  LForm := ParentForm;
  if FShowCaption and (LForm <> nil) then
  begin
    LCaption := RectF(CCaptionMargin, 0, Width - ButtonsWidth - CCaptionMargin, Height);
    DrawText(LForm.Caption, LCaption, AColors.Text, 12, False, FCaptionAlignment,
      TTextAlign.Center, False);
  end;
end;

procedure TDaisyFmxTitleBarPanel.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  LForm: TCommonCustomForm;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button <> TMouseButton.mbLeft) or (csDesigning in ComponentState) or not DrawsChrome
    or (TrackedItemAt(PointF(X, Y)) <> -1) then
    Exit;
  LForm := ParentForm;
  if LForm = nil then
    Exit;
  if ssDouble in Shift then
  begin
    if dtbMaximize in FSystemButtons then
      if LForm.WindowState = TWindowState.wsMaximized then
        LForm.WindowState := TWindowState.wsNormal
      else
        LForm.WindowState := TWindowState.wsMaximized;
  end
  else
    LForm.StartWindowDrag;
end;

procedure TDaisyFmxTitleBarPanel.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  LForm: TCommonCustomForm;
  LItem: Integer;
begin
  inherited MouseUp(Button, Shift, X, Y);
  if (Button <> TMouseButton.mbLeft) or (csDesigning in ComponentState) then
    Exit;
  LForm := ParentForm;
  LItem := TrackedItemAt(PointF(X, Y));
  if (LForm = nil) or (LItem = -1) then
    Exit;
  case TDaisyFmxTitleButton(LItem) of
    dtbMinimize:
      LForm.WindowState := TWindowState.wsMinimized;
    dtbMaximize:
      if LForm.WindowState = TWindowState.wsMaximized then
        LForm.WindowState := TWindowState.wsNormal
      else
        LForm.WindowState := TWindowState.wsMaximized;
    dtbClose:
      LForm.Close;
  end;
end;

end.
