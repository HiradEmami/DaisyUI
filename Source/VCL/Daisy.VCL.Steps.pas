unit Daisy.VCL.Steps;

{
  TDaisySteps - the DaisyUI "steps": a row (or column) of numbered circles joined by a line that is
  coloured up to the active step. A step can show its own text or icon in the circle and take its
  own colour. A horizontal row wider than the control scrolls with the mouse wheel, and it can
  switch to a vertical layout below a given width (BreakWidth).
}

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  System.SysUtils, System.Classes, System.Types, System.UITypes, System.Math,
  Vcl.Controls, Daisy.Theme, Daisy.Navigation, Daisy.VCL.Control;

type
  TDaisySteps = class(TDaisyControl)
  strict private
    var
      FItems: TDaisyStepItems;
      FOrientation: TDaisyStepsOrientation;
      FActiveStep: Integer;
      FActiveVariant: TDaisyVariant;
      FBreakWidth: Integer;
      FScroll: Integer;
    procedure SetItems(const Value: TDaisyStepItems);
    procedure SetOrientation(const Value: TDaisyStepsOrientation);
    procedure SetActiveStep(const Value: Integer);
    procedure SetActiveVariant(const Value: TDaisyVariant);
    procedure SetBreakWidth(const Value: Integer);
    procedure ItemsChanged(Sender: TObject);
    function EffectiveOrientation: TDaisyStepsOrientation;
    function ColumnWidth: Integer;
    function RowHeight: Integer;
    function ContentLength: Integer;
    function StepFill(AIndex: Integer): TAlphaColor;
    function StepText(AIndex: Integer): TAlphaColor;
    function CircleRect(AIndex: Integer): TRect;
  protected
    function DrawsFocusRing: Boolean; override;
    function DefaultCornerRadius: Integer; override;
    function DefaultShadowSize: Integer; override;
    function DefaultContentPadding: Integer; override;
    function DefaultStyleColors(AState: TDaisyState): TDaisyColors; override;
    procedure Resize; override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
    procedure DrawContent(const AColors: TDaisyColors; const ARect: TRect); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Items: TDaisyStepItems read FItems write SetItems;
    property Orientation: TDaisyStepsOrientation read FOrientation write SetOrientation
      default dsoHorizontal;
    // Steps up to and including this index are coloured with ActiveVariant (-1: none)
    property ActiveStep: Integer read FActiveStep write SetActiveStep default 1;
    property ActiveVariant: TDaisyVariant read FActiveVariant write SetActiveVariant
      default dvPrimary;
    // A horizontal row becomes vertical while the control is narrower than this (0: never)
    property BreakWidth: Integer read FBreakWidth write SetBreakWidth default 0;
  end;

implementation

const
  CMinColumn = 80;
  CMinRow = 64;
  CLabelGap = 8;

{ TDaisySteps }

constructor TDaisySteps.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOrientation := dsoHorizontal;
  FActiveStep := 1;
  FActiveVariant := dvPrimary;
  FItems := TDaisyStepItems.Create(Self);
  FItems.OnChange := ItemsChanged;
  FItems.Add.Caption := 'Register';
  FItems.Add.Caption := 'Choose plan';
  FItems.Add.Caption := 'Purchase';
  SetBounds(Left, Top, 360, 64);
end;

destructor TDaisySteps.Destroy;
begin
  FItems.OnChange := nil;
  FItems.Free;
  inherited Destroy;
end;

function TDaisySteps.DrawsFocusRing: Boolean;
begin
  Result := False;
end;

function TDaisySteps.DefaultCornerRadius: Integer;
begin
  Result := 0;
end;

function TDaisySteps.DefaultShadowSize: Integer;
begin
  Result := 0;
end;

function TDaisySteps.DefaultContentPadding: Integer;
begin
  Result := 0;
end;

function TDaisySteps.DefaultStyleColors(AState: TDaisyState): TDaisyColors;
begin
  Result := Default(TDaisyColors);
  Result.Text := Theme.BaseContent;
end;

procedure TDaisySteps.SetItems(const Value: TDaisyStepItems);
begin
  FItems.Assign(Value);
end;

procedure TDaisySteps.SetOrientation(const Value: TDaisyStepsOrientation);
begin
  if FOrientation <> Value then
  begin
    FOrientation := Value;
    FScroll := 0;
    Invalidate;
  end;
