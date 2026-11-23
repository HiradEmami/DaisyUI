unit Daisy.FMX.Dock;

{
  TDaisyFmxDock - the DaisyUI "dock": a bar of icon + label buttons fixed to an edge of the screen.
  Unlike the web component it can sit at the bottom, top, left or right, and its items are either
  spread evenly along the whole bar (dspEven) or packed from the start with IconSpacing between
  them (dspNormal). The items flow in the DirectionFlow, and a left / right dock can be
  collapsed to a thin strip holding just the expand button.
}

interface

uses
  System.SysUtils, System.Classes, System.Types, System.UITypes, System.Math,
  FMX.Types, FMX.Controls, FMX.Graphics, Daisy.Theme, Daisy.Navigation, Daisy.FMX.Control;

type
  TDaisyFmxDock = class(TDaisyControl)
  strict private
    var
      FItems: TDaisyDockItems;
      FPlacement: TDaisyDockPlacement;
      FSpacing: TDaisyDockSpacing;
      FIconSpacing: Integer;
      FDirectionFlow: TDaisyDockFlow;
      FShowExpandCollapse: Boolean;
      FCollapsed: Boolean;
      FExpandedSize: Single;
      FShowLabels: Boolean;
      FAutoThickness: Boolean;
      FItemIndex: Integer;
      FUpdating: Boolean;
      FOnChange: TNotifyEvent;
      FOnCollapsedChange: TNotifyEvent;
      FOnItemClick: TDaisyItemClickEvent;
    procedure SetItems(const Value: TDaisyDockItems);
    procedure SetPlacement(const Value: TDaisyDockPlacement);
    procedure SetSpacing(const Value: TDaisyDockSpacing);
    procedure SetIconSpacing(const Value: Integer);
    procedure SetDirectionFlow(const Value: TDaisyDockFlow);
    procedure SetShowExpandCollapse(const Value: Boolean);
    procedure SetCollapsed(const Value: Boolean);
    procedure SetShowLabels(const Value: Boolean);
    procedure SetAutoThickness(const Value: Boolean);
    procedure SetItemIndex(const Value: Integer);
    procedure ItemsChanged(Sender: TObject);
    function IsVertical: Boolean;
    function Thickness: Single;
    function ItemRect(AIndex: Integer): TRectF;
    function ItemSlots: TArray<TDaisyDockSlot>;
    function ItemEnabled(AIndex: Integer): Boolean;
    function OuterOnLeft: Boolean;
    function IsCollapsed: Boolean;
    function ToggleVisible: Boolean;
    function ToggleRect: TRectF;
    function CanResize(AWidth: Boolean): Boolean;
    procedure DrawItems(const AColors: TDaisyColors);
    procedure DrawToggle(const AColors: TDaisyColors);
    procedure UpdateThickness;
    procedure ActivateItem(AIndex: Integer);
    procedure MoveSelection(ADelta: Integer);
  protected
    function IsInteractive: Boolean; override;
    function DrawsFocusRing: Boolean; override;
    function DefaultCornerRadius: Integer; override;
    function DefaultShadowSize: Integer; override;
    function DefaultContentPadding: Integer; override;
    function DefaultStyleColors(AState: TDaisyState): TDaisyColors; override;
    function TrackedItemAt(const APoint: TPointF): Integer; override;
    procedure TrackedItemChanged; override;
    procedure SizeChanged; override;
    procedure Resize; override;
    procedure Loaded; override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure DrawContent(const AColors: TDaisyColors; const ARect: TRectF); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Items: TDaisyDockItems read FItems write SetItems;
    property ItemIndex: Integer read FItemIndex write SetItemIndex default 0;
    // The edge the dock belongs to. When Align is already one of the edges it follows
    property Placement: TDaisyDockPlacement read FPlacement write SetPlacement default ddpBottom;
    // dspEven spreads the items along the whole bar, dspNormal packs them from the start
    property Spacing: TDaisyDockSpacing read FSpacing write SetSpacing default dspEven;
    // The gap between the items when Spacing = dspNormal
    property IconSpacing: Integer read FIconSpacing write SetIconSpacing default 4;
    // The direction the items flow in: difTopToBottom / difBottomToTop for a left or right dock,
    // difLeftToRight / difRightToLeft for a top or bottom dock
    property DirectionFlow: TDaisyDockFlow read FDirectionFlow write SetDirectionFlow
      default difLeftToRight;
    // Left / right docks only: shows the < > button that collapses and expands the dock
    property ShowExpandCollapse: Boolean read FShowExpandCollapse write SetShowExpandCollapse
      default True;
    // Left / right docks only: True shrinks the dock to a thin strip holding just the expand button
    property Collapsed: Boolean read FCollapsed write SetCollapsed default False;
    property ShowLabels: Boolean read FShowLabels write SetShowLabels default True;
    // The thickness of the bar (its height, or its width when docked left/right) follows SizeKind
    property AutoThickness: Boolean read FAutoThickness write SetAutoThickness default True;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnCollapsedChange: TNotifyEvent read FOnCollapsedChange write FOnCollapsedChange;
    property OnItemClick: TDaisyItemClickEvent read FOnItemClick write FOnItemClick;
  end;

