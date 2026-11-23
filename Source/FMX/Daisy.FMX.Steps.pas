unit Daisy.FMX.Steps;

{
  TDaisyFmxSteps - the DaisyUI "steps": a row (or column) of numbered circles joined by a line that is
  coloured up to the active step. A step can show its own text or icon in the circle and take its
  own colour. A horizontal row wider than the control scrolls with the mouse wheel, and it can
  switch to a vertical layout below a given width (BreakWidth).
}

interface

uses
  System.SysUtils, System.Classes, System.Types, System.UITypes, System.Math,
  FMX.Types, FMX.Controls, FMX.Graphics, Daisy.Theme, Daisy.Navigation, Daisy.FMX.Control;

type
  TDaisyFmxSteps = class(TDaisyControl)
  strict private
    var
      FItems: TDaisyStepItems;
      FOrientation: TDaisyStepsOrientation;
      FActiveStep: Integer;
      FActiveVariant: TDaisyVariant;
      FBreakWidth: Integer;
      FScroll: Single;
    procedure SetItems(const Value: TDaisyStepItems);
    procedure SetOrientation(const Value: TDaisyStepsOrientation);
    procedure SetActiveStep(const Value: Integer);
    procedure SetActiveVariant(const Value: TDaisyVariant);
    procedure SetBreakWidth(const Value: Integer);
    procedure ItemsChanged(Sender: TObject);
    function EffectiveOrientation: TDaisyStepsOrientation;
    function ColumnWidth: Single;
    function RowHeight: Single;
    function ContentLength: Single;
    function StepFill(AIndex: Integer): TAlphaColor;
    function StepText(AIndex: Integer): TAlphaColor;
    function CircleRect(AIndex: Integer): TRectF;
  protected
    function DrawsFocusRing: Boolean; override;
    function DefaultCornerRadius: Integer; override;
    function DefaultShadowSize: Integer; override;
    function DefaultContentPadding: Integer; override;
    function DefaultStyleColors(AState: TDaisyState): TDaisyColors; override;
    procedure Resize; override;
    procedure MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean); override;
    procedure DrawContent(const AColors: TDaisyColors; const ARect: TRectF); override;
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

{ TDaisyFmxSteps }

constructor TDaisyFmxSteps.Create(AOwner: TComponent);
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
  SetBounds(Position.X, Position.Y, 360, 64);
end;

destructor TDaisyFmxSteps.Destroy;
begin
  FItems.OnChange := nil;
  FItems.Free;
  inherited Destroy;
end;

function TDaisyFmxSteps.DrawsFocusRing: Boolean;
begin
  Result := False;
end;

function TDaisyFmxSteps.DefaultCornerRadius: Integer;
begin
  Result := 0;
end;

function TDaisyFmxSteps.DefaultShadowSize: Integer;
begin
  Result := 0;
end;

function TDaisyFmxSteps.DefaultContentPadding: Integer;
begin
  Result := 0;
end;

function TDaisyFmxSteps.DefaultStyleColors(AState: TDaisyState): TDaisyColors;
begin
  Result := Default(TDaisyColors);
  Result.Text := Theme.BaseContent;
end;

procedure TDaisyFmxSteps.SetItems(const Value: TDaisyStepItems);
begin
  FItems.Assign(Value);
end;

procedure TDaisyFmxSteps.SetOrientation(const Value: TDaisyStepsOrientation);
begin
  if FOrientation <> Value then
  begin
    FOrientation := Value;
    FScroll := 0;
    Repaint;
  end;
end;

procedure TDaisyFmxSteps.SetActiveStep(const Value: Integer);
begin
  if FActiveStep <> Value then
  begin
    FActiveStep := Value;
    Repaint;
  end;
end;

procedure TDaisyFmxSteps.SetActiveVariant(const Value: TDaisyVariant);
begin
  if FActiveVariant <> Value then
  begin
    FActiveVariant := Value;
    Repaint;
  end;
end;

procedure TDaisyFmxSteps.SetBreakWidth(const Value: Integer);
begin
  if FBreakWidth <> System.Math.Max(0, Value) then
  begin
    FBreakWidth := System.Math.Max(0, Value);
    Repaint;
  end;
end;

procedure TDaisyFmxSteps.ItemsChanged(Sender: TObject);
begin
  Repaint;
end;

function TDaisyFmxSteps.EffectiveOrientation: TDaisyStepsOrientation;
begin
  Result := FOrientation;
  if (FOrientation = dsoHorizontal) and (FBreakWidth > 0) and (Width < FBreakWidth) then
    Result := dsoVertical;
end;

function TDaisyFmxSteps.ColumnWidth: Single;
var
  I: Integer;
  LWidest: Single;
begin
  LWidest := 0;
  for I := 0 to FItems.Count - 1 do
    LWidest := System.Math.Max(LWidest,
      MeasureTextWidth(FItems[I].Caption, DaisyFontSize(SizeKind), False));
  Result := System.Math.Max(CMinColumn, LWidest + 16);
  if FItems.Count > 0 then
    Result := System.Math.Max(Result, Width / FItems.Count);
end;

function TDaisyFmxSteps.RowHeight: Single;
begin
  Result := System.Math.Max(CMinRow, DaisyStepCircle(SizeKind) + CLabelGap);
  if FItems.Count > 0 then
    Result := System.Math.Max(Result, Height / FItems.Count);
