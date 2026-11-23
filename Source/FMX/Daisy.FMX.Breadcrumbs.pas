unit Daisy.FMX.Breadcrumbs;

{
  TDaisyFmxBreadcrumbs - the DaisyUI "breadcrumbs": a trail of links separated by chevrons
  (or slashes). Every item but the last is a link; the last one is the current page. Items can
  carry an icon. A trail wider than the control scrolls with the mouse wheel.
}

interface

uses
  System.SysUtils, System.Classes, System.Types, System.UITypes, System.Math,
  FMX.Types, FMX.Controls, FMX.Graphics, Daisy.Theme, Daisy.Navigation, Daisy.FMX.Control;

type
  TDaisyFmxBreadcrumbs = class(TDaisyControl)
  strict private
    type
      TCrumbLayout = record
        Items: TArray<TRectF>;
        Seps: TArray<Single>;
        Width: Single;
        RowHeight: Single;
      end;
    var
      FItems: TDaisyBreadcrumbItems;
      FSeparator: TDaisyBreadcrumbSeparator;
      FAutoFit: Boolean;
      FUpdating: Boolean;
      FScroll: Single;
      FOnItemClick: TDaisyItemClickEvent;
    procedure SetItems(const Value: TDaisyBreadcrumbItems);
    procedure SetSeparator(const Value: TDaisyBreadcrumbSeparator);
    procedure SetAutoFit(const Value: Boolean);
    procedure ItemsChanged(Sender: TObject);
    procedure Measure(out ALayout: TCrumbLayout);
    function IsLink(AIndex: Integer): Boolean;
    procedure UpdateSize;
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
    procedure MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean); override;
    procedure DrawContent(const AColors: TDaisyColors; const ARect: TRectF); override;
    procedure DrawCrumbs(const AColors: TDaisyColors);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Items: TDaisyBreadcrumbItems read FItems write SetItems;
    property Separator: TDaisyBreadcrumbSeparator read FSeparator write SetSeparator
      default dbsChevron;
    // The size follows the items and SizeKind; when off the control keeps its own size and a
    // trail wider than the control scrolls
    property AutoFit: Boolean read FAutoFit write SetAutoFit default False;
    property OnItemClick: TDaisyItemClickEvent read FOnItemClick write FOnItemClick;
  end;

implementation

const
  CIconSize = 16;
  CIconGap = 8;
  CSeparatorWidth = 22;
  CEdge = 2;
  CScrollStep = 40;

{ TDaisyFmxBreadcrumbs }

constructor TDaisyFmxBreadcrumbs.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItems := TDaisyBreadcrumbItems.Create(Self);
  FItems.OnChange := ItemsChanged;
  FItems.Add.Caption := 'Home';
  FItems.Add.Caption := 'Documents';
  FItems.Add.Caption := 'Add Document';
  CanFocus := False;
  SetBounds(Position.X, Position.Y, 260, 32);
end;

destructor TDaisyFmxBreadcrumbs.Destroy;
begin
  FItems.OnChange := nil;
  FItems.Free;
  inherited Destroy;
end;

function TDaisyFmxBreadcrumbs.IsInteractive: Boolean;
begin
  Result := True;
end;

function TDaisyFmxBreadcrumbs.DrawsFocusRing: Boolean;
begin
  Result := False;
end;

function TDaisyFmxBreadcrumbs.DefaultCornerRadius: Integer;
begin
  Result := 0;
end;

function TDaisyFmxBreadcrumbs.DefaultShadowSize: Integer;
begin
  Result := 0;
end;

function TDaisyFmxBreadcrumbs.DefaultContentPadding: Integer;
begin
  Result := 0;
end;

function TDaisyFmxBreadcrumbs.DefaultStyleColors(AState: TDaisyState): TDaisyColors;
begin
  Result := Default(TDaisyColors);
  Result.Text := Theme.BaseContent;
end;

procedure TDaisyFmxBreadcrumbs.SetItems(const Value: TDaisyBreadcrumbItems);
begin
  FItems.Assign(Value);
end;

procedure TDaisyFmxBreadcrumbs.SetSeparator(const Value: TDaisyBreadcrumbSeparator);
begin
  if FSeparator <> Value then
  begin
    FSeparator := Value;
    Repaint;
  end;