implementation

const
  CNormalGap = 4;
  CEdgePadding = 8;
  CBarLength = 24;
  CBarThickness = 2;
  CInactiveOpacity = 0.6;
  CToggleSize = 16;
  CToggleMargin = 4;
  // TrackedItem value while the mouse is over the collapse / expand button
  CToggleItem = -2;

{ TDaisyFmxDock }

constructor TDaisyFmxDock.Create(AOwner: TComponent);
var
  LNames: array[0..2] of string;
  I: Integer;
begin
  inherited Create(AOwner);
  FPlacement := ddpBottom;
  FSpacing := dspEven;
  FIconSpacing := CNormalGap;
  FDirectionFlow := difLeftToRight;
  FShowExpandCollapse := True;
  FShowLabels := True;
  FAutoThickness := True;
  FItemIndex := 0;
  FItems := TDaisyDockItems.Create(Self);
  FItems.OnChange := ItemsChanged;
  LNames[0] := 'Home';
  LNames[1] := 'Inbox';
  LNames[2] := 'Settings';
  for I := 0 to High(LNames) do
    FItems.Add.Caption := LNames[I];
  CanFocus := True;
  TabStop := True;
  SetBounds(Position.X, Position.Y, 320, DaisyDockThickness(SizeKind));
end;

destructor TDaisyFmxDock.Destroy;
begin
  FItems.OnChange := nil;
  FItems.Free;
  inherited Destroy;
end;

function TDaisyFmxDock.IsInteractive: Boolean;
begin
  Result := True;
end;

function TDaisyFmxDock.DrawsFocusRing: Boolean;
begin
  Result := False;
end;

function TDaisyFmxDock.DefaultCornerRadius: Integer;
begin
  Result := 0;
end;

function TDaisyFmxDock.DefaultShadowSize: Integer;
begin
  Result := 0;
end;

function TDaisyFmxDock.DefaultContentPadding: Integer;
begin
  Result := 0;
end;

function TDaisyFmxDock.DefaultStyleColors(AState: TDaisyState): TDaisyColors;
var
  LPalette: TDaisyPalette;
begin
  Result := Default(TDaisyColors);
  if Variant = dvDefault then
  begin
    Result.Background := Theme.Base100;
    Result.Border := Theme.Base300;
    Result.Text := Theme.BaseContent;
  end
  else
  begin
    LPalette := DaisyVariantPalette(Theme, Variant);
    Result.Background := LPalette.Fill;
    Result.Border := LPalette.Fill;
    Result.Text := LPalette.Content;
  end;
end;

function TDaisyFmxDock.IsVertical: Boolean;
begin
  Result := FPlacement in [ddpLeft, ddpRight];
end;

function TDaisyFmxDock.OuterOnLeft: Boolean;
begin
  // Logical coordinates are mirrored in RTL, so the physical left edge is the logical right one
  Result := (FPlacement = ddpLeft) <> IsRTL;
end;

function TDaisyFmxDock.Thickness: Single;
begin
  Result := DaisyDockThickness(SizeKind);
end;

function TDaisyFmxDock.IsCollapsed: Boolean;
begin
  Result := FCollapsed and IsVertical;
end;

function TDaisyFmxDock.ToggleVisible: Boolean;
begin
  Result := FShowExpandCollapse and IsVertical;
end;

function TDaisyFmxDock.ToggleRect: TRectF;
var
  LLeft, LTop: Single;
begin
  // the button sits on the inner edge, at the end the items do not flow from
  if OuterOnLeft then
    LLeft := Width - CToggleSize
  else
    LLeft := 0;
  if DaisyDockFlowReversed(FDirectionFlow) then
    LTop := CToggleMargin
  else
    LTop := Height - CToggleMargin - CToggleSize;
  Result := RectF(LLeft, LTop, LLeft + CToggleSize, LTop + CToggleSize);
