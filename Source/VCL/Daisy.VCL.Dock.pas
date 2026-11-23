unit Daisy.VCL.Dock;

{
  TDaisyDock - the DaisyUI "dock": a bar of icon + label buttons fixed to an edge of the screen.
  Unlike the web component it can sit at the bottom, top, left or right, and its items are either
  spread evenly along the whole bar (dspEven) or packed from the start with a standard gap
  (dspNormal).
}

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  System.SysUtils, System.Classes, System.Types, System.UITypes, System.Math,
  Vcl.Controls, Daisy.Theme, Daisy.Navigation, Daisy.VCL.Control;

type
  TDaisyDock = class(TDaisyControl)
  strict private
    var
      FItems: TDaisyDockItems;
      FPlacement: TDaisyDockPlacement;
      FSpacing: TDaisyDockSpacing;
      FShowLabels: Boolean;
      FAutoThickness: Boolean;
      FItemIndex: Integer;
      FUpdating: Boolean;
      FOnChange: TNotifyEvent;
      FOnItemClick: TDaisyItemClickEvent;
    procedure SetItems(const Value: TDaisyDockItems);
    procedure SetPlacement(const Value: TDaisyDockPlacement);
    procedure SetSpacing(const Value: TDaisyDockSpacing);
    procedure SetShowLabels(const Value: Boolean);
    procedure SetAutoThickness(const Value: Boolean);
    procedure SetItemIndex(const Value: Integer);
    procedure ItemsChanged(Sender: TObject);
    function IsVertical: Boolean;
    function Thickness: Integer;
    function ItemRect(AIndex: Integer): TRect;
    function ItemSlots: TArray<TDaisyDockSlot>;
    function ItemEnabled(AIndex: Integer): Boolean;
    function OuterOnLeft: Boolean;
    procedure UpdateThickness;
    procedure ActivateItem(AIndex: Integer);
    procedure MoveSelection(ADelta: Integer);
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
  protected
    function IsInteractive: Boolean; override;
    function DrawsFocusRing: Boolean; override;
    function DefaultCornerRadius: Integer; override;
    function DefaultShadowSize: Integer; override;
    function DefaultContentPadding: Integer; override;
    function DefaultStyleColors(AState: TDaisyState): TDaisyColors; override;
    function TrackedItemAt(const APoint: TPoint): Integer; override;
    procedure TrackedItemChanged; override;
    procedure SizeChanged; override;
    procedure Resize; override;
    procedure Loaded; override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DrawContent(const AColors: TDaisyColors; const ARect: TRect); override;
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
    property ShowLabels: Boolean read FShowLabels write SetShowLabels default True;
    // The thickness of the bar (its height, or its width when docked left/right) follows SizeKind
    property AutoThickness: Boolean read FAutoThickness write SetAutoThickness default True;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnItemClick: TDaisyItemClickEvent read FOnItemClick write FOnItemClick;
  end;

implementation

const
  CNormalGap = 4;
  CEdgePadding = 8;
  CBarLength = 24;
  CBarThickness = 2;
  CInactiveOpacity = 0.6;

{ TDaisyDock }

constructor TDaisyDock.Create(AOwner: TComponent);
var
  LNames: array[0..2] of string;
  I: Integer;
begin
  inherited Create(AOwner);
  FPlacement := ddpBottom;
  FSpacing := dspEven;
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
  SetBounds(Left, Top, 320, DaisyDockThickness(SizeKind));
end;

destructor TDaisyDock.Destroy;
begin
  FItems.OnChange := nil;
  FItems.Free;
  inherited Destroy;
end;

function TDaisyDock.IsInteractive: Boolean;
begin
  Result := True;
end;

function TDaisyDock.DrawsFocusRing: Boolean;
begin
  Result := False;
end;

function TDaisyDock.DefaultCornerRadius: Integer;
begin
  Result := 0;
end;

function TDaisyDock.DefaultShadowSize: Integer;
begin
  Result := 0;