end;

procedure TDaisyFmxBreadcrumbs.SetAutoFit(const Value: Boolean);
begin
  if FAutoFit <> Value then
  begin
    FAutoFit := Value;
    UpdateSize;
  end;
end;

procedure TDaisyFmxBreadcrumbs.ItemsChanged(Sender: TObject);
begin
  UpdateSize;
  Repaint;
end;

function TDaisyFmxBreadcrumbs.IsLink(AIndex: Integer): Boolean;
begin
  Result := (AIndex >= 0) and (AIndex < FItems.Count - 1) and FItems[AIndex].Enabled and Enabled;
end;

procedure TDaisyFmxBreadcrumbs.Measure(out ALayout: TCrumbLayout);
var
  I: Integer;
  X, LWidth, LTop: Single;
  LFont: Integer;
begin
  LFont := DaisyFontSize(SizeKind);
  ALayout.RowHeight := MeasureTextHeight('Ag', 10000, LFont, False);
  LTop := (Height - ALayout.RowHeight) / 2;
  SetLength(ALayout.Items, FItems.Count);
  SetLength(ALayout.Seps, System.Math.Max(0, FItems.Count - 1));
  X := CEdge;
  for I := 0 to FItems.Count - 1 do
  begin
    LWidth := MeasureTextWidth(FItems[I].Caption, LFont, False);
    if not FItems[I].Icon.IsEmpty then
      LWidth := LWidth + CIconSize + CIconGap;
    ALayout.Items[I] := RectF(X, LTop, X + LWidth, LTop + ALayout.RowHeight);
    X := X + LWidth;
    if I < FItems.Count - 1 then
    begin
      ALayout.Seps[I] := X + CSeparatorWidth / 2;
      X := X + CSeparatorWidth;
    end;
  end;
  ALayout.Width := X + CEdge;
end;

procedure TDaisyFmxBreadcrumbs.UpdateSize;
var
  LLayout: TCrumbLayout;
  LW, LH: Single;
begin
  if FUpdating or (csLoading in ComponentState) then
    Exit;
  Measure(LLayout);
  if FAutoFit then
  begin
    LW := LLayout.Width;
    LH := LLayout.RowHeight + 2 * 8;
    if not (SameValue(Width, LW) and SameValue(Height, LH)) then
    begin
      FUpdating := True;
      try
        SetBounds(Position.X, Position.Y, LW, LH);
      finally
        FUpdating := False;
      end;
    end;
  end;
  FScroll := DaisyClampScroll(FScroll, LLayout.Width, Width);
end;

procedure TDaisyFmxBreadcrumbs.SizeChanged;
begin
  UpdateSize;
  Repaint;
end;

procedure TDaisyFmxBreadcrumbs.Resize;
begin
  inherited;
  UpdateSize;
end;

procedure TDaisyFmxBreadcrumbs.Loaded;
begin
  inherited;
  UpdateSize;
end;

function TDaisyFmxBreadcrumbs.TrackedItemAt(const APoint: TPointF): Integer;
var
  LLayout: TCrumbLayout;
  LRect: TRectF;
  I: Integer;
begin
  Result := -1;
  Measure(LLayout);
  for I := 0 to High(LLayout.Items) do
  begin
    LRect := LLayout.Items[I];
    LRect.Offset(-FScroll, 0);
    if RectF(LRect.Left, 0, LRect.Right, Height).Contains(APoint) then
      Exit(I);
  end;
end;

procedure TDaisyFmxBreadcrumbs.TrackedItemChanged;
begin
  SetItemCursor(IsLink(TrackedItem));
  inherited;
end;

procedure TDaisyFmxBreadcrumbs.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  LIndex: Integer;
begin
  inherited MouseUp(Button, Shift, X, Y);
  if (Button <> TMouseButton.mbLeft) or (csDesigning in ComponentState) then
    Exit;
  LIndex := TrackedItemAt(PointF(X, Y));
  if not IsLink(LIndex) then
    Exit;
  FItems[LIndex].Click;
  if Assigned(FOnItemClick) then
    FOnItemClick(Self, LIndex);
end;

procedure TDaisyFmxBreadcrumbs.MouseWheel(Shift: TShiftState; WheelDelta: Integer;
  var Handled: Boolean);