end;

// The dimension an Align already dictates is left alone
function TDaisyFmxDock.CanResize(AWidth: Boolean): Boolean;
begin
  if AWidth then
    Result := not (Align in [TAlignLayout.Top, TAlignLayout.Bottom, TAlignLayout.Client,
      TAlignLayout.Contents, TAlignLayout.MostTop, TAlignLayout.MostBottom,
      TAlignLayout.Horizontal, TAlignLayout.Scale, TAlignLayout.Fit, TAlignLayout.FitLeft,
      TAlignLayout.FitRight])
  else
    Result := not (Align in [TAlignLayout.Left, TAlignLayout.Right, TAlignLayout.Client,
      TAlignLayout.Contents, TAlignLayout.MostLeft, TAlignLayout.MostRight,
      TAlignLayout.Vertical, TAlignLayout.Scale, TAlignLayout.Fit, TAlignLayout.FitLeft,
      TAlignLayout.FitRight]);
end;

procedure TDaisyFmxDock.SetItems(const Value: TDaisyDockItems);
begin
  FItems.Assign(Value);
end;

procedure TDaisyFmxDock.SetPlacement(const Value: TDaisyDockPlacement);
begin
  if FPlacement = Value then
    Exit;
  // only a left / right dock can be collapsed
  if FCollapsed and not (Value in [ddpLeft, ddpRight]) then
    SetCollapsed(False);
  FPlacement := Value;
  FDirectionFlow := DaisyDockFlowFor(Value, FDirectionFlow);
  if not (csLoading in ComponentState) then
  begin
    case Align of
      TAlignLayout.Top, TAlignLayout.Bottom, TAlignLayout.Left, TAlignLayout.Right:
        case Value of
          ddpBottom: Align := TAlignLayout.Bottom;
          ddpTop: Align := TAlignLayout.Top;
          ddpLeft: Align := TAlignLayout.Left;
          ddpRight: Align := TAlignLayout.Right;
        end;
    end;
    UpdateThickness;
  end;
  Repaint;
end;

procedure TDaisyFmxDock.SetSpacing(const Value: TDaisyDockSpacing);
begin
  if FSpacing <> Value then
  begin
    FSpacing := Value;
    Repaint;
  end;
end;

procedure TDaisyFmxDock.SetIconSpacing(const Value: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, Value);
  if FIconSpacing <> LValue then
  begin
    FIconSpacing := LValue;
    Repaint;
  end;
end;

procedure TDaisyFmxDock.SetDirectionFlow(const Value: TDaisyDockFlow);
var
  LValue: TDaisyDockFlow;
begin
  LValue := DaisyDockFlowFor(FPlacement, Value);
  if FDirectionFlow <> LValue then
  begin
    FDirectionFlow := LValue;
    Repaint;
  end;
end;

procedure TDaisyFmxDock.SetShowExpandCollapse(const Value: Boolean);
begin
  if FShowExpandCollapse <> Value then
  begin
    FShowExpandCollapse := Value;
    Repaint;
  end;
end;

procedure TDaisyFmxDock.SetCollapsed(const Value: Boolean);
var
  LRight: Single;
begin
  if FCollapsed = Value then
    Exit;
  if csLoading in ComponentState then
  begin
    FCollapsed := Value;
    Exit;
  end;
  // remember a width that does not follow SizeKind so that expanding can restore it
  if Value and IsVertical and not FAutoThickness and (Width > CToggleSize) then
    FExpandedSize := Width;
  LRight := Position.X + Width;
  FCollapsed := Value;
  if IsVertical then
  begin
    if (not Value) and (not FAutoThickness) and (FExpandedSize > 0) and CanResize(True) then
    begin
      FUpdating := True;
      try
        Width := FExpandedSize;
      finally
        FUpdating := False;
      end;
    end;
    UpdateThickness;
    // a free-standing right dock keeps its right edge in place
    if (FPlacement = ddpRight) and (Align = TAlignLayout.None) then
      Position.X := LRight - Width;
  end;
  Repaint;
  if Assigned(FOnCollapsedChange) then
    FOnCollapsedChange(Self);
end;

procedure TDaisyFmxDock.SetShowLabels(const Value: Boolean);
begin
  if FShowLabels <> Value then
  begin
    FShowLabels := Value;
    Repaint;
  end;
end;

