unit Daisy.VCL.Chart;

{
  TDaisyChart - a chart in the style of the Flowbite (ApexCharts) charts: line, area,
  column, bar, pie, donut and radial. The data lives in Series (each item holds a name,
  a comma separated Data list and an optional colour), the category or slice names in
  Labels. The layout is done by Daisy.Charts; this unit only draws the resulting shapes
  with GDI+ and shows the hover tooltip.
}

interface

uses
  Winapi.Windows, Winapi.GDIPAPI, Winapi.GDIPOBJ, System.SysUtils, System.Classes,
  System.Types, System.UITypes, System.Math, Vcl.Controls,
  Daisy.Theme, Daisy.Charts, Daisy.VCL.Control;

type
  TDaisyChart = class(TDaisyControl)
  strict private
    FEngine: TDaisyChartEngine;
    FSeries: TDaisyChartSeriesCollection;
    FLabels: TStrings;
    FColors: TStrings;
    FChartType: TDaisyChartType;
    FDataLabels: Boolean;
    FShowGrid: Boolean;
    FShowXAxis: Boolean;
    FShowYAxis: Boolean;
    FShowTooltip: Boolean;
    FShowTotal: Boolean;
    FStacked: Boolean;
    FCurve: TDaisyChartCurve;
    FStrokeWidth: Integer;
    FMarkerSize: Integer;
    FBarRadius: Integer;
    FHoleSize: Integer;
    FLegendPosition: TDaisyChartLegendPosition;
    FValuePrefix: string;
    FValueSuffix: string;
    FTotalLabel: string;
    procedure SetSeries(const AValue: TDaisyChartSeriesCollection);
    procedure SetLabels(const AValue: TStrings);
    procedure SetColors(const AValue: TStrings);
    procedure SetChartType(const AValue: TDaisyChartType);
    procedure SetDataLabels(const AValue: Boolean);
    procedure SetShowGrid(const AValue: Boolean);
    procedure SetShowXAxis(const AValue: Boolean);
    procedure SetShowYAxis(const AValue: Boolean);
    procedure SetShowTooltip(const AValue: Boolean);
    procedure SetShowTotal(const AValue: Boolean);
    procedure SetStacked(const AValue: Boolean);
    procedure SetCurve(const AValue: TDaisyChartCurve);
    procedure SetStrokeWidth(const AValue: Integer);
    procedure SetMarkerSize(const AValue: Integer);
    procedure SetBarRadius(const AValue: Integer);
    procedure SetHoleSize(const AValue: Integer);
    procedure SetLegendPosition(const AValue: TDaisyChartLegendPosition);
    procedure SetValuePrefix(const AValue: string);
    procedure SetValueSuffix(const AValue: string);
    procedure SetTotalLabel(const AValue: string);
    function GetChartWidth: Integer;
    procedure SetChartWidth(const AValue: Integer);
    function GetChartHeight: Integer;
    procedure SetChartHeight(const AValue: Integer);
    procedure DataChanged(Sender: TObject);
    function MeasureChartText(const AText: string; AFontSize: Integer; ABold: Boolean): Single;
    function ChartFontSize: Integer;
    procedure PrepareEngine;
    procedure DrawShape(AGraphics: TGPGraphics; const AShape: TDaisyChartShape);
    procedure DrawShapeText(const AShape: TDaisyChartShape);
  protected
    function DefaultCornerRadius: Integer; override;
    function DefaultShadowSize: Integer; override;
    function DefaultContentPadding: Integer; override;
    function DefaultStyleColors(AState: TDaisyState): TDaisyColors; override;
    procedure SizeChanged; override;
    function TrackedItemAt(const APoint: TPoint): Integer; override;
    procedure TrackedItemChanged; override;
    procedure DrawContent(const AColors: TDaisyColors; const ARect: TRect); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property ChartType: TDaisyChartType read FChartType write SetChartType default dctLine;
    // The data series; each item has a Name, a Data list ("6500, 6418, 6456") and a Color
    property Series: TDaisyChartSeriesCollection read FSeries write SetSeries;
    // Category names of a line, area, column or bar chart; slice names of a pie, donut or radial chart
    property Labels: TStrings read FLabels write SetLabels;
    // Series colours as HTML colours (#1C64F2), used in order; empty uses the theme colours
    property Colors: TStrings read FColors write SetColors;
    // Writes the value on bars, points and slices
    property DataLabels: Boolean read FDataLabels write SetDataLabels default False;
    // Size of the chart in pixels (the same as Width and Height)
    property ChartWidth: Integer read GetChartWidth write SetChartWidth stored False;
    property ChartHeight: Integer read GetChartHeight write SetChartHeight stored False;
    property LegendPosition: TDaisyChartLegendPosition read FLegendPosition write SetLegendPosition
      default dlpBottom;
    property ShowGrid: Boolean read FShowGrid write SetShowGrid default True;
    property ShowXAxis: Boolean read FShowXAxis write SetShowXAxis default True;
    property ShowYAxis: Boolean read FShowYAxis write SetShowYAxis default True;
    property ShowTooltip: Boolean read FShowTooltip write SetShowTooltip default True;
    // Donut: writes the total in the hole. Radial: writes the average
    property ShowTotal: Boolean read FShowTotal write SetShowTotal default True;
    property TotalLabel: string read FTotalLabel write SetTotalLabel;
    // Column, bar and area charts: the series are stacked
    property Stacked: Boolean read FStacked write SetStacked default False;
    property Curve: TDaisyChartCurve read FCurve write SetCurve default dccSmooth;
    property StrokeWidth: Integer read FStrokeWidth write SetStrokeWidth default 3;
    // Radius of the dot drawn on every point of a line or area chart; 0 draws none
    property MarkerSize: Integer read FMarkerSize write SetMarkerSize default 0;
    // Rounding of the bar ends
    property BarRadius: Integer read FBarRadius write SetBarRadius default 4;
    // Size of the donut hole in percent of the diameter
    property HoleSize: Integer read FHoleSize write SetHoleSize default 65;
    property ValuePrefix: string read FValuePrefix write SetValuePrefix;
    property ValueSuffix: string read FValueSuffix write SetValueSuffix;
  end;