var
  LLayout: TCrumbLayout;
  LOld: Single;
begin
  Measure(LLayout);
  LOld := FScroll;
  FScroll := DaisyClampScroll(FScroll - Sign(WheelDelta) * CScrollStep, LLayout.Width, Width);
  if not SameValue(FScroll, LOld) then
  begin
    Handled := True;
    Repaint;
  end
  else
    inherited MouseWheel(Shift, WheelDelta, Handled);
end;

procedure TDaisyFmxBreadcrumbs.DrawContent(const AColors: TDaisyColors; const ARect: TRectF);
var
  LState: TCanvasSaveState;
begin
  LState := Canvas.SaveState;
  try
    // the content scrolls, so it must not paint outside the control
    Canvas.IntersectClipRect(RectF(0, 0, Width, Height));
    DrawCrumbs(AColors);
  finally
    Canvas.RestoreState(LState);
  end;
end;

procedure TDaisyFmxBreadcrumbs.DrawCrumbs(const AColors: TDaisyColors);
var
  LLayout: TCrumbLayout;
  LRect, LIconBox, LTextRect: TRectF;
  LFont, I: Integer;
  LCenterY, LSepX: Single;
  LText, LLinkText, LSepColor: TAlphaColor;
begin
  Measure(LLayout);
  LFont := DaisyFontSize(SizeKind);
  LCenterY := Height / 2;
  if Variant = dvDefault then
    LLinkText := AColors.Text
  else
    LLinkText := DaisyVariantPalette(Theme, Variant).Fill;
  if not Enabled then
    LLinkText := DaisyWithAlpha(Theme.BaseContent, 0.3);
  LSepColor := DaisyWithAlpha(Theme.BaseContent, 0.4);

  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Color := LSepColor;
  Canvas.Stroke.Thickness := 1.25;
  Canvas.Stroke.Cap := TStrokeCap.Round;
  Canvas.Stroke.Join := TStrokeJoin.Round;
  Canvas.Stroke.Dash := TStrokeDash.Solid;
  for I := 0 to High(LLayout.Seps) do
  begin
    LSepX := LLayout.Seps[I] - FScroll;
    if FSeparator = dbsChevron then
    begin
      Canvas.DrawLine(PointF(LSepX - 2, LCenterY - 4), PointF(LSepX + 2, LCenterY), AbsoluteOpacity);
      Canvas.DrawLine(PointF(LSepX + 2, LCenterY), PointF(LSepX - 2, LCenterY + 4), AbsoluteOpacity);
    end
    else
      Canvas.DrawLine(PointF(LSepX + 3, LCenterY - 6), PointF(LSepX - 3, LCenterY + 6),
        AbsoluteOpacity);
  end;
  // a link is underlined while the mouse is over it
  if IsLink(TrackedItem) then
  begin
    LRect := LLayout.Items[TrackedItem];
    LRect.Offset(-FScroll, 0);
    if not FItems[TrackedItem].Icon.IsEmpty then
      LRect.Left := LRect.Left + CIconSize + CIconGap;
    FillRound(RectF(LRect.Left, LRect.Bottom - 2, LRect.Right, LRect.Bottom - 1), 0, LLinkText);
  end;

  for I := 0 to High(LLayout.Items) do
  begin
    LRect := LLayout.Items[I];
    LRect.Offset(-FScroll, 0);
    if (LRect.Right < 0) or (LRect.Left > Width) then
      Continue;
    if IsLink(I) then
      LText := LLinkText
    else if Enabled and FItems[I].Enabled then
      LText := AColors.Text
    else
      LText := DaisyWithAlpha(Theme.BaseContent, 0.3);
    LTextRect := LRect;
    if not FItems[I].Icon.IsEmpty then
    begin
      LIconBox := RectF(LRect.Left, LCenterY - CIconSize / 2, LRect.Left + CIconSize,
        LCenterY + CIconSize / 2);
      DrawGlyph(FItems[I].Icon, LIconBox, LText);
      LTextRect.Left := LTextRect.Left + CIconSize + CIconGap;
    end;
    DrawText(FItems[I].Caption, LTextRect, LText, LFont, False, TTextAlign.Leading,
      TTextAlign.Center, False);
  end;
end;

end.