procedure TDaisyFmxDock.SetAutoThickness(const Value: Boolean);
begin
  if FAutoThickness <> Value then
  begin
    FAutoThickness := Value;
    UpdateThickness;
  end;
end;

procedure TDaisyFmxDock.SetItemIndex(const Value: Integer);
var
  LValue: Integer;
begin
  LValue := EnsureRange(Value, -1, FItems.Count - 1);
  if FItemIndex <> LValue then
  begin
    FItemIndex := LValue;
    Repaint;
    if Assigned(FOnChange) and not (csLoading in ComponentState) then
      FOnChange(Self);
  end;
end;

procedure TDaisyFmxDock.ItemsChanged(Sender: TObject);
begin
  if FItemIndex > FItems.Count - 1 then
    FItemIndex := FItems.Count - 1;
  Repaint;
end;

procedure TDaisyFmxDock.UpdateThickness;
var
  LThickness: Single;
begin
  if FUpdating or (csLoading in ComponentState) then
    Exit;
  if IsCollapsed then
    LThickness := CToggleSize
  else if FAutoThickness then
    LThickness := Thickness
  else
    Exit;
  FUpdating := True;
  try
    if IsVertical then
    begin
      if not SameValue(Width, LThickness) and CanResize(True) then
        Width := LThickness;
    end
    else if not SameValue(Height, LThickness) and CanResize(False) then
      Height := LThickness;
  finally
    FUpdating := False;
  end;
end;

procedure TDaisyFmxDock.SizeChanged;
begin
  UpdateThickness;
  Repaint;
end;

procedure TDaisyFmxDock.Resize;
begin
  inherited;
  UpdateThickness;
end;

procedure TDaisyFmxDock.Loaded;
begin
  inherited;
  FItemIndex := EnsureRange(FItemIndex, -1, FItems.Count - 1);
  UpdateThickness;
end;

function TDaisyFmxDock.ItemSlots: TArray<TDaisyDockSlot>;
var
  LTotal, LLength, LStart, LReserved: Single;
  LReverse: Boolean;
  I: Integer;
begin
  if IsVertical then
    LTotal := Height
  else
    LTotal := Width;
  LReverse := DaisyDockFlowReversed(FDirectionFlow);
  // the collapse button takes the end of the dock the items flow towards
  LStart := 0;
  if ToggleVisible then
  begin
    LReserved := CToggleSize + 2 * CToggleMargin;
    LTotal := LTotal - LReserved;
    if LReverse then
      LStart := LReserved;
  end;
  // a left / right dock has square cells; a top / bottom dock has wider ones
  if IsVertical then
    LLength := DaisyDockThickness(SizeKind)
  else
    LLength := DaisyDockThickness(SizeKind) * 3 div 2;
  if FSpacing = dspEven then
    Result := DaisyDockSlots(FItems.Count, LTotal, LLength, 0, dspEven, LReverse)
  else
  begin
    Result := DaisyDockSlots(FItems.Count, LTotal - 2 * CEdgePadding, LLength, FIconSpacing,
      dspNormal, LReverse);
    LStart := LStart + CEdgePadding;
  end;
  for I := 0 to High(Result) do
    Result[I].Start := Result[I].Start + LStart;
end;

function TDaisyFmxDock.ItemRect(AIndex: Integer): TRectF;
var
  LSlots: TArray<TDaisyDockSlot>;
begin
  LSlots := ItemSlots;
  if IsVertical then
    Result := RectF(0, LSlots[AIndex].Start, Width, LSlots[AIndex].Start + LSlots[AIndex].Extent)
  else
    Result := RectF(LSlots[AIndex].Start, 0, LSlots[AIndex].Start + LSlots[AIndex].Extent, Height);
end;

function TDaisyFmxDock.ItemEnabled(AIndex: Integer): Boolean;
begin
  Result := Enabled and (AIndex >= 0) and (AIndex < FItems.Count) and FItems[AIndex].Enabled;
end;

function TDaisyFmxDock.TrackedItemAt(const APoint: TPointF): Integer;
var
  I: Integer;
begin
  Result := -1;
  if ToggleVisible and ToggleRect.Contains(APoint) then
    Exit(CToggleItem);
  if IsCollapsed then
    Exit;
  for I := 0 to FItems.Count - 1 do
    if ItemRect(I).Contains(APoint) then
      Exit(I);
end;

procedure TDaisyFmxDock.TrackedItemChanged;
begin
  SetItemCursor((TrackedItem = CToggleItem) and Enabled or ItemEnabled(TrackedItem));
  inherited;