end;

function TDaisyFmxSteps.ContentLength: Single;
begin
  if EffectiveOrientation = dsoHorizontal then
    Result := ColumnWidth * FItems.Count
  else
    Result := RowHeight * FItems.Count;
end;

function TDaisyFmxSteps.StepFill(AIndex: Integer): TAlphaColor;
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

function TDaisyFmxSteps.StepText(AIndex: Integer): TAlphaColor;
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

function TDaisyFmxSteps.CircleRect(AIndex: Integer): TRectF;
var
  LCircle, LCenter: Single;
begin
  LCircle := DaisyStepCircle(SizeKind);
  if EffectiveOrientation = dsoHorizontal then
  begin
    LCenter := AIndex * ColumnWidth + ColumnWidth / 2 - FScroll;
    Result := RectF(LCenter - LCircle / 2, 0, LCenter + LCircle / 2, LCircle);
  end
  else
  begin
    LCenter := AIndex * RowHeight + LCircle / 2;
    Result := RectF(0, LCenter - LCircle / 2, LCircle, LCenter + LCircle / 2);
  end;
end;

procedure TDaisyFmxSteps.Resize;
var
  LView: Single;
begin
  inherited;
  if EffectiveOrientation = dsoHorizontal then
    LView := Width
  else
    LView := Height;
  FScroll := DaisyClampScroll(FScroll, ContentLength, LView);
end;

procedure TDaisyFmxSteps.MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
var
  LOld: Single;
begin
  LOld := FScroll;
  if EffectiveOrientation = dsoHorizontal then
    FScroll := DaisyClampScroll(FScroll - Sign(WheelDelta) * CMinColumn / 2, ContentLength, Width);
  if not SameValue(FScroll, LOld) then
  begin
    Handled := True;
    Repaint;
  end
  else
    inherited MouseWheel(Shift, WheelDelta, Handled);
end;

procedure TDaisyFmxSteps.DrawContent(const AColors: TDaisyColors; const ARect: TRectF);
var
  LCircle, LLine, LStep, LOffset: Single;
  LFont, I: Integer;
  LCurrent, LPrevious, LLabelRect: TRectF;
  LHorizontal: Boolean;
  LText: string;
begin
  if FItems.Count = 0 then
    Exit;
  LHorizontal := EffectiveOrientation = dsoHorizontal;
  LCircle := DaisyStepCircle(SizeKind);
  LLine := DaisyStepLine(SizeKind);
  LFont := DaisyFontSize(SizeKind);
  if LHorizontal then
    LStep := ColumnWidth
  else
    LStep := RowHeight;

  // lines first, so that the circles sit on top of them
  for I := 1 to FItems.Count - 1 do
  begin
    LPrevious := CircleRect(I - 1);
    LCurrent := CircleRect(I);
    if LHorizontal then
      FillRound(RectF((LPrevious.Left + LPrevious.Right) / 2, (LCurrent.Top + LCurrent.Bottom - LLine) / 2,
        (LCurrent.Left + LCurrent.Right) / 2, (LCurrent.Top + LCurrent.Bottom + LLine) / 2), 0,
        StepFill(I))
    else
      FillRound(RectF((LCurrent.Left + LCurrent.Right - LLine) / 2, (LPrevious.Top + LPrevious.Bottom) / 2,
        (LCurrent.Left + LCurrent.Right + LLine) / 2, (LCurrent.Top + LCurrent.Bottom) / 2), 0,
        StepFill(I));
  end;
  for I := 0 to FItems.Count - 1 do
    FillRound(CircleRect(I), LCircle / 2, StepFill(I));

  for I := 0 to FItems.Count - 1 do
  begin
    LCurrent := CircleRect(I);
    if LHorizontal and ((LCurrent.Right < 0) or (LCurrent.Left > Width)) then
      Continue;
    if not FItems[I].Icon.IsEmpty then
      DrawGlyph(FItems[I].Icon, RectF(LCurrent.Left + LCircle / 4, LCurrent.Top + LCircle / 4,
        LCurrent.Right - LCircle / 4, LCurrent.Bottom - LCircle / 4), StepText(I))
    else
    begin
      if FItems[I].Content <> '' then
        LText := FItems[I].Content
      else
        LText := IntToStr(I + 1);
      DrawText(LText, LCurrent, StepText(I), LFont, False, TTextAlign.Center, TTextAlign.Center,
        False);
    end;
    if LHorizontal then
    begin
      LOffset := I * LStep - FScroll;
      LLabelRect := RectF(LOffset + 2, LCurrent.Bottom + CLabelGap, LOffset + LStep - 2, Height);
      DrawText(FItems[I].Caption, LLabelRect, AColors.Text, LFont, False, TTextAlign.Center,
        TTextAlign.Leading, False);
    end
    else
    begin
      LLabelRect := RectF(LCurrent.Right + CLabelGap, LCurrent.Top, Width, LCurrent.Bottom);
      DrawText(FItems[I].Caption, LLabelRect, AColors.Text, LFont, False, TTextAlign.Leading,
        TTextAlign.Center, False);
    end;
  end;
end;

end.
