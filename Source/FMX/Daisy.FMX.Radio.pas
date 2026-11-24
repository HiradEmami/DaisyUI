unit Daisy.FMX.Radio;

{
  TDaisyFmxRadio - the DaisyUI "radio". A round box that shows a dot in the Variant colour
  when Checked. SizeKind gives xs..xl and Text puts a caption beside the box.

  Radios that share a Parent and a GroupIndex exclude one another: checking one
  unchecks the others. Use GroupIndex to hold several groups on the same parent.
  The arrow keys move the selection through the group.
}

interface

uses
  System.SysUtils, System.Classes, System.Types, System.UITypes, System.Math,
  System.Actions, FMX.ActnList, FMX.Types, FMX.Controls, FMX.Graphics, Daisy.Theme, Daisy.Widgets,
  Daisy.FMX.Control;

type
  TDaisyFmxRadio = class(TDaisyControl)
  strict private
    FChecked: Boolean;
    FGroupIndex: Integer;
    FAutoFit: Boolean;
    FUpdating: Boolean;
    FText: string;
    FOnChange: TNotifyEvent;
    procedure SetChecked(const Value: Boolean);
    procedure SetAutoFit(const Value: Boolean);
    procedure SetText(const Value: string);
    function BoxSize: Single;
    procedure UpdateSize;
    procedure Changed;
    procedure UncheckGroup;
    procedure SelectSibling(AForward: Boolean);
  protected
    function IsInteractive: Boolean; override;
    function DrawsFocusRing: Boolean; override;
    function DefaultCornerRadius: Integer; override;
    function DefaultContentPadding: Integer; override;
    function DefaultStyleColors(AState: TDaisyState): TDaisyColors; override;
    procedure SizeChanged; override;
    procedure Loaded; override;
    procedure ActionChange(Sender: TBasicAction; CheckDefaults: Boolean); override;
    procedure KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure DrawContent(const AColors: TDaisyColors; const ARect: TRectF); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Click; override;
  published
    property Action;
    property Checked: Boolean read FChecked write SetChecked default False;
    // Radios with the same Parent and GroupIndex are mutually exclusive
    property GroupIndex: Integer read FGroupIndex write FGroupIndex default 0;
    // Text beside the box
    property Text: string read FText write SetText;
    // The size follows SizeKind and Text; when off the control keeps its own size
    property AutoFit: Boolean read FAutoFit write SetAutoFit default True;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

implementation

const
  CBoxSizes: array[TDaisySize] of Integer = (16, 20, 24, 28, 32);
  CMargin = 3;

{ TDaisyFmxRadio }

constructor TDaisyFmxRadio.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAutoFit := True;
  CanFocus := True;
  TabStop := True;
  Cursor := crHandPoint;
  SetBounds(Position.X, Position.Y, 28, 28);
  UpdateSize;
end;

function TDaisyFmxRadio.IsInteractive: Boolean;
begin
  Result := True;
end;

function TDaisyFmxRadio.DrawsFocusRing: Boolean;
begin
  Result := False; // the circle outline shows the focus
end;

function TDaisyFmxRadio.DefaultCornerRadius: Integer;
begin
  Result := 0;
end;

function TDaisyFmxRadio.DefaultContentPadding: Integer;
begin
  Result := 0;
end;

function TDaisyFmxRadio.DefaultStyleColors(AState: TDaisyState): TDaisyColors;
begin
  Result := Default(TDaisyColors);
  Result.Text := Theme.BaseContent;
end;

procedure TDaisyFmxRadio.Changed;
begin
  Repaint;
  if not (csLoading in ComponentState) and Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TDaisyFmxRadio.UncheckGroup;
var
  I: Integer;
  LOther: TDaisyFmxRadio;
begin
  if Parent = nil then
    Exit;
  for I := 0 to Parent.ChildrenCount - 1 do
    if (Parent.Children[I] is TDaisyFmxRadio) and (Parent.Children[I] <> Self) then
    begin
      LOther := TDaisyFmxRadio(Parent.Children[I]);
      if (LOther.FGroupIndex = FGroupIndex) and LOther.FChecked then
        LOther.SetChecked(False);
    end;
end;

procedure TDaisyFmxRadio.SetChecked(const Value: Boolean);
begin
  if FChecked = Value then
    Exit;
  FChecked := Value;
  if FChecked then
    UncheckGroup;
  Changed;
  if ActionClient and (Action is TCustomAction) then
    TCustomAction(Action).Checked := FChecked;
end;

procedure TDaisyFmxRadio.ActionChange(Sender: TBasicAction; CheckDefaults: Boolean);
begin
  inherited ActionChange(Sender, CheckDefaults);
  if Sender is TCustomAction then
  begin
    if (not CheckDefaults) or (FText = '') then
      SetText(TCustomAction(Sender).Text);
    if (not CheckDefaults) or (not FChecked) then
      SetChecked(TCustomAction(Sender).Checked);
  end;
end;