end;

function TDaisyDock.DefaultContentPadding: Integer;
begin
  Result := 0;
end;

function TDaisyDock.DefaultStyleColors(AState: TDaisyState): TDaisyColors;
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

function TDaisyDock.IsVertical: Boolean;
begin
  Result := FPlacement in [ddpLeft, ddpRight];
end;

function TDaisyDock.OuterOnLeft: Boolean;
begin
  // Logical coordinates are mirrored in RTL, so the physical left edge is the logical right one
  Result := (FPlacement = ddpLeft) <> IsRTL;
end;

function TDaisyDock.Thickness: Integer;
begin
  Result := ScaleValue(DaisyDockThickness(SizeKind));
end;

procedure TDaisyDock.SetItems(const Value: TDaisyDockItems);
begin
  FItems.Assign(Value);
end;

procedure TDaisyDock.SetPlacement(const Value: TDaisyDockPlacement);
begin
  if FPlacement = Value then
    Exit;
  FPlacement := Value;
  if not (csLoading in ComponentState) then
  begin
    case Align of
      alTop, alBottom, alLeft, alRight:
        case Value of
          ddpBottom: Align := alBottom;
          ddpTop: Align := alTop;
          ddpLeft: Align := alLeft;
          ddpRight: Align := alRight;
        end;
    end;
    UpdateThickness;
  end;
  Invalidate;
end;

procedure TDaisyDock.SetSpacing(const Value: TDaisyDockSpacing);
begin
  if FSpacing <> Value then
  begin
    FSpacing := Value;
    Invalidate;
  end;
end;

procedure TDaisyDock.SetShowLabels(const Value: Boolean);
begin
  if FShowLabels <> Value then
  begin
    FShowLabels := Value;
    Invalidate;
  end;
end;

procedure TDaisyDock.SetAutoThickness(const Value: Boolean);
begin
  if FAutoThickness <> Value then
  begin
    FAutoThickness := Value;
    UpdateThickness;
  end;
end;

procedure TDaisyDock.SetItemIndex(const Value: Integer);
var
  LValue: Integer;
begin
  LValue := EnsureRange(Value, -1, FItems.Count - 1);
  if FItemIndex <> LValue then
  begin
    FItemIndex := LValue;
    Invalidate;
    if Assigned(FOnChange) and not (csLoading in ComponentState) then
      FOnChange(Self);
  end;
end;

procedure TDaisyDock.ItemsChanged(Sender: TObject);
begin
  if FItemIndex > FItems.Count - 1 then
    FItemIndex := FItems.Count - 1;
  Invalidate;
end;

procedure TDaisyDock.UpdateThickness;
var
  LThickness: Integer;
begin
  if (not FAutoThickness) or FUpdating or (csLoading in ComponentState) then
    Exit;
  LThickness := Thickness;
  FUpdating := True;
  try
    // the dimension an Align already dictates is left alone
    if IsVertical then
    begin
      if (Width <> LThickness) and not (Align in [alTop, alBottom, alClient]) then
        Width := LThickness;
    end
    else if (Height <> LThickness) and not (Align in [alLeft, alRight, alClient]) then
      Height := LThickness;
  finally
    FUpdating := False;
  end;
end;

procedure TDaisyDock.SizeChanged;
begin
  UpdateThickness;
end;

procedure TDaisyDock.Resize;
begin
  inherited;
  UpdateThickness;
end;

procedure TDaisyDock.Loaded;
begin
  inherited;
  FItemIndex := EnsureRange(FItemIndex, -1, FItems.Count - 1);
  UpdateThickness;
end;

function TDaisyDock.ItemSlots: TArray<TDaisyDockSlot>;
var
  LPad, LTotal, LLength: Integer;
