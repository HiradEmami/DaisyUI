unit Daisy.VCL.Radio;

{
  TDaisyRadio - the DaisyUI "radio". A round box that shows a dot in the Variant colour
  when Checked. SizeKind gives xs..xl and Caption puts text beside the box.

  Radios that share a Parent and a GroupIndex exclude one another: checking one
  unchecks the others. Use GroupIndex to hold several groups on the same parent.
  The arrow keys move the selection through the group.
}

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  System.SysUtils, System.Classes, System.Types, System.UITypes, System.Math,
  Vcl.Controls, Vcl.ActnList, Daisy.Theme, Daisy.Widgets, Daisy.VCL.Control;

type
  TDaisyRadio = class(TDaisyControl)
  strict private
    FChecked: Boolean;
    FGroupIndex: Integer;
    FAutoFit: Boolean;
    FUpdating: Boolean;
    FOnChange: TNotifyEvent;
    procedure SetChecked(const Value: Boolean);
    procedure SetAutoFit(const Value: Boolean);
    function GetCaption: string;
    procedure SetCaption(const Value: string);
    function BoxSize: Integer;
    function Margin: Integer;
    procedure UpdateSize;
    procedure Changed;
    procedure UncheckGroup;
    procedure SelectSibling(AForward: Boolean);
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
  protected
    function IsInteractive: Boolean; override;
    function DrawsFocusRing: Boolean; override;
    function DefaultCornerRadius: Integer; override;
    function DefaultContentPadding: Integer; override;
    function DefaultStyleColors(AState: TDaisyState): TDaisyColors; override;
    procedure SizeChanged; override;
    procedure Loaded; override;
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DrawContent(const AColors: TDaisyColors; const ARect: TRect); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Click; override;
  published
    property Action;
    property Checked: Boolean read FChecked write SetChecked default False;
    // Radios with the same Parent and GroupIndex are mutually exclusive
    property GroupIndex: Integer read FGroupIndex write FGroupIndex default 0;
    // Text beside the box
    property Caption: string read GetCaption write SetCaption;
    // The size follows SizeKind and Caption; when off the control keeps its own size
    property AutoFit: Boolean read FAutoFit write SetAutoFit default True;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

implementation

const
  CBoxSizes: array[TDaisySize] of Integer = (16, 20, 24, 28, 32);

{ TDaisyRadio }

constructor TDaisyRadio.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAutoFit := True;
  TabStop := True;
  Cursor := crHandPoint;
  SetBounds(Left, Top, 28, 28);
  UpdateSize;
end;

function TDaisyRadio.IsInteractive: Boolean;
begin
  Result := True;
end;

function TDaisyRadio.DrawsFocusRing: Boolean;
begin
  Result := False; // the circle outline shows the focus
end;

function TDaisyRadio.DefaultCornerRadius: Integer;
begin
  Result := 0;
end;

function TDaisyRadio.DefaultContentPadding: Integer;
begin
  Result := 0;
end;

function TDaisyRadio.DefaultStyleColors(AState: TDaisyState): TDaisyColors;
begin
  Result := Default(TDaisyColors);
  Result.Text := Theme.BaseContent;
end;

function TDaisyRadio.GetCaption: string;
begin
  Result := inherited Caption;
end;

procedure TDaisyRadio.SetCaption(const Value: string);
begin
  inherited Caption := Value;
end;

procedure TDaisyRadio.CMTextChanged(var Message: TMessage);
begin
  inherited;
  UpdateSize;
  Invalidate;
end;

procedure TDaisyRadio.CMFontChanged(var Message: TMessage);
begin
  inherited;
  UpdateSize;
end;

procedure TDaisyRadio.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  Message.Result := Message.Result or DLGC_WANTARROWS;
end;

procedure TDaisyRadio.Changed;
begin
  Invalidate;
  if not (csLoading in ComponentState) and Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TDaisyRadio.UncheckGroup;
var
  I: Integer;
  LOther: TDaisyRadio;
begin
  if Parent = nil then
    Exit;
  for I := 0 to Parent.ControlCount - 1 do
    if (Parent.Controls[I] is TDaisyRadio) and (Parent.Controls[I] <> Self) then
    begin
      LOther := TDaisyRadio(Parent.Controls[I]);
      if (LOther.FGroupIndex = FGroupIndex) and LOther.FChecked then
        LOther.SetChecked(False);
    end;
end;

procedure TDaisyRadio.SetChecked(const Value: Boolean);
begin
  if FChecked = Value then
    Exit;
  FChecked := Value;
  if FChecked then
    UncheckGroup;
  Changed;
  if (Action is TCustomAction) and (TCustomAction(Action).Checked <> FChecked) then
    TCustomAction(Action).Checked := FChecked;
end;

procedure TDaisyRadio.ActionChange(Sender: TObject; CheckDefaults: Boolean);
begin
  inherited ActionChange(Sender, CheckDefaults);
  if (Sender is TCustomAction) and ((not CheckDefaults) or (not FChecked)) then
    SetChecked(TCustomAction(Sender).Checked);