end;

procedure TDaisyFmxDock.ActivateItem(AIndex: Integer);
begin
  if not ItemEnabled(AIndex) then
    Exit;
  SetItemIndex(AIndex);
  FItems[AIndex].Click;
  if Assigned(FOnItemClick) then
    FOnItemClick(Self, AIndex);
end;

procedure TDaisyFmxDock.MoveSelection(ADelta: Integer);
var
  LIndex, I: Integer;
begin
  LIndex := FItemIndex;
  for I := 1 to FItems.Count do
  begin
    LIndex := (LIndex + ADelta + FItems.Count) mod FItems.Count;
    if ItemEnabled(LIndex) then
    begin
      SetItemIndex(LIndex);
      Exit;
    end;
  end;
end;

procedure TDaisyFmxDock.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  LItem: Integer;
begin
  inherited MouseUp(Button, Shift, X, Y);
  if (Button = TMouseButton.mbLeft) and not (csDesigning in ComponentState) then
  begin
    SetFocus;
    LItem := TrackedItemAt(PointF(X, Y));
    if LItem = CToggleItem then
    begin
      if Enabled then
        SetCollapsed(not FCollapsed);
    end
    else
      ActivateItem(LItem);
  end;
end;

procedure TDaisyFmxDock.KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
var
  LStep: Integer;
  LHandled: Boolean;
begin
  LHandled := FItems.Count > 0;
  LStep := 0;
  if LHandled then
    // The arrow keys follow the visual direction, which is reversed for a horizontal RTL dock
    case Key of
      vkLeft: if not IsVertical then LStep := IfThen(IsRTL, 1, -1);
      vkRight: if not IsVertical then LStep := IfThen(IsRTL, -1, 1);
      vkUp: if IsVertical then LStep := -1;
      vkDown: if IsVertical then LStep := 1;
      vkHome: SetItemIndex(0);
      vkEnd: SetItemIndex(FItems.Count - 1);
      vkReturn: ActivateItem(FItemIndex);
    else
      if KeyChar = ' ' then
        ActivateItem(FItemIndex)
      else
        LHandled := False;
    end;
  if LHandled and (LStep <> 0) then
    MoveSelection(LStep)
  else if LHandled and (LStep = 0) and not (Key in [vkHome, vkEnd, vkReturn]) and (KeyChar <> ' ') then
    LHandled := False;
  if LHandled then
  begin
    Key := 0;
    KeyChar := #0;
  end
  else
    inherited KeyDown(Key, KeyChar, Shift);
end;

procedure TDaisyFmxDock.DrawContent(const AColors: TDaisyColors; const ARect: TRectF);
begin
  if not IsCollapsed then
    DrawItems(AColors);
  if ToggleVisible then
    DrawToggle(AColors);
end;

procedure TDaisyFmxDock.DrawToggle(const AColors: TDaisyColors);
var
  LRect: TRectF;
  LCenterX, LCenterY: Single;
  LPointsLeft, LHot: Boolean;
  LColor: TAlphaColor;
begin
  LRect := ToggleRect;
  LHot := Enabled and (TrackedItem = CToggleItem);
  if not Enabled then
    LColor := DaisyWithAlpha(AColors.Text, 0.3)
  else if LHot then
    LColor := AColors.Text
  else
    LColor := DaisyWithAlpha(AColors.Text, CInactiveOpacity);
  // the arrow points to the outer edge while expanded, to the inner edge while collapsed
  LPointsLeft := OuterOnLeft <> IsCollapsed;
  LCenterX := (LRect.Left + LRect.Right) / 2;
  LCenterY := (LRect.Top + LRect.Bottom) / 2;
  if LHot then
    FillRound(LRect, 4, DaisyWithAlpha(AColors.Text, 0.1));
  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Color := LColor;
  Canvas.Stroke.Thickness := 1.5;
  Canvas.Stroke.Cap := TStrokeCap.Round;
  Canvas.Stroke.Join := TStrokeJoin.Round;
  Canvas.Stroke.Dash := TStrokeDash.Solid;
  if LPointsLeft then
  begin
    Canvas.DrawLine(PointF(LCenterX + 2.5, LCenterY - 4), PointF(LCenterX - 2.5, LCenterY),
      AbsoluteOpacity);
    Canvas.DrawLine(PointF(LCenterX - 2.5, LCenterY), PointF(LCenterX + 2.5, LCenterY + 4),
      AbsoluteOpacity);
  end
  else
  begin
    Canvas.DrawLine(PointF(LCenterX - 2.5, LCenterY - 4), PointF(LCenterX + 2.5, LCenterY),
      AbsoluteOpacity);
    Canvas.DrawLine(PointF(LCenterX + 2.5, LCenterY), PointF(LCenterX - 2.5, LCenterY + 4),
      AbsoluteOpacity);
  end;