implementation

const
  CFontSizes: array[TDaisySize] of Integer = (10, 11, 12, 14, 16);

{ TDaisyChart }

constructor TDaisyChart.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEngine := TDaisyChartEngine.Create;
  FEngine.Measure := MeasureChartText;
  FSeries := TDaisyChartSeriesCollection.Create(Self);
  FSeries.OnChange := DataChanged;
  FLabels := TStringList.Create;
  TStringList(FLabels).OnChange := DataChanged;
  FColors := TStringList.Create;
  TStringList(FColors).OnChange := DataChanged;
  FChartType := dctLine;
  FLegendPosition := dlpBottom;
  FShowGrid := True;
  FShowXAxis := True;
  FShowYAxis := True;
  FShowTooltip := True;
  FShowTotal := True;
  FCurve := dccSmooth;
  FStrokeWidth := 3;
  FBarRadius := 4;
  FHoleSize := 65;
  SetBounds(Left, Top, 320, 220);
end;

destructor TDaisyChart.Destroy;
begin
  FSeries.OnChange := nil;
  TStringList(FLabels).OnChange := nil;
  TStringList(FColors).OnChange := nil;
  FSeries.Free;
  FLabels.Free;
  FColors.Free;
  FEngine.Free;
  inherited;
end;

function TDaisyChart.DefaultCornerRadius: Integer;
begin
  Result := 0;
end;

function TDaisyChart.DefaultShadowSize: Integer;
begin
  Result := 0;
end;

function TDaisyChart.DefaultContentPadding: Integer;
begin
  Result := 0;
end;

// The chart is transparent: it sits on a card or panel
function TDaisyChart.DefaultStyleColors(AState: TDaisyState): TDaisyColors;
begin
  Result := Default(TDaisyColors);
  Result.Text := Theme.BaseContent;
