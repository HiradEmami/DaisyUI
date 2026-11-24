unit Daisy.FMX.Chart;

{
  TDaisyFmxChart - a chart in the style of the Flowbite (ApexCharts) charts: line, area,
  column, bar, pie, donut and radial. The data lives in Series (each item holds a name,
  a comma separated Data list and an optional colour), the category or slice names in
  Labels. The layout is done by Daisy.Charts; this unit only draws the resulting shapes
  and shows the hover tooltip.
}

interface

uses
  System.SysUtils, System.Classes, System.Types, System.UITypes, System.Math,
  FMX.Types, FMX.Controls, FMX.Graphics, Daisy.Theme, Daisy.Charts, Daisy.FMX.Control;

type
  TDaisyFmxChart = class(TDaisyControl)
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
    procedure DrawShape(const AShape: TDaisyChartShape);
  protected
    function DefaultCornerRadius: Integer; override;
    function DefaultShadowSize: Integer; override;
    function DefaultContentPadding: Integer; override;
    function DefaultStyleColors(AState: TDaisyState): TDaisyColors; override;
    procedure SizeChanged; override;
    function TrackedItemAt(const APoint: TPointF): Integer; override;
    procedure DrawContent(const AColors: TDaisyColors; const ARect: TRectF); override;
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
    // Size of the chart (the same as Width and Height)
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

{ TDaisyFmxChart }

constructor TDaisyFmxChart.Create(AOwner: TComponent);
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
  SetSize(320, 220);
end;

destructor TDaisyFmxChart.Destroy;
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

function TDaisyFmxChart.DefaultCornerRadius: Integer;
begin
  Result := 0;
end;

function TDaisyFmxChart.DefaultShadowSize: Integer;
begin
  Result := 0;
end;

function TDaisyFmxChart.DefaultContentPadding: Integer;
begin
  Result := 0;
end;

// The chart is transparent: it sits on a card or panel
function TDaisyFmxChart.DefaultStyleColors(AState: TDaisyState): TDaisyColors;
begin
  Result := Default(TDaisyColors);
  Result.Text := Theme.BaseContent;
end;

procedure TDaisyFmxChart.SizeChanged;
begin
  FEngine.Invalidate;
  Repaint;
end;

procedure TDaisyFmxChart.DataChanged(Sender: TObject);
begin
  FEngine.Invalidate;
  Repaint;
end;

function TDaisyFmxChart.MeasureChartText(const AText: string; AFontSize: Integer;
  ABold: Boolean): Single;
begin
  Result := MeasureTextWidth(AText, AFontSize, ABold);
end;

function TDaisyFmxChart.ChartFontSize: Integer;
begin
  Result := CFontSizes[SizeKind];
end;

procedure TDaisyFmxChart.PrepareEngine;
begin
  FEngine.ApplyTheme(Theme, ChartFontSize, 1);
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

function TDaisyFmxChart.TrackedItemAt(const APoint: TPointF): Integer;
begin
  if not FShowTooltip then
    Exit(-1);
  PrepareEngine;
  Result := FEngine.HitTest(Width, Height, APoint);
end;

procedure TDaisyFmxChart.DrawShape(const AShape: TDaisyChartShape);
var
  LData: TPathData;
  I: Integer;
  LHorz: TTextAlign;