end;

procedure TDaisyFmxDock.DrawItems(const AColors: TDaisyColors);
var
  LRect, LIconBox, LLabelRect, LBar: TRectF;
  LIconSize, LLabelHeight, LGroupHeight, LTop: Single;
  LFont, I: Integer;
  LText: TAlphaColor;
  LHasLabel: Boolean;
begin
  if FItems.Count = 0 then
    Exit;
  LIconSize := DaisyDockIconSize(SizeKind);
  LFont := DaisyDockFontSize(SizeKind);
  LLabelHeight := MeasureTextHeight('Ag', 10000, LFont, False);

  for I := 0 to FItems.Count - 1 do
  begin
    LRect := ItemRect(I);
    if ItemEnabled(I) and (I = TrackedItem) and (I <> FItemIndex) then
      FillRound(RectF(LRect.Left + 4, LRect.Top + 4, LRect.Right - 4, LRect.Bottom - 4), 8,
        DaisyWithAlpha(AColors.Text, 0.1));
    if (I = FItemIndex) and ItemEnabled(I) then
    begin
      // a small rounded bar on the outer edge marks the active item
      case FPlacement of
        ddpBottom:
          LBar := RectF((LRect.Left + LRect.Right - CBarLength) / 2,
            LRect.Bottom - CBarThickness - 2, (LRect.Left + LRect.Right + CBarLength) / 2,
            LRect.Bottom - 2);
        ddpTop:
          LBar := RectF((LRect.Left + LRect.Right - CBarLength) / 2, LRect.Top + 2,
            (LRect.Left + LRect.Right + CBarLength) / 2, LRect.Top + 2 + CBarThickness);
      else
        if OuterOnLeft then
          LBar := RectF(LRect.Left + 2, (LRect.Top + LRect.Bottom - CBarLength) / 2,
            LRect.Left + 2 + CBarThickness, (LRect.Top + LRect.Bottom + CBarLength) / 2)
        else
          LBar := RectF(LRect.Right - 2 - CBarThickness,
            (LRect.Top + LRect.Bottom - CBarLength) / 2, LRect.Right - 2,
            (LRect.Top + LRect.Bottom + CBarLength) / 2);
      end;
      FillRound(LBar, CBarThickness / 2, AColors.Text);
    end;
    if IsFocused and (I = FItemIndex) then
      DrawItemFocus(RectF(LRect.Left + 4, LRect.Top + 4, LRect.Right - 4, LRect.Bottom - 4), 8);
  end;

  for I := 0 to FItems.Count - 1 do
  begin
    LRect := ItemRect(I);
    if not ItemEnabled(I) then
      LText := DaisyWithAlpha(AColors.Text, 0.3)
    else if I = FItemIndex then
      LText := AColors.Text
    else
      LText := DaisyWithAlpha(AColors.Text, CInactiveOpacity);
    LHasLabel := FShowLabels and (FItems[I].Caption <> '');
    LGroupHeight := LIconSize;
    if LHasLabel then
      LGroupHeight := LGroupHeight + LLabelHeight + 2;
    LTop := (LRect.Top + LRect.Bottom - LGroupHeight) / 2;
    // keep the content off the active bar
    case FPlacement of
      ddpBottom: LTop := LTop - 2;
      ddpTop: LTop := LTop + 2;
    end;
    LIconBox := RectF((LRect.Left + LRect.Right - LIconSize) / 2, LTop,
      (LRect.Left + LRect.Right + LIconSize) / 2, LTop + LIconSize);
    if not FItems[I].Icon.IsEmpty then
      DrawGlyph(FItems[I].Icon, LIconBox, LText);
    if LHasLabel then
    begin
      LLabelRect := RectF(LRect.Left + 2, LIconBox.Bottom + 2, LRect.Right - 2,
        LIconBox.Bottom + 2 + LLabelHeight);
      DrawText(FItems[I].Caption, LLabelRect, LText, LFont, False, TTextAlign.Center,
        TTextAlign.Leading, False);
    end;
  end;
end;

end.