begin
  LPad := ScaleValue(CEdgePadding);
  if IsVertical then
    LTotal := Height
  else
    LTotal := Width;
  LLength := ScaleValue(DaisyDockThickness(SizeKind) * 3 div 2);
  if FSpacing = dspEven then
    Result := DaisyDockSlots(FItems.Count, LTotal, LLength, 0, dspEven)
  else
  begin
    Result := DaisyDockSlots(FItems.Count, LTotal - 2 * LPad, LLength, ScaleValue(CNormalGap),
      dspNormal);
    for var I := 0 to High(Result) do
      Result[I].Start := Result[I].Start + LPad;
  end;
end;

function TDaisyDock.ItemRect(AIndex: Integer): TRect;
var
  LSlots: TArray<TDaisyDockSlot>;
begin
  LSlots := ItemSlots;
  if IsVertical then
    Result := Rect(0, Round(LSlots[AIndex].Start), Width,
      Round(LSlots[AIndex].Start + LSlots[AIndex].Extent))
  else
    Result := Rect(Round(LSlots[AIndex].Start), 0,
      Round(LSlots[AIndex].Start + LSlots[AIndex].Extent), Height);
end;

function TDaisyDock.ItemEnabled(AIndex: Integer): Boolean;
begin
  Result := Enabled and (AIndex >= 0) and (AIndex < FItems.Count) and FItems[AIndex].Enabled;
end;

function TDaisyDock.TrackedItemAt(const APoint: TPoint): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FItems.Count - 1 do
    if PtInRect(ItemRect(I), APoint) then
      Exit(I);
end;

procedure TDaisyDock.TrackedItemChanged;
begin
  SetItemCursor(ItemEnabled(TrackedItem));
  inherited;
end;

procedure TDaisyDock.ActivateItem(AIndex: Integer);
begin
  if not ItemEnabled(AIndex) then
    Exit;
  SetItemIndex(AIndex);
  FItems[AIndex].Click;
  if Assigned(FOnItemClick) then
    FOnItemClick(Self, AIndex);
end;

procedure TDaisyDock.MoveSelection(ADelta: Integer);
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

procedure TDaisyDock.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if (Button = mbLeft) and not (csDesigning in ComponentState) then
    ActivateItem(TrackedItemAt(MirrorPoint(Point(X, Y))));
end;

procedure TDaisyDock.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  Message.Result := Message.Result or DLGC_WANTARROWS;
end;

procedure TDaisyDock.KeyDown(var Key: Word; Shift: TShiftState);
var
  LStep: Integer;
begin
  inherited KeyDown(Key, Shift);
  if FItems.Count = 0 then
    Exit;
  // The arrow keys follow the visual direction, which is reversed for a horizontal RTL dock
  LStep := 0;
  case Key of
    VK_LEFT: if not IsVertical then LStep := IfThen(IsRTL, 1, -1);
    VK_RIGHT: if not IsVertical then LStep := IfThen(IsRTL, -1, 1);
    VK_UP: if IsVertical then LStep := -1;
    VK_DOWN: if IsVertical then LStep := 1;
    VK_HOME:
      begin
        SetItemIndex(0);
        Key := 0;
      end;
    VK_END:
      begin
        SetItemIndex(FItems.Count - 1);
        Key := 0;
      end;
    VK_RETURN, VK_SPACE:
      begin
        ActivateItem(FItemIndex);
        Key := 0;
      end;
  end;
  if LStep <> 0 then
  begin
    MoveSelection(LStep);
    Key := 0;
  end;
end;

procedure TDaisyDock.DrawContent(const AColors: TDaisyColors; const ARect: TRect);
var
  LGraphics: TGPGraphics;
  LRect, LIconBox, LLabelRect: TRect;
  LIconSize, LLabelHeight, LFont, LGroupHeight, LTop, I: Integer;
  LBar: TRectF;
  LText: TAlphaColor;
  LHasLabel: Boolean;