begin
  case AShape.Kind of
    cskFill, cskGradient, cskLine:
      begin
        if Length(AShape.Points) < 2 then
          Exit;
        LData := TPathData.Create;
        try
          LData.MoveTo(AShape.Points[0]);
          for I := 1 to High(AShape.Points) do
            LData.LineTo(AShape.Points[I]);
          if (AShape.Kind <> cskLine) or AShape.Closed then
            LData.ClosePath;
          if AShape.Kind = cskLine then
          begin
            Canvas.Stroke.Kind := TBrushKind.Solid;
            Canvas.Stroke.Color := AShape.Color;
            Canvas.Stroke.Thickness := AShape.StrokeWidth;
            Canvas.Stroke.Join := TStrokeJoin.Round;
            if AShape.RoundCaps then
              Canvas.Stroke.Cap := TStrokeCap.Round
            else
              Canvas.Stroke.Cap := TStrokeCap.Flat;
            if AShape.Dashed then
              Canvas.Stroke.Dash := TStrokeDash.Dash
            else
              Canvas.Stroke.Dash := TStrokeDash.Solid;
            Canvas.DrawPath(LData, AbsoluteOpacity);
            Canvas.Stroke.Dash := TStrokeDash.Solid;
            Canvas.Stroke.Cap := TStrokeCap.Flat;
          end
          else
          begin
            if AShape.Kind = cskGradient then
            begin
              Canvas.Fill.Kind := TBrushKind.Gradient;
              Canvas.Fill.Gradient.Style := TGradientStyle.Linear;
              Canvas.Fill.Gradient.StartPosition.Point := PointF(0, 0);
              Canvas.Fill.Gradient.StopPosition.Point := PointF(0, 1);
              Canvas.Fill.Gradient.Color := AShape.Color;
              Canvas.Fill.Gradient.Color1 := AShape.Color2;
            end
            else
            begin
              Canvas.Fill.Kind := TBrushKind.Solid;
              Canvas.Fill.Color := AShape.Color;
            end;
            Canvas.FillPath(LData, AbsoluteOpacity);
            Canvas.Fill.Kind := TBrushKind.Solid;
            if (AShape.StrokeWidth > 0) and (TAlphaColorRec(AShape.StrokeColor).A > 0) then
            begin
              Canvas.Stroke.Kind := TBrushKind.Solid;
              Canvas.Stroke.Color := AShape.StrokeColor;
              Canvas.Stroke.Thickness := AShape.StrokeWidth;
              Canvas.Stroke.Join := TStrokeJoin.Round;
              Canvas.Stroke.Dash := TStrokeDash.Solid;
              Canvas.DrawPath(LData, AbsoluteOpacity);
            end;
          end;
        finally
          LData.Free;
        end;
      end;
    cskDot:
      begin
        Canvas.Fill.Kind := TBrushKind.Solid;
        Canvas.Fill.Color := AShape.Color;
        Canvas.FillEllipse(AShape.Box, AbsoluteOpacity);
        if (AShape.StrokeWidth > 0) and (TAlphaColorRec(AShape.StrokeColor).A > 0) then
        begin
          Canvas.Stroke.Kind := TBrushKind.Solid;
          Canvas.Stroke.Color := AShape.StrokeColor;
          Canvas.Stroke.Thickness := AShape.StrokeWidth;
          Canvas.Stroke.Dash := TStrokeDash.Solid;
          Canvas.DrawEllipse(AShape.Box, AbsoluteOpacity);
        end;
      end;
    cskText:
      begin
        case AShape.Align of
          dcaLeft: LHorz := TTextAlign.Leading;
          dcaRight: LHorz := TTextAlign.Trailing;
        else
          LHorz := TTextAlign.Center;
        end;
        DrawText(AShape.Text, AShape.Box, AShape.Color, AShape.FontSize, AShape.Bold, LHorz,
          TTextAlign.Center, False);
      end;
  end;
end;

procedure TDaisyFmxChart.DrawContent(const AColors: TDaisyColors; const ARect: TRectF);
var
  LShapes: TArray<TDaisyChartShape>;
  I: Integer;
begin
  PrepareEngine;
  LShapes := FEngine.Build(Width, Height, TrackedItem);
  for I := 0 to High(LShapes) do
    DrawShape(LShapes[I]);
end;

{ Property setters }

procedure TDaisyFmxChart.SetSeries(const AValue: TDaisyChartSeriesCollection);
begin
  FSeries.Assign(AValue);
end;

procedure TDaisyFmxChart.SetLabels(const AValue: TStrings);
begin
  FLabels.Assign(AValue);
end;

procedure TDaisyFmxChart.SetColors(const AValue: TStrings);
begin
  FColors.Assign(AValue);
end;

procedure TDaisyFmxChart.SetChartType(const AValue: TDaisyChartType);
begin
  if FChartType <> AValue then
  begin
    FChartType := AValue;
    DataChanged(Self);
  end;
