unit Daisy.VCL.Breadcrumbs;

{
  TDaisyBreadcrumbs - the DaisyUI "breadcrumbs": a trail of links separated by chevrons
  (or slashes). Every item but the last is a link; the last one is the current page. Items can
  carry an icon. A trail wider than the control scrolls with the mouse wheel.
}

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  System.SysUtils, System.Classes, System.Types, System.UITypes, System.Math,
  Vcl.Controls, Daisy.Theme, Daisy.Navigation, Daisy.VCL.Control;

type
  TDaisyBreadcrumbs = class(TDaisyControl)
  strict private
    type
      TCrumbLayout = record
        Items: TArray<TRect>;
        Seps: TArray<Integer>;
        Width: Integer;
        RowHeight: Integer;
      end;
    var
      FItems: TDaisyBreadcrumbItems;
      FSeparator: TDaisyBreadcrumbSeparator;
      FAutoFit: Boolean;
      FUpdating: Boolean;
      FScroll: Integer;
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
    function TrackedItemAt(const APoint: TPoint): Integer; override;
    procedure TrackedItemChanged; override;
    procedure SizeChanged; override;
    procedure Resize; override;
    procedure Loaded; override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
    procedure DrawContent(const AColors: TDaisyColors; const ARect: TRect); override;
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

{ TDaisyBreadcrumbs }

constructor TDaisyBreadcrumbs.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItems := TDaisyBreadcrumbItems.Create(Self);
  FItems.OnChange := ItemsChanged;
  FItems.Add.Caption := 'Home';
  FItems.Add.Caption := 'Documents';
  FItems.Add.Caption := 'Add Document';
  SetBounds(Left, Top, 260, 32);
end;

destructor TDaisyBreadcrumbs.Destroy;
begin
  FItems.OnChange := nil;
  FItems.Free;
  inherited Destroy;
end;

function TDaisyBreadcrumbs.IsInteractive: Boolean;
begin
  Result := True;
end;

function TDaisyBreadcrumbs.DrawsFocusRing: Boolean;
begin
  Result := False;
end;

function TDaisyBreadcrumbs.DefaultCornerRadius: Integer;
begin
  Result := 0;
end;

function TDaisyBreadcrumbs.DefaultShadowSize: Integer;
begin
  Result := 0;
end;

function TDaisyBreadcrumbs.DefaultContentPadding: Integer;
begin
  Result := 0;
end;

function TDaisyBreadcrumbs.DefaultStyleColors(AState: TDaisyState): TDaisyColors;
begin
  Result := Default(TDaisyColors);
  Result.Text := Theme.BaseContent;
end;

procedure TDaisyBreadcrumbs.SetItems(const Value: TDaisyBreadcrumbItems);
begin
  FItems.Assign(Value);
end;

procedure TDaisyBreadcrumbs.SetSeparator(const Value: TDaisyBreadcrumbSeparator);
begin
  if FSeparator <> Value then
  begin
    FSeparator := Value;
    Invalidate;
  end;
end;

procedure TDaisyBreadcrumbs.SetAutoFit(const Value: Boolean);
begin
  if FAutoFit <> Value then
  begin
    FAutoFit := Value;
    UpdateSize;
  end;
end;

procedure TDaisyBreadcrumbs.ItemsChanged(Sender: TObject);
begin
  UpdateSize;
  Invalidate;
end;

function TDaisyBreadcrumbs.IsLink(AIndex: Integer): Boolean;
begin
  Result := (AIndex >= 0) and (AIndex < FItems.Count - 1) and FItems[AIndex].Enabled and Enabled;
end;

procedure TDaisyBreadcrumbs.Measure(out ALayout: TCrumbLayout);
var
  I, X, LFont, LWidth, LTop: Integer;
begin
  LFont := DaisyFontSize(SizeKind);
  ALayout.RowHeight := MeasureTextHeight('Ag', 10000, LFont, False);
  LTop := (Height - ALayout.RowHeight) div 2;
  SetLength(ALayout.Items, FItems.Count);
  SetLength(ALayout.Seps, Max(0, FItems.Count - 1));
  X := ScaleValue(CEdge);
  for I := 0 to FItems.Count - 1 do
  begin
    LWidth := MeasureTextWidth(FItems[I].Caption, LFont, False);
    if not FItems[I].Icon.IsEmpty then
      Inc(LWidth, ScaleValue(CIconSize + CIconGap));
    ALayout.Items[I] := Rect(X, LTop, X + LWidth, LTop + ALayout.RowHeight);
    Inc(X, LWidth);
    if I < FItems.Count - 1 then
    begin
      ALayout.Seps[I] := X + ScaleValue(CSeparatorWidth) div 2;
      Inc(X, ScaleValue(CSeparatorWidth));
    end;
  end;
  ALayout.Width := X + ScaleValue(CEdge);
end;

procedure TDaisyBreadcrumbs.UpdateSize;
var
  LLayout: TCrumbLayout;
  LW, LH: Integer;
begin
  if FUpdating or (csLoading in ComponentState) then
    Exit;
  Measure(LLayout);
  if FAutoFit then
  begin
    LW := LLayout.Width;
    LH := LLayout.RowHeight + 2 * ScaleValue(8);
    if (Width <> LW) or (Height <> LH) then
    begin
      FUpdating := True;
      try
        SetBounds(Left, Top, LW, LH);
      finally
        FUpdating := False;
      end;
    end;
  end;
  FScroll := Round(DaisyClampScroll(FScroll, LLayout.Width, Width));