begin
  if FItems.Count = 0 then
    Exit;
  LIconSize := ScaleValue(DaisyDockIconSize(SizeKind));
  LFont := DaisyDockFontSize(SizeKind);
  LLabelHeight := MeasureTextHeight('Ag', 10000, LFont, False);

  LGraphics := NewGraphics;
  try
    for I := 0 to FItems.Count - 1 do
    begin
      LRect := ItemRect(I);
      if ItemEnabled(I) and (I = TrackedItem) and (I <> FItemIndex) then
        FillRoundRect(LGraphics, RectF(LRect.Left + ScaleValue(4), LRect.Top + ScaleValue(4),
          LRect.Right - ScaleValue(4), LRect.Bottom - ScaleValue(4)), ScaleValue(8),
          DaisyWithAlpha(AColors.Text, 0.1));
      if I = FItemIndex then
      begin
        // a small rounded bar on the outer edge marks the active item
        case FPlacement of
          ddpBottom:
            LBar := RectF((LRect.Left + LRect.Right - ScaleValue(CBarLength)) / 2,
              LRect.Bottom - ScaleValue(CBarThickness) - ScaleValue(2),
              (LRect.Left + LRect.Right + ScaleValue(CBarLength)) / 2, LRect.Bottom - ScaleValue(2));
          ddpTop:
            LBar := RectF((LRect.Left + LRect.Right - ScaleValue(CBarLength)) / 2,
              LRect.Top + ScaleValue(2),
              (LRect.Left + LRect.Right + ScaleValue(CBarLength)) / 2,
              LRect.Top + ScaleValue(2) + ScaleValue(CBarThickness));
        else
          if OuterOnLeft then
            LBar := RectF(LRect.Left + ScaleValue(2),
              (LRect.Top + LRect.Bottom - ScaleValue(CBarLength)) / 2,
              LRect.Left + ScaleValue(2) + ScaleValue(CBarThickness),
              (LRect.Top + LRect.Bottom + ScaleValue(CBarLength)) / 2)
          else
            LBar := RectF(LRect.Right - ScaleValue(2) - ScaleValue(CBarThickness),
              (LRect.Top + LRect.Bottom - ScaleValue(CBarLength)) / 2,
              LRect.Right - ScaleValue(2),
              (LRect.Top + LRect.Bottom + ScaleValue(CBarLength)) / 2);
        end;
        if ItemEnabled(I) then
          FillRoundRect(LGraphics, LBar, ScaleValue(CBarThickness) / 2, AColors.Text);
      end;
      if Focused and (I = FItemIndex) then
        DrawItemFocus(LGraphics, RectF(LRect.Left + ScaleValue(4), LRect.Top + ScaleValue(4),
          LRect.Right - ScaleValue(4), LRect.Bottom - ScaleValue(4)), ScaleValue(8));
    end;
  finally
    LGraphics.Free;
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
      Inc(LGroupHeight, LLabelHeight + ScaleValue(2));
    LTop := (LRect.Top + LRect.Bottom - LGroupHeight) div 2;
    // keep the content off the active bar
    case FPlacement of
      ddpBottom: Dec(LTop, ScaleValue(2));
      ddpTop: Inc(LTop, ScaleValue(2));
    end;
    LIconBox := Rect((LRect.Left + LRect.Right - LIconSize) div 2, LTop,
      (LRect.Left + LRect.Right + LIconSize) div 2, LTop + LIconSize);
    if not FItems[I].Icon.IsEmpty then
      DrawGlyph(FItems[I].Icon, LIconBox, LText);
    if LHasLabel then
    begin
      LLabelRect := Rect(LRect.Left + ScaleValue(2), LIconBox.Bottom + ScaleValue(2),
        LRect.Right - ScaleValue(2), LIconBox.Bottom + ScaleValue(2) + LLabelHeight);
      DrawText(FItems[I].Caption, LLabelRect, LText, LFont, False,
        DT_CENTER or DT_SINGLELINE or DT_TOP or DT_END_ELLIPSIS);
    end;
  end;
end;

end.