procedure TDaisyFmxRadio.SetAutoFit(const Value: Boolean);
begin
  if FAutoFit <> Value then
  begin
    FAutoFit := Value;
    UpdateSize;
  end;
end;

procedure TDaisyFmxRadio.SetText(const Value: string);
begin
  if FText <> Value then
  begin
    FText := Value;
    UpdateSize;
    Repaint;
  end;
end;

// A radio can only be switched on by the user; the group switches the others off
procedure TDaisyFmxRadio.Click;
begin
  if Enabled then
    SetChecked(True);
  inherited Click;
end;

procedure TDaisyFmxRadio.SelectSibling(AForward: Boolean);
var
  I, LStart, LStep, LCount: Integer;
  LOther: TFmxObject;
begin
  if Parent = nil then
    Exit;
  LCount := Parent.ChildrenCount;
  LStart := -1;
  for I := 0 to LCount - 1 do
    if Parent.Children[I] = Self then
      LStart := I;
  if LStart < 0 then
    Exit;
  if AForward then
    LStep := 1
  else
    LStep := -1;
  I := LStart;
  repeat
    I := (I + LStep + LCount) mod LCount;
    LOther := Parent.Children[I];
    if (LOther is TDaisyFmxRadio) and (TDaisyFmxRadio(LOther).FGroupIndex = FGroupIndex) and
      TDaisyFmxRadio(LOther).Enabled and TDaisyFmxRadio(LOther).Visible then
    begin
      if TDaisyFmxRadio(LOther).CanFocus then
        TDaisyFmxRadio(LOther).SetFocus;
      TDaisyFmxRadio(LOther).Click;
      Exit;
    end;
  until I = LStart;
end;

procedure TDaisyFmxRadio.KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  if ((Key = vkSpace) or (KeyChar = ' ')) and Enabled then
  begin
    Click;
    Key := 0;
    KeyChar := #0;
  end
  else if (Key = vkLeft) or (Key = vkUp) then
  begin
    SelectSibling(False);
    Key := 0;
  end
  else if (Key = vkRight) or (Key = vkDown) then
  begin
    SelectSibling(True);
    Key := 0;
  end
  else
    inherited KeyDown(Key, KeyChar, Shift);
end;

function TDaisyFmxRadio.BoxSize: Single;
begin
  Result := CBoxSizes[SizeKind];
end;

procedure TDaisyFmxRadio.UpdateSize;
var
  LWidth, LHeight: Single;
begin
  if (not FAutoFit) or FUpdating or (csLoading in ComponentState) then
    Exit;
  LHeight := BoxSize + 2 * CMargin;
  LWidth := BoxSize + 2 * CMargin;
  if FText <> '' then
    LWidth := LWidth + 8 + MeasureTextWidth(FText, DaisyFontSize(SizeKind), False) + 2;
  FUpdating := True;
  try
    SetBounds(Position.X, Position.Y, LWidth, LHeight);
  finally
    FUpdating := False;
  end;
end;

procedure TDaisyFmxRadio.SizeChanged;
begin
  UpdateSize;
  Repaint;
end;

procedure TDaisyFmxRadio.Loaded;
begin
  inherited;
  UpdateSize;
end;

procedure TDaisyFmxRadio.DrawContent(const AColors: TDaisyColors; const ARect: TRectF);
var
  LBox, LDot, LText: TRectF;
  LTint, LBorder: TAlphaColor;
  LSize, LFade: Single;
begin
  LSize := BoxSize;
  LBox := RectF(CMargin, (Height - LSize) / 2, CMargin + LSize, (Height - LSize) / 2 + LSize);

  if Variant = dvDefault then
    LTint := Theme.BaseContent
  else
    LTint := DaisyVariantPalette(Theme, Variant).Fill;
  LFade := 1;
  if not Enabled then
    LFade := 0.3;

  if FChecked then
    LBorder := LTint
  else
    LBorder := DaisyMix(Theme.Base100, Theme.BaseContent, 0.35);

  FillRound(LBox, LSize / 2, DaisyWithAlpha(Theme.Base100, LFade));
  StrokeRound(LBox, LSize / 2, DaisyWithAlpha(LBorder, LFade), Max(1, Theme.BorderWidth), False);
  if FChecked then
  begin
    LDot := LBox;
    LDot.Inflate(-LSize * 0.25, -LSize * 0.25);
    FillRound(LDot, LDot.Width / 2, DaisyWithAlpha(LTint, LFade));
  end;
  if IsFocused then
  begin
    LDot := LBox;
    LDot.Inflate(2, 2);
    StrokeRound(LDot, LDot.Width / 2, DaisyWithAlpha(Theme.BaseContent, 0.45 * LFade), 1, False);
  end;

  if FText <> '' then
  begin
    LText := RectF(LBox.Right + 8, 0, Width, Height);
    DrawText(FText, LText, DaisyWithAlpha(Theme.BaseContent, LFade), DaisyFontSize(SizeKind),
      False, TTextAlign.Leading, TTextAlign.Center, False);
  end;
end;

end.