end;

procedure TDaisyFmxChart.SetDataLabels(const AValue: Boolean);
begin
  if FDataLabels <> AValue then
  begin
    FDataLabels := AValue;
    DataChanged(Self);
  end;
end;

procedure TDaisyFmxChart.SetShowGrid(const AValue: Boolean);
begin
  if FShowGrid <> AValue then
  begin
    FShowGrid := AValue;
    DataChanged(Self);
  end;
end;

procedure TDaisyFmxChart.SetShowXAxis(const AValue: Boolean);
begin
  if FShowXAxis <> AValue then
  begin
    FShowXAxis := AValue;
    DataChanged(Self);
  end;
end;

procedure TDaisyFmxChart.SetShowYAxis(const AValue: Boolean);
begin
  if FShowYAxis <> AValue then
  begin
    FShowYAxis := AValue;
    DataChanged(Self);
  end;
end;

procedure TDaisyFmxChart.SetShowTooltip(const AValue: Boolean);
begin
  if FShowTooltip <> AValue then
  begin
    FShowTooltip := AValue;
    DataChanged(Self);
  end;
end;

procedure TDaisyFmxChart.SetShowTotal(const AValue: Boolean);
begin
  if FShowTotal <> AValue then
  begin
    FShowTotal := AValue;
    DataChanged(Self);
  end;
end;

procedure TDaisyFmxChart.SetStacked(const AValue: Boolean);
begin
  if FStacked <> AValue then
  begin
    FStacked := AValue;
    DataChanged(Self);
  end;
end;

procedure TDaisyFmxChart.SetCurve(const AValue: TDaisyChartCurve);
begin
  if FCurve <> AValue then
  begin
    FCurve := AValue;
    DataChanged(Self);
  end;
end;

procedure TDaisyFmxChart.SetStrokeWidth(const AValue: Integer);
begin
  if FStrokeWidth <> AValue then
  begin
    FStrokeWidth := Max(1, AValue);
    DataChanged(Self);
  end;
end;

procedure TDaisyFmxChart.SetMarkerSize(const AValue: Integer);
begin
  if FMarkerSize <> AValue then
  begin
    FMarkerSize := Max(0, AValue);
    DataChanged(Self);
  end;
end;

procedure TDaisyFmxChart.SetBarRadius(const AValue: Integer);
begin
  if FBarRadius <> AValue then
  begin
    FBarRadius := Max(0, AValue);
    DataChanged(Self);
  end;
end;

procedure TDaisyFmxChart.SetHoleSize(const AValue: Integer);
begin
  if FHoleSize <> AValue then
  begin
    FHoleSize := EnsureRange(AValue, 10, 90);
    DataChanged(Self);
  end;
end;

procedure TDaisyFmxChart.SetLegendPosition(const AValue: TDaisyChartLegendPosition);
begin
  if FLegendPosition <> AValue then
  begin
    FLegendPosition := AValue;
    DataChanged(Self);
  end;
end;

procedure TDaisyFmxChart.SetValuePrefix(const AValue: string);
begin
  if FValuePrefix <> AValue then
  begin
    FValuePrefix := AValue;
    DataChanged(Self);
  end;
end;

procedure TDaisyFmxChart.SetValueSuffix(const AValue: string);
begin
  if FValueSuffix <> AValue then
  begin
    FValueSuffix := AValue;
    DataChanged(Self);
  end;
end;

procedure TDaisyFmxChart.SetTotalLabel(const AValue: string);
begin
  if FTotalLabel <> AValue then
  begin
    FTotalLabel := AValue;
    DataChanged(Self);
  end;
end;

function TDaisyFmxChart.GetChartWidth: Integer;
begin
  Result := Round(Width);
end;

procedure TDaisyFmxChart.SetChartWidth(const AValue: Integer);
begin
  Width := AValue;
end;

function TDaisyFmxChart.GetChartHeight: Integer;
begin
  Result := Round(Height);
end;

procedure TDaisyFmxChart.SetChartHeight(const AValue: Integer);
begin
  Height := AValue;
end;

end.