end;

procedure TDaisySteps.SetActiveStep(const Value: Integer);
begin
  if FActiveStep <> Value then
  begin
    FActiveStep := Value;
    Invalidate;
  end;
end;

procedure TDaisySteps.SetActiveVariant(const Value: TDaisyVariant);
begin
  if FActiveVariant <> Value then
  begin
    FActiveVariant := Value;
    Invalidate;
  end;
end;

procedure TDaisySteps.SetBreakWidth(const Value: Integer);
begin
  if FBreakWidth <> Max(0, Value) then
  begin
    FBreakWidth := Max(0, Value);
    Invalidate;
  end;
end;

procedure TDaisySteps.ItemsChanged(Sender: TObject);
begin
  Invalidate;
end;

function TDaisySteps.EffectiveOrientation: TDaisyStepsOrientation;
begin
  Result := FOrientation;
  if (FOrientation = dsoHorizontal) and (FBreakWidth > 0) and (Width < ScaleValue(FBreakWidth)) then
    Result := dsoVertical;
end;

function TDaisySteps.ColumnWidth: Integer;
var
  I, LWidest: Integer;
begin
  LWidest := 0;
  for I := 0 to FItems.Count - 1 do
    LWidest := Max(LWidest, MeasureTextWidth(FItems[I].Caption, DaisyFontSize(SizeKind), False));
  Result := Max(ScaleValue(CMinColumn), LWidest + ScaleValue(16));
  if FItems.Count > 0 then
    Result := Max(Result, Width div FItems.Count);
end;

function TDaisySteps.RowHeight: Integer;
begin
  Result := ScaleValue(CMinRow);
  Result := Max(Result, ScaleValue(DaisyStepCircle(SizeKind)) + ScaleValue(CLabelGap));
  if FItems.Count > 0 then
    Result := Max(Result, Height div FItems.Count);
end;

function TDaisySteps.ContentLength: Integer;
begin
  if EffectiveOrientation = dsoHorizontal then
    Result := ColumnWidth * FItems.Count
  else
    Result := RowHeight * FItems.Count;
end;

function TDaisySteps.StepFill(AIndex: Integer): TAlphaColor;
var
  LVariant: TDaisyVariant;
begin
  LVariant := FItems[AIndex].Variant;
  if (LVariant = dvDefault) and (AIndex <= FActiveStep) then
    LVariant := FActiveVariant;
  if LVariant = dvDefault then
    if AIndex <= FActiveStep then
      Result := Theme.Neutral
    else
      Result := Theme.Base300
  else
    Result := DaisyVariantPalette(Theme, LVariant).Fill;
end;

function TDaisySteps.StepText(AIndex: Integer): TAlphaColor;
var
  LVariant: TDaisyVariant;
begin
  LVariant := FItems[AIndex].Variant;
  if (LVariant = dvDefault) and (AIndex <= FActiveStep) then
    LVariant := FActiveVariant;
  if LVariant = dvDefault then
    if AIndex <= FActiveStep then
      Result := DaisyVariantPalette(Theme, dvNeutral).Content
    else
      Result := Theme.BaseContent
  else
    Result := DaisyVariantPalette(Theme, LVariant).Content;
end;

function TDaisySteps.CircleRect(AIndex: Integer): TRect;
var
  LCircle, LCenter: Integer;
begin
  LCircle := ScaleValue(DaisyStepCircle(SizeKind));
  if EffectiveOrientation = dsoHorizontal then
  begin
    LCenter := AIndex * ColumnWidth + ColumnWidth div 2 - FScroll;
    Result := Rect(LCenter - LCircle div 2, 0, LCenter - LCircle div 2 + LCircle, LCircle);
  end
  else
  begin
    LCenter := AIndex * RowHeight + LCircle div 2;
    Result := Rect(0, LCenter - LCircle div 2, LCircle, LCenter - LCircle div 2 + LCircle);
  end;
end;

procedure TDaisySteps.Resize;
var
  LView: Integer;
begin
  inherited;
  if EffectiveOrientation = dsoHorizontal then
    LView := Width
  else
    LView := Height;
  FScroll := Round(DaisyClampScroll(FScroll, ContentLength, LView));