end;

procedure TDaisyBreadcrumbs.SizeChanged;
begin
  UpdateSize;
end;

procedure TDaisyBreadcrumbs.Resize;
begin
  inherited;
  UpdateSize;
end;

procedure TDaisyBreadcrumbs.Loaded;
begin
  inherited;
  UpdateSize;
end;

function TDaisyBreadcrumbs.TrackedItemAt(const APoint: TPoint): Integer;
var
  LLayout: TCrumbLayout;
  LRect: TRect;
  I: Integer;
begin
  Result := -1;
  Measure(LLayout);
  for I := 0 to High(LLayout.Items) do
  begin
    LRect := LLayout.Items[I];
    OffsetRect(LRect, -FScroll, 0);
    if PtInRect(Rect(LRect.Left, 0, LRect.Right, Height), APoint) then
      Exit(I);
  end;
end;

procedure TDaisyBreadcrumbs.TrackedItemChanged;
begin
  SetItemCursor(IsLink(TrackedItem));
  inherited;
end;

procedure TDaisyBreadcrumbs.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LIndex: Integer;
begin
  inherited MouseUp(Button, Shift, X, Y);
  if (Button <> mbLeft) or (csDesigning in ComponentState) then
    Exit;
  LIndex := TrackedItemAt(MirrorPoint(Point(X, Y)));
  if not IsLink(LIndex) then
    Exit;
  FItems[LIndex].Click;
  if Assigned(FOnItemClick) then
    FOnItemClick(Self, LIndex);
end;

function TDaisyBreadcrumbs.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
var
  LLayout: TCrumbLayout;
  LOld: Integer;
begin
  Measure(LLayout);
  LOld := FScroll;
  FScroll := Round(DaisyClampScroll(FScroll - Sign(WheelDelta) * ScaleValue(CScrollStep),
    LLayout.Width, Width));
  Result := FScroll <> LOld;
  if Result then
    Invalidate
  else
    Result := inherited DoMouseWheel(Shift, WheelDelta, MousePos);
end;

procedure TDaisyBreadcrumbs.DrawContent(const AColors: TDaisyColors; const ARect: TRect);
var
  LLayout: TCrumbLayout;
  LGraphics: TGPGraphics;
  LPen: TGPPen;
  LRect, LIconBox, LTextRect: TRect;
  LFont, I, LCenterY, LSepX: Integer;
  LText: TAlphaColor;
  LLinkText: TAlphaColor;
begin
  Measure(LLayout);
  LFont := DaisyFontSize(SizeKind);
  LCenterY := Height div 2;
  if Variant = dvDefault then
    LLinkText := AColors.Text
  else
    LLinkText := DaisyVariantPalette(Theme, Variant).Fill;
  if not Enabled then
    LLinkText := DaisyWithAlpha(Theme.BaseContent, 0.3);

  LGraphics := NewGraphics;
  try
    LPen := TGPPen.Create(DaisyWithAlpha(Theme.BaseContent, 0.4), Max(1, ScaleValue(1)) * 1.25);
    try
      LPen.SetLineCap(LineCapRound, LineCapRound, DashCapRound);
      LPen.SetLineJoin(LineJoinRound);
      for I := 0 to High(LLayout.Seps) do
      begin
        LSepX := LLayout.Seps[I] - FScroll;
        if FSeparator = dbsChevron then
        begin
          LGraphics.DrawLine(LPen, LSepX - ScaleValue(2) + 0.5, LCenterY - ScaleValue(4),
            LSepX + ScaleValue(2) + 0.5, LCenterY);
          LGraphics.DrawLine(LPen, LSepX + ScaleValue(2) + 0.5, LCenterY,
            LSepX - ScaleValue(2) + 0.5, LCenterY + ScaleValue(4));
        end
        else
          LGraphics.DrawLine(LPen, LSepX + ScaleValue(3), LCenterY - ScaleValue(6),
            LSepX - ScaleValue(3), LCenterY + ScaleValue(6));
      end;
    finally
      LPen.Free;
    end;
    // a link is underlined while the mouse is over it
    if IsLink(TrackedItem) then
    begin
      LRect := LLayout.Items[TrackedItem];
      OffsetRect(LRect, -FScroll, 0);
      if not FItems[TrackedItem].Icon.IsEmpty then
        Inc(LRect.Left, ScaleValue(CIconSize + CIconGap));
      FillRoundRect(LGraphics, RectF(LRect.Left, LRect.Bottom - ScaleValue(2),
        LRect.Right, LRect.Bottom - ScaleValue(2) + Max(1, ScaleValue(1))), 0, LLinkText);
    end;
  finally
    LGraphics.Free;
  end;

  for I := 0 to High(LLayout.Items) do
  begin
    LRect := LLayout.Items[I];
    OffsetRect(LRect, -FScroll, 0);
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
      LIconBox := Rect(LRect.Left, LCenterY - ScaleValue(CIconSize) div 2,
        LRect.Left + ScaleValue(CIconSize), LCenterY + ScaleValue(CIconSize) div 2);
      DrawGlyph(FItems[I].Icon, LIconBox, LText);
      Inc(LTextRect.Left, ScaleValue(CIconSize + CIconGap));
    end;
    DrawText(FItems[I].Caption, LTextRect, LText, LFont, False,
      DT_LEFT or DT_SINGLELINE or DT_VCENTER);
  end;
end;

end.