end;

procedure TDaisyRadio.SetAutoFit(const Value: Boolean);
begin
  if FAutoFit <> Value then
  begin
    FAutoFit := Value;
    UpdateSize;
  end;
end;

// A radio can only be switched on by the user; the group switches the others off
procedure TDaisyRadio.Click;
begin
  if Enabled then
    SetChecked(True);
  inherited Click;
end;

procedure TDaisyRadio.SelectSibling(AForward: Boolean);
var
  I, LStart, LStep, LCount: Integer;
  LOther: TControl;
begin
  if Parent = nil then
    Exit;
  LCount := Parent.ControlCount;
  LStart := -1;
  for I := 0 to LCount - 1 do
    if Parent.Controls[I] = Self then
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
    LOther := Parent.Controls[I];
    if (LOther is TDaisyRadio) and (TDaisyRadio(LOther).FGroupIndex = FGroupIndex) and
      LOther.Enabled and LOther.Visible then
    begin
      if TDaisyRadio(LOther).CanFocus then
        TDaisyRadio(LOther).SetFocus;
      TDaisyRadio(LOther).Click;
      Exit;
    end;
  until I = LStart;
end;

procedure TDaisyRadio.KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_SPACE:
      if Enabled then
      begin
        Click;
        Key := 0;
      end;
    VK_LEFT, VK_UP:
      begin
        SelectSibling(False);
        Key := 0;
      end;
    VK_RIGHT, VK_DOWN:
      begin
        SelectSibling(True);
        Key := 0;
      end;
  else
    inherited KeyDown(Key, Shift);
  end;
end;

function TDaisyRadio.BoxSize: Integer;
begin
  Result := ScaleValue(CBoxSizes[SizeKind]);
end;

function TDaisyRadio.Margin: Integer;
begin
  Result := ScaleValue(3);
end;

procedure TDaisyRadio.UpdateSize;
var
  LWidth, LHeight: Integer;
begin
  if (not FAutoFit) or FUpdating or (csLoading in ComponentState) then
    Exit;
  LHeight := BoxSize + 2 * Margin;
  LWidth := BoxSize + 2 * Margin;
  if Caption <> '' then
    Inc(LWidth, ScaleValue(8) + MeasureTextWidth(Caption, DaisyFontSize(SizeKind), False) + ScaleValue(2));
  FUpdating := True;
  try
    SetBounds(Left, Top, LWidth, LHeight);
  finally
    FUpdating := False;
  end;
end;

procedure TDaisyRadio.SizeChanged;
begin
  UpdateSize;
end;

procedure TDaisyRadio.Loaded;
begin
  inherited;
  UpdateSize;
end;

procedure TDaisyRadio.DrawContent(const AColors: TDaisyColors; const ARect: TRect);
var
  LGraphics: TGPGraphics;
  LBox, LDot: TRectF;
  LTint, LBorder: TAlphaColor;
  LPalette: TDaisyPalette;
  LSize, LFade: Single;
  LText: TRect;
begin
  LSize := BoxSize;
  LBox := RectF(Margin, (ClientHeight - LSize) / 2, Margin + LSize, (ClientHeight - LSize) / 2 + LSize);

  if Variant = dvDefault then
    LTint := Theme.BaseContent
  else
  begin
    LPalette := DaisyVariantPalette(Theme, Variant);
    LTint := LPalette.Fill;
  end;
  LFade := 1;
  if not Enabled then
    LFade := 0.3;

  if FChecked then
    LBorder := LTint
  else
    LBorder := DaisyMix(Theme.Base100, Theme.BaseContent, 0.35);

  LGraphics := NewGraphics;
  try
    FillRoundRect(LGraphics, LBox, LSize / 2, DaisyWithAlpha(Theme.Base100, LFade));
    StrokeRoundRect(LGraphics, LBox, LSize / 2, DaisyWithAlpha(LBorder, LFade),
      Max(1, ScaleValue(Theme.BorderWidth)), False);
    if FChecked then
    begin
      LDot := LBox;
      LDot.Inflate(-LSize * 0.25, -LSize * 0.25);
      FillRoundRect(LGraphics, LDot, LDot.Width / 2, DaisyWithAlpha(LTint, LFade));
    end;
    if Focused then
    begin
      LDot := LBox;
      LDot.Inflate(ScaleValue(2), ScaleValue(2));
      StrokeRoundRect(LGraphics, LDot, LDot.Width / 2, DaisyWithAlpha(Theme.BaseContent, 0.45 * LFade),
        ScaleValue(1), False);
    end;
  finally
    LGraphics.Free;
  end;

  if Caption <> '' then
  begin
    LText := Rect(Round(LBox.Right) + ScaleValue(8), 0, ClientWidth, ClientHeight);
    DrawRichText(Caption, LText, DaisyWithAlpha(Theme.BaseContent, LFade), DaisyFontSize(SizeKind),
      False, DT_LEFT or DT_VCENTER or DT_SINGLELINE);
  end;
end;

end.