end;

function TDaisySteps.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
var
  LOld: Integer;
begin
  LOld := FScroll;
  if EffectiveOrientation = dsoHorizontal then
    FScroll := Round(DaisyClampScroll(FScroll - Sign(WheelDelta) * ScaleValue(CMinColumn) div 2,
      ContentLength, Width));
  Result := FScroll <> LOld;
  if Result then
    Invalidate
  else
    Result := inherited DoMouseWheel(Shift, WheelDelta, MousePos);
end;

procedure TDaisySteps.DrawContent(const AColors: TDaisyColors; const ARect: TRect);
var
  LGraphics: TGPGraphics;
  LCircle, LLine, LFont, LStep, I, LOffset: Integer;
  LCurrent, LPrevious: TRect;
  LLabelRect: TRect;
  LHorizontal: Boolean;
  LText: string;
begin
  if FItems.Count = 0 then
    Exit;
  LHorizontal := EffectiveOrientation = dsoHorizontal;
  LCircle := ScaleValue(DaisyStepCircle(SizeKind));
  LLine := ScaleValue(DaisyStepLine(SizeKind));
  LFont := DaisyFontSize(SizeKind);
  if LHorizontal then
    LStep := ColumnWidth
  else
    LStep := RowHeight;

  LGraphics := NewGraphics;
  try
    // lines first, so that the circles sit on top of them
    for I := 1 to FItems.Count - 1 do
    begin
      LPrevious := CircleRect(I - 1);
      LCurrent := CircleRect(I);
      if LHorizontal then
        FillRoundRect(LGraphics, RectF((LPrevious.Left + LPrevious.Right) / 2,
          (LCurrent.Top + LCurrent.Bottom - LLine) / 2, (LCurrent.Left + LCurrent.Right) / 2,
          (LCurrent.Top + LCurrent.Bottom + LLine) / 2), 0, StepFill(I))
      else
        FillRoundRect(LGraphics, RectF((LCurrent.Left + LCurrent.Right - LLine) / 2,
          (LPrevious.Top + LPrevious.Bottom) / 2, (LCurrent.Left + LCurrent.Right + LLine) / 2,
          (LCurrent.Top + LCurrent.Bottom) / 2), 0, StepFill(I));
    end;
    for I := 0 to FItems.Count - 1 do
    begin
      LCurrent := CircleRect(I);
      FillRoundRect(LGraphics, RectF(LCurrent.Left, LCurrent.Top, LCurrent.Right, LCurrent.Bottom),
        LCircle / 2, StepFill(I));
    end;
  finally
    LGraphics.Free;
  end;

  for I := 0 to FItems.Count - 1 do
  begin
    LCurrent := CircleRect(I);
    if (LHorizontal and ((LCurrent.Right < 0) or (LCurrent.Left > Width))) then
      Continue;
    if not FItems[I].Icon.IsEmpty then
      DrawGlyph(FItems[I].Icon, Rect(LCurrent.Left + LCircle div 4, LCurrent.Top + LCircle div 4,
        LCurrent.Right - LCircle div 4, LCurrent.Bottom - LCircle div 4), StepText(I))
    else
    begin
      if FItems[I].Content <> '' then
        LText := FItems[I].Content
      else
        LText := IntToStr(I + 1);
      DrawText(LText, LCurrent, StepText(I), LFont, False, DT_CENTER or DT_SINGLELINE or DT_VCENTER);
    end;
    if LHorizontal then
    begin
      LOffset := I * LStep - FScroll;
      LLabelRect := Rect(LOffset + ScaleValue(2), LCurrent.Bottom + ScaleValue(CLabelGap),
        LOffset + LStep - ScaleValue(2), Height);
      DrawText(FItems[I].Caption, LLabelRect, AColors.Text, LFont, False,
        DT_CENTER or DT_SINGLELINE or DT_TOP or DT_END_ELLIPSIS);
    end
    else
    begin
      LLabelRect := Rect(LCurrent.Right + ScaleValue(CLabelGap), LCurrent.Top,
        Width, LCurrent.Bottom);
      DrawText(FItems[I].Caption, LLabelRect, AColors.Text, LFont, False,
        DT_LEFT or DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS);
    end;
  end;
end;

end.
