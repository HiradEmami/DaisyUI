unit Daisy.VCL.Link;

{
  TDaisyLink - the DaisyUI "link": underlined text that reacts to the mouse. Variant picks
  the colour (link-primary, link-secondary ...), Underline = dluHover gives link-hover (the
  underline only shows while the mouse is over the link). URL, when set, is opened on click.
}

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  System.SysUtils, System.Classes, System.Types, System.UITypes, System.Math,
  Vcl.Controls, Daisy.Theme, Daisy.Navigation, Daisy.VCL.Control;

type
  TDaisyLink = class(TDaisyControl)
  strict private
    FUnderline: TDaisyLinkUnderline;
    FURL: string;
    FAutoFit: Boolean;
    FUpdating: Boolean;
    function GetCaption: string;
    procedure SetCaption(const Value: string);
    procedure SetUnderline(const Value: TDaisyLinkUnderline);
    procedure SetAutoFit(const Value: Boolean);
    function TextColor: TAlphaColor;
    procedure UpdateSize;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
  protected
    function IsInteractive: Boolean; override;
    function DrawsFocusRing: Boolean; override;
    function DefaultCornerRadius: Integer; override;
    function DefaultShadowSize: Integer; override;
    function DefaultContentPadding: Integer; override;
    function DefaultStyleColors(AState: TDaisyState): TDaisyColors; override;
    procedure SizeChanged; override;
    procedure Loaded; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DrawContent(const AColors: TDaisyColors; const ARect: TRect); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Click; override;
  published
    property Caption: string read GetCaption write SetCaption;
    // Address opened in the default browser when the link is clicked
    property URL: string read FURL write FURL;
    property Underline: TDaisyLinkUnderline read FUnderline write SetUnderline default dluAlways;
    // The size follows the caption and SizeKind; when off the control keeps its own size
    property AutoFit: Boolean read FAutoFit write SetAutoFit default True;
  end;

implementation

{ TDaisyLink }

constructor TDaisyLink.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAutoFit := True;
  TabStop := True;
  Cursor := crHandPoint;
  SetBounds(Left, Top, 80, 24);
  Caption := 'Link';
end;

function TDaisyLink.GetCaption: string;
begin
  Result := inherited Caption;
end;

procedure TDaisyLink.SetCaption(const Value: string);
begin
  inherited Caption := Value;
end;

function TDaisyLink.IsInteractive: Boolean;
begin
  Result := True;
end;

function TDaisyLink.DrawsFocusRing: Boolean;
begin
  Result := False;
end;

function TDaisyLink.DefaultCornerRadius: Integer;
begin
  Result := 0;
end;

function TDaisyLink.DefaultShadowSize: Integer;
begin
  Result := 0;
end;

function TDaisyLink.DefaultContentPadding: Integer;
begin
  Result := 0;
end;

function TDaisyLink.DefaultStyleColors(AState: TDaisyState): TDaisyColors;
begin
  Result := Default(TDaisyColors);
  Result.Text := TextColor;
end;

function TDaisyLink.TextColor: TAlphaColor;
begin
  if Variant = dvDefault then
    Result := Theme.BaseContent
  else
    Result := DaisyVariantPalette(Theme, Variant).Fill;
  if not Enabled then
    Result := DaisyWithAlpha(Theme.BaseContent, 0.3)
  else if Hot then
    Result := DaisyWithAlpha(Result, 0.8);
end;

procedure TDaisyLink.UpdateSize;
var
  LW, LH: Integer;
begin
  if (not FAutoFit) or FUpdating or (csLoading in ComponentState) then
    Exit;
  LW := MeasureTextWidth(Caption, DaisyFontSize(SizeKind), False) + 2 * ScaleValue(2);
  LH := MeasureTextHeight('Ag', 10000, DaisyFontSize(SizeKind), False) + 2 * ScaleValue(2);
  if (Width = LW) and (Height = LH) then
    Exit;
  FUpdating := True;
  try
    SetBounds(Left, Top, LW, LH);
  finally
    FUpdating := False;
  end;
end;

procedure TDaisyLink.SizeChanged;
begin
  UpdateSize;
end;

procedure TDaisyLink.Loaded;
begin
  inherited;
  UpdateSize;
end;

procedure TDaisyLink.CMTextChanged(var Message: TMessage);
begin
  inherited;
  UpdateSize;
end;

procedure TDaisyLink.SetUnderline(const Value: TDaisyLinkUnderline);
begin
  if FUnderline <> Value then
  begin
    FUnderline := Value;
    Invalidate;
  end;
end;

procedure TDaisyLink.SetAutoFit(const Value: Boolean);
begin
  if FAutoFit <> Value then
  begin
    FAutoFit := Value;
    UpdateSize;
  end;
end;

procedure TDaisyLink.Click;
begin
  inherited Click;
  if (FURL <> '') and Enabled and not (csDesigning in ComponentState) then
    ShellExecute(0, 'open', PChar(FURL), nil, nil, SW_SHOWNORMAL);
end;

procedure TDaisyLink.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if (Key in [VK_RETURN, VK_SPACE]) and Enabled then
  begin
    Click;
    Key := 0;
  end;
end;

procedure TDaisyLink.DrawContent(const AColors: TDaisyColors; const ARect: TRect);
var
  LGraphics: TGPGraphics;
  LFont, LTextW, LTextH, LLeft, LTop, LLineY: Integer;
  LRect: TRect;
begin
  LFont := DaisyFontSize(SizeKind);
  LTextW := MeasureTextWidth(Caption, LFont, False);
  LTextH := MeasureTextHeight('Ag', 10000, LFont, False);
  LLeft := ScaleValue(2);
  LTop := (Height - LTextH) div 2;
  LRect := Rect(LLeft, LTop, Min(Width - LLeft, LLeft + LTextW + ScaleValue(2)), LTop + LTextH);

  DrawText(Caption, LRect, AColors.Text, LFont, False, DT_LEFT or DT_SINGLELINE or DT_VCENTER);

  LGraphics := NewGraphics;
  try
    if (FUnderline = dluAlways) or Hot or Focused then
    begin
      LLineY := LTop + LTextH - ScaleValue(2);
      FillRoundRect(LGraphics, RectF(LLeft, LLineY, LRect.Right - ScaleValue(2),
        LLineY + Max(1, ScaleValue(1))), 0, AColors.Text);
    end;
    if Focused then
      DrawItemFocus(LGraphics, RectF(LLeft, LTop, LRect.Right - ScaleValue(2), LTop + LTextH),
        ScaleValue(2));
  finally
    LGraphics.Free;
  end;
end;

end.