end;

procedure TDaisyChart.SizeChanged;
begin
  FEngine.Invalidate;
  Invalidate;
end;

procedure TDaisyChart.DataChanged(Sender: TObject);
begin
  FEngine.Invalidate;
  Invalidate;
end;

function TDaisyChart.MeasureChartText(const AText: string; AFontSize: Integer;
  ABold: Boolean): Single;
begin
  Result := MeasureTextWidth(AText, AFontSize, ABold);
end;

function TDaisyChart.ChartFontSize: Integer;
begin
  Result := CFontSizes[SizeKind];
end;

procedure TDaisyChart.PrepareEngine;
begin
  FEngine.ApplyTheme(Theme, ChartFontSize, ScaleValue(100) / 100);
  FEngine.LoadData(Theme, FSeries, FLabels, FColors, csDesigning in ComponentState);
  FEngine.Options.ChartType := FChartType;
  FEngine.Options.DataLabels := FDataLabels;
  FEngine.Options.ShowGrid := FShowGrid;
  FEngine.Options.ShowXAxis := FShowXAxis;
  FEngine.Options.ShowYAxis := FShowYAxis;
  FEngine.Options.ShowTooltip := FShowTooltip;
  FEngine.Options.ShowTotal := FShowTotal;
  FEngine.Options.Stacked := FStacked;
  FEngine.Options.Curve := FCurve;
  FEngine.Options.StrokeWidth := FStrokeWidth;
  FEngine.Options.MarkerSize := FMarkerSize;
  FEngine.Options.BarRadius := FBarRadius;
  FEngine.Options.HoleSize := FHoleSize;
  FEngine.Options.LegendPosition := FLegendPosition;
  FEngine.Options.ValuePrefix := FValuePrefix;
  FEngine.Options.ValueSuffix := FValueSuffix;
  FEngine.Options.TotalLabel := FTotalLabel;
end;

function TDaisyChart.TrackedItemAt(const APoint: TPoint): Integer;
begin
  if not FShowTooltip then
    Exit(-1);
  PrepareEngine;
  Result := FEngine.HitTest(ClientWidth, ClientHeight, PointF(APoint.X, APoint.Y));
end;

procedure TDaisyChart.TrackedItemChanged;
begin
  Invalidate;
end;

procedure TDaisyChart.DrawShape(AGraphics: TGPGraphics; const AShape: TDaisyChartShape);
var
  LPath: TGPGraphicsPath;
  LBrush: TGPBrush;
  LPen: TGPPen;
  LPoints: array of TGPPointF;
  LPattern: array[0..1] of Single;
  I: Integer;
