unit Daisy.FMX.Link;

{
  TDaisyFmxLink - the DaisyUI "link": underlined text that reacts to the mouse. Variant picks
  the colour (link-primary, link-secondary ...), Underline = dluHover gives link-hover (the
  underline only shows while the mouse is over the link). URL, when set, is opened on click.
}

interface

uses
  {$IFDEF MSWINDOWS}
  Winapi.Windows, Winapi.ShellAPI,
  {$ENDIF}
  System.SysUtils, System.Classes, System.Types, System.UITypes, System.Math,
  FMX.Types, FMX.Controls, FMX.Graphics, Daisy.Theme, Daisy.Navigation, Daisy.FMX.Control;

type
  TDaisyFmxLink = class(TDaisyControl)
  strict private
    FText: string;
    FUnderline: TDaisyLinkUnderline;
    FURL: string;
    FAutoFit: Boolean;
    FUpdating: Boolean;
    procedure SetText(const Value: string);
    procedure SetUnderline(const Value: TDaisyLinkUnderline);
    procedure SetAutoFit(const Value: Boolean);
    function TextColor: TAlphaColor;
    procedure UpdateSize;
  protected
    function IsInteractive: Boolean; override;
    function DrawsFocusRing: Boolean; override;
    function DefaultCornerRadius: Integer; override;
    function DefaultShadowSize: Integer; override;
    function DefaultContentPadding: Integer; override;
    function DefaultStyleColors(AState: TDaisyState): TDaisyColors; override;
    procedure SizeChanged; override;
    procedure Loaded; override;
    procedure KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure DrawContent(const AColors: TDaisyColors; const ARect: TRectF); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Click; override;
  published
    property Text: string read FText write SetText;
    // Address opened in the default browser when the link is clicked
    property URL: string read FURL write FURL;
    property Underline: TDaisyLinkUnderline read FUnderline write SetUnderline default dluAlways;
    // The size follows the text and SizeKind; when off the control keeps its own size
    property AutoFit: Boolean read FAutoFit write SetAutoFit default True;
  end;

implementation

{ TDaisyFmxLink }

constructor TDaisyFmxLink.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FText := 'Link';
  FAutoFit := True;
  CanFocus := True;
  TabStop := True;
  Cursor := crHandPoint;
  SetBounds(Position.X, Position.Y, 80, 24);
  UpdateSize;
end;

function TDaisyFmxLink.IsInteractive: Boolean;
begin
  Result := True;
end;

function TDaisyFmxLink.DrawsFocusRing: Boolean;
begin
  Result := False;
end;

function TDaisyFmxLink.DefaultCornerRadius: Integer;
begin
  Result := 0;
end;

function TDaisyFmxLink.DefaultShadowSize: Integer;
begin
  Result := 0;
end;

function TDaisyFmxLink.DefaultContentPadding: Integer;
begin
  Result := 0;
end;

function TDaisyFmxLink.DefaultStyleColors(AState: TDaisyState): TDaisyColors;
begin
  Result := Default(TDaisyColors);
  Result.Text := TextColor;
end;

function TDaisyFmxLink.TextColor: TAlphaColor;
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

procedure TDaisyFmxLink.UpdateSize;
var
  LW, LH: Single;
begin
  if (not FAutoFit) or FUpdating or (csLoading in ComponentState) then
    Exit;
  LW := MeasureTextWidth(FText, DaisyFontSize(SizeKind), False) + 2 * 2;
  LH := MeasureTextHeight('Ag', 10000, DaisyFontSize(SizeKind), False) + 2 * 2;
  if SameValue(Width, LW) and SameValue(Height, LH) then
    Exit;
  FUpdating := True;
  try
    SetBounds(Position.X, Position.Y, LW, LH);
  finally
    FUpdating := False;
  end;
end;

procedure TDaisyFmxLink.SizeChanged;
begin
  UpdateSize;
  Repaint;
end;

procedure TDaisyFmxLink.Loaded;
begin
  inherited;
  UpdateSize;
end;

procedure TDaisyFmxLink.SetText(const Value: string);
begin
  if FText <> Value then
  begin
    FText := Value;
    UpdateSize;
    Repaint;
  end;
end;

procedure TDaisyFmxLink.SetUnderline(const Value: TDaisyLinkUnderline);
begin
  if FUnderline <> Value then
  begin
    FUnderline := Value;
    Repaint;
  end;
end;

procedure TDaisyFmxLink.SetAutoFit(const Value: Boolean);
begin
  if FAutoFit <> Value then
  begin
    FAutoFit := Value;
    UpdateSize;
  end;
end;

procedure TDaisyFmxLink.Click;
begin
  inherited Click;
  {$IFDEF MSWINDOWS}
  if (FURL <> '') and Enabled and not (csDesigning in ComponentState) then
    ShellExecute(0, 'open', PChar(FURL), nil, nil, SW_SHOWNORMAL);
  {$ENDIF}
end;

procedure TDaisyFmxLink.KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  if Enabled and ((Key = vkReturn) or (KeyChar = ' ')) then
  begin
    Key := 0;
    KeyChar := #0;
    Click;
  end
  else
    inherited KeyDown(Key, KeyChar, Shift);
end;

procedure TDaisyFmxLink.DrawContent(const AColors: TDaisyColors; const ARect: TRectF);
var
  LFont: Integer;
  LTextW, LTextH, LLeft, LTop, LLineY, LRight: Single;
begin
  LFont := DaisyFontSize(SizeKind);
  LTextW := MeasureTextWidth(FText, LFont, False);
  LTextH := MeasureTextHeight('Ag', 10000, LFont, False);
  LLeft := 2;
  LTop := (Height - LTextH) / 2;
  LRight := System.Math.Min(Width - LLeft, LLeft + LTextW + 2);

  DrawText(FText, RectF(LLeft, LTop, LRight, LTop + LTextH), AColors.Text, LFont, False,
    TTextAlign.Leading, TTextAlign.Center, False);

  if (FUnderline = dluAlways) or Hot or IsFocused then
  begin
    LLineY := LTop + LTextH - 2;
    FillRound(RectF(LLeft, LLineY, LRight - 2, LLineY + 1), 0, AColors.Text);
  end;
  if IsFocused then
    DrawItemFocus(RectF(LLeft, LTop, LRight - 2, LTop + LTextH), 2);
end;

end.