begin
  SetLength(LPoints, Length(AShape.Points));
  for I := 0 to High(AShape.Points) do
    LPoints[I] := MakePoint(AShape.Points[I].X, AShape.Points[I].Y);

  case AShape.Kind of
    cskFill, cskGradient:
      begin
        if Length(LPoints) < 3 then
          Exit;
        LPath := TGPGraphicsPath.Create;
        try
          LPath.AddPolygon(PGPPointF(@LPoints[0]), Length(LPoints));
          if (AShape.Kind = cskGradient) and (AShape.Box.Height >= 1) then
            LBrush := TGPLinearGradientBrush.Create(
              MakeRect(AShape.Box.Left, AShape.Box.Top, Max(1, AShape.Box.Width), AShape.Box.Height),
              AShape.Color, AShape.Color2, LinearGradientModeVertical)
          else
            LBrush := TGPSolidBrush.Create(AShape.Color);
          try
            AGraphics.FillPath(LBrush, LPath);
          finally
            LBrush.Free;
          end;
          if (AShape.StrokeWidth > 0) and (TAlphaColorRec(AShape.StrokeColor).A > 0) then
          begin
            LPen := TGPPen.Create(AShape.StrokeColor, AShape.StrokeWidth);
            try
              LPen.SetLineJoin(LineJoinRound);
              AGraphics.DrawPath(LPen, LPath);
            finally
              LPen.Free;
            end;
          end;
        finally
          LPath.Free;
        end;
      end;
    cskLine:
      begin
        if Length(LPoints) < 2 then
          Exit;
        LPath := TGPGraphicsPath.Create;
        LPen := TGPPen.Create(AShape.Color, AShape.StrokeWidth);
        try
          LPath.AddLines(PGPPointF(@LPoints[0]), Length(LPoints));
          if AShape.Closed then
            LPath.CloseFigure;
          LPen.SetLineJoin(LineJoinRound);
          if AShape.RoundCaps then
            LPen.SetLineCap(LineCapRound, LineCapRound, DashCapRound);
          if AShape.Dashed then
          begin
            LPattern[0] := 4 / Max(1, AShape.StrokeWidth);
            LPattern[1] := 4 / Max(1, AShape.StrokeWidth);
            LPen.SetDashPattern(@LPattern[0], 2);
          end;
          AGraphics.DrawPath(LPen, LPath);
        finally
          LPen.Free;
          LPath.Free;
        end;
      end;
    cskDot:
      begin
        LBrush := TGPSolidBrush.Create(AShape.Color);
        try
          AGraphics.FillEllipse(LBrush, AShape.Box.Left, AShape.Box.Top, AShape.Box.Width,
            AShape.Box.Height);
        finally
          LBrush.Free;
        end;
        if (AShape.StrokeWidth > 0) and (TAlphaColorRec(AShape.StrokeColor).A > 0) then
        begin
          LPen := TGPPen.Create(AShape.StrokeColor, AShape.StrokeWidth);
          try
            AGraphics.DrawEllipse(LPen, AShape.Box.Left, AShape.Box.Top, AShape.Box.Width,
              AShape.Box.Height);
          finally
            LPen.Free;
          end;
        end;
      end;
  end;
end;

procedure TDaisyChart.DrawShapeText(const AShape: TDaisyChartShape);
var
  LFlags: Cardinal;
begin
  LFlags := DT_SINGLELINE or DT_VCENTER;
  case AShape.Align of
    dcaLeft: LFlags := LFlags or DT_LEFT;
    dcaCenter: LFlags := LFlags or DT_CENTER;
    dcaRight: LFlags := LFlags or DT_RIGHT;
  end;
  DrawText(AShape.Text, Rect(Floor(AShape.Box.Left), Floor(AShape.Box.Top), Ceil(AShape.Box.Right),
    Ceil(AShape.Box.Bottom)), AShape.Color, AShape.FontSize, AShape.Bold, LFlags);
end;

procedure TDaisyChart.DrawContent(const AColors: TDaisyColors; const ARect: TRect);
var
  LShapes: TArray<TDaisyChartShape>;
  LGraphics: TGPGraphics;
  I: Integer;
begin
  PrepareEngine;
  LShapes := FEngine.Build(ClientWidth, ClientHeight, TrackedItem);
  LGraphics := nil;
  try
    for I := 0 to High(LShapes) do
      if LShapes[I].Kind = cskText then
      begin
        FreeAndNil(LGraphics); // GDI+ output is flushed before GDI text is drawn over it
        DrawShapeText(LShapes[I]);
      end
      else
      begin
        if LGraphics = nil then
          LGraphics := NewGraphics;
        DrawShape(LGraphics, LShapes[I]);
      end;
  finally
    LGraphics.Free;
  end;
end;

{ Property setters }

procedure TDaisyChart.SetSeries(const AValue: TDaisyChartSeriesCollection);
begin
  FSeries.Assign(AValue);
end;

procedure TDaisyChart.SetLabels(const AValue: TStrings);
begin
  FLabels.Assign(AValue);
end;

procedure TDaisyChart.SetColors(const AValue: TStrings);
begin
  FColors.Assign(AValue);
end;

procedure TDaisyChart.SetChartType(const AValue: TDaisyChartType);
begin
  if FChartType <> AValue then
  begin
    FChartType := AValue;
    DataChanged(Self);
  end;
end;

procedure TDaisyChart.SetDataLabels(const AValue: Boolean);
begin
  if FDataLabels <> AValue then
  begin
    FDataLabels := AValue;
    DataChanged(Self);
  end;
end;

procedure TDaisyChart.SetShowGrid(const AValue: Boolean);
begin
  if FShowGrid <> AValue then
  begin
    FShowGrid := AValue;
    DataChanged(Self);
  end;
end;

procedure TDaisyChart.SetShowXAxis(const AValue: Boolean);
begin
  if FShowXAxis <> AValue then
  begin
    FShowXAxis := AValue;
    DataChanged(Self);
  end;
end;

procedure TDaisyChart.SetShowYAxis(const AValue: Boolean);
begin
  if FShowYAxis <> AValue then
  begin
    FShowYAxis := AValue;
    DataChanged(Self);
  end;
end;

procedure TDaisyChart.SetShowTooltip(const AValue: Boolean);
begin
  if FShowTooltip <> AValue then
  begin
    FShowTooltip := AValue;
    DataChanged(Self);
  end;
end;

procedure TDaisyChart.SetShowTotal(const AValue: Boolean);
begin
  if FShowTotal <> AValue then
  begin
    FShowTotal := AValue;
    DataChanged(Self);
  end;
end;

procedure TDaisyChart.SetStacked(const AValue: Boolean);
begin
  if FStacked <> AValue then
  begin
    FStacked := AValue;
    DataChanged(Self);
  end;
end;

procedure TDaisyChart.SetCurve(const AValue: TDaisyChartCurve);
begin
  if FCurve <> AValue then
  begin
    FCurve := AValue;
    DataChanged(Self);
  end;
end;

procedure TDaisyChart.SetStrokeWidth(const AValue: Integer);
begin
  if FStrokeWidth <> AValue then
  begin
    FStrokeWidth := Max(1, AValue);
    DataChanged(Self);
  end;
end;

procedure TDaisyChart.SetMarkerSize(const AValue: Integer);
begin
  if FMarkerSize <> AValue then
  begin
    FMarkerSize := Max(0, AValue);
    DataChanged(Self);
  end;
end;

procedure TDaisyChart.SetBarRadius(const AValue: Integer);
begin
  if FBarRadius <> AValue then
  begin
    FBarRadius := Max(0, AValue);
    DataChanged(Self);
  end;
end;

procedure TDaisyChart.SetHoleSize(const AValue: Integer);
begin
  if FHoleSize <> AValue then
  begin
    FHoleSize := EnsureRange(AValue, 10, 90);
    DataChanged(Self);
  end;
end;

procedure TDaisyChart.SetLegendPosition(const AValue: TDaisyChartLegendPosition);
begin
  if FLegendPosition <> AValue then
  begin
    FLegendPosition := AValue;
    DataChanged(Self);
  end;
end;

procedure TDaisyChart.SetValuePrefix(const AValue: string);
begin
  if FValuePrefix <> AValue then
  begin
    FValuePrefix := AValue;
    DataChanged(Self);
  end;
end;

procedure TDaisyChart.SetValueSuffix(const AValue: string);
begin
  if FValueSuffix <> AValue then
  begin
    FValueSuffix := AValue;
    DataChanged(Self);
  end;
end;

procedure TDaisyChart.SetTotalLabel(const AValue: string);
begin
  if FTotalLabel <> AValue then
  begin
    FTotalLabel := AValue;
    DataChanged(Self);
  end;
end;

function TDaisyChart.GetChartWidth: Integer;
begin
  Result := Width;
end;

procedure TDaisyChart.SetChartWidth(const AValue: Integer);
begin
  Width := AValue;
end;

function TDaisyChart.GetChartHeight: Integer;
begin
  Result := Height;
end;

procedure TDaisyChart.SetChartHeight(const AValue: Integer);
begin
  Height := AValue;
end;

end.
