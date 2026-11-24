unit Daisy.Charts;

{
  Framework neutral chart engine shared by TDaisyChart (VCL) and TDaisyFmxChart (FMX).
  It follows the ApexCharts model used by Flowbite: a chart type, a list of series,
  category labels and a handful of options. The engine only turns that data into a flat
  list of shapes (filled polygons, polylines, dots and text); each framework draws the
  shapes with its own canvas. Must not reference Vcl.* or FMX.* units.
}

interface

uses
  System.SysUtils, System.Classes, System.Types, System.UITypes, System.Math,
  System.Generics.Collections, Daisy.Theme;

type
  TDaisyChartType = (dctLine, dctArea, dctColumn, dctBar, dctPie, dctDonut, dctRadial);
  TDaisyChartCurve = (dccSmooth, dccStraight, dccStepline);
  TDaisyChartLegendPosition = (dlpNone, dlpTop, dlpBottom, dlpLeft, dlpRight);

  // One data series of a chart. Data is a list of numbers such as "6500, 6418, 6456".
  TDaisyChartSeriesItem = class(TCollectionItem)
  strict private
    FName: string;
    FData: string;
    FColor: string;
    FVariant: TDaisyVariant;
    FValues: TArray<Double>;
    FParsed: Boolean;
    procedure SetName(const AValue: string);
    procedure SetData(const AValue: string);
    procedure SetColor(const AValue: string);
    procedure SetVariant(const AValue: TDaisyVariant);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(ACollection: TCollection); override;
    procedure Assign(ASource: TPersistent); override;
    // The parsed Data; a value that is not a number (e.g. null) is NaN and leaves a gap
    function Values: TArray<Double>;
    procedure SetValues(const AValues: array of Double);
  published
    property Name: string read FName write SetName;
    property Data: string read FData write SetData;
    // HTML colour such as #1C64F2; empty uses Variant, then the automatic palette
    property Color: string read FColor write SetColor;
    property Variant: TDaisyVariant read FVariant write SetVariant default dvDefault;
  end;

  TDaisyChartSeriesCollection = class(TOwnedCollection)
  strict private
    FOnChange: TNotifyEvent;
    function GetItem(AIndex: Integer): TDaisyChartSeriesItem;
    procedure SetItem(AIndex: Integer; const AValue: TDaisyChartSeriesItem);
  protected
    procedure Update(AItem: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TDaisyChartSeriesItem;
    property Items[AIndex: Integer]: TDaisyChartSeriesItem read GetItem write SetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TDaisyChartShapeKind = (cskFill, cskGradient, cskLine, cskDot, cskText);
  TDaisyChartTextAlign = (dcaLeft, dcaCenter, dcaRight);

  TDaisyChartShape = record
    Kind: TDaisyChartShapeKind;
    Points: TArray<TPointF>;
    Closed: Boolean;
    Color: TAlphaColor;       // fill, line or text colour; the top colour of a gradient
    Color2: TAlphaColor;      // bottom colour of a gradient
    StrokeColor: TAlphaColor; // outline of a fill or dot
    StrokeWidth: Single;      // line width, or outline width of a fill or dot
    Dashed: Boolean;
    RoundCaps: Boolean;
    Box: TRectF;              // text box, gradient bounds or dot bounds
    Text: string;
    Align: TDaisyChartTextAlign;
    FontSize: Integer;
    Bold: Boolean;
  end;

  TDaisyChartOptions = record
    ChartType: TDaisyChartType;
    DataLabels: Boolean;
    ShowGrid: Boolean;
    ShowXAxis: Boolean;
    ShowYAxis: Boolean;
    ShowTooltip: Boolean;
    ShowTotal: Boolean;
    Stacked: Boolean;
    Curve: TDaisyChartCurve;
    StrokeWidth: Integer;
    MarkerSize: Integer;
    BarRadius: Integer;
    HoleSize: Integer;
    LegendPosition: TDaisyChartLegendPosition;
    ValuePrefix: string;
    ValueSuffix: string;
    TotalLabel: string;
  end;

  TDaisyChartStyle = record
    TextColor, MutedColor, GridColor, SurfaceColor, TrackColor: TAlphaColor;
    TooltipBack, TooltipBorder: TAlphaColor;
    FontSize: Integer; // logical size; the framework scales it when drawing
    Scale: Single;     // converts logical units to pixels for the geometry
  end;

  TDaisyChartSeriesData = record
    Name: string;
    Color: TAlphaColor;
    Values: TArray<Double>;
  end;

  TDaisyChartLegendItem = record
    Text: string;
    Color: TAlphaColor;
    Dot: TPointF;
    TextBox: TRectF;
  end;

  TDaisyChartSlice = record
    Name: string;
    Color: TAlphaColor;
    Value: Double;
    From, To_: Double; // fractions of the full circle
  end;

  TDaisyChartTipRow = record
    Color: TAlphaColor;
    Text: string;
  end;

  // Measures text in pixels for a logical font size
  TDaisyChartMeasure = function(const AText: string; AFontSize: Integer;
    ABold: Boolean): Single of object;

  TDaisyChartEngine = class
  strict private
    FW, FH: Single;
    FLaidOut: Boolean;
    FShapes: TArray<TDaisyChartShape>;
    FCount: Integer;
    FLegend: TArray<TDaisyChartLegendItem>;
    FArea: TRectF;
    FPlot: TRectF;
    FCats: Integer;
    FInset: Single;
    FAxMin, FAxMax, FAxStart, FAxStep: Double;
    FTickCount: Integer;
    FHi, FLo: TArray<TArray<Double>>;
    FSlices: TArray<TDaisyChartSlice>;
    FCenter: TPointF;
    FOuter, FInner, FThick: Single;
    function Px(AValue: Single): Single;
    function LineH(AFontSize: Integer): Single;
    function TextW(const AText: string; AFontSize: Integer; ABold: Boolean): Single;
    function IsRound: Boolean;
    function IsHorizontal: Boolean;
    function FmtValue(AValue: Double): string;
    function CategoryText(AIndex: Integer): string;
    procedure Push(const AShape: TDaisyChartShape);
    procedure AddFill(const APoints: TArray<TPointF>; AColor, AStroke: TAlphaColor;
      AStrokeWidth: Single);
    procedure AddGradient(const APoints: TArray<TPointF>; ATop, ABottom: TAlphaColor;
      const ABox: TRectF);
    procedure AddLine(const APoints: TArray<TPointF>; AColor: TAlphaColor; AWidth: Single;
      ADashed, ARound, AClosed: Boolean);
    procedure AddDot(ACx, ACy, ARadius: Single; AFill, AStroke: TAlphaColor; AStrokeWidth: Single);
    procedure AddText(const AText: string; const ABox: TRectF; AAlign: TDaisyChartTextAlign;
      AFontSize: Integer; ABold: Boolean; AColor: TAlphaColor);
    procedure AddTooltip(const AHeader: string; const ARows: TArray<TDaisyChartTipRow>;
      const AAnchor: TPointF);
    procedure CollectSlices;
    procedure LayoutLegend;
    procedure LayoutCartesian;
    procedure LayoutRound;
    procedure ComputeLayout(AWidth, AHeight: Single);
    function ValPos(AValue: Double): Single;
    function CatPos(AIndex: Integer): Single;
    function BandSize: Single;
    function IsLastInStack(ASeries, AIndex: Integer): Boolean;
    function CurvePoints(const APoints: TArray<TPointF>): TArray<TPointF>;
    procedure BuildLegend;
    procedure BuildCartesian(AHover: Integer);
    procedure BuildBars(AHover: Integer);
    procedure BuildLines(AHover: Integer);
    procedure BuildRound(AHover: Integer);
  public
    Options: TDaisyChartOptions;
    Style: TDaisyChartStyle;
    Series: TArray<TDaisyChartSeriesData>;
    Labels: TArray<string>;
    // Colours used for the points of a pie, donut or radial chart
    Palette: TArray<TAlphaColor>;
    Measure: TDaisyChartMeasure;
    procedure Invalidate;
    // Takes colours from the theme
    procedure ApplyTheme(const ATheme: TDaisyTheme; AFontSize: Integer; AScale: Single);
    // Takes the series, labels and colours of a chart control. An empty chart shows
    // example data when ASample is True (design time).
    procedure LoadData(const ATheme: TDaisyTheme; ASeries: TDaisyChartSeriesCollection;
      ALabels, AColors: TStrings;       ASample: Boolean);
    procedure ApplySample;
    function Build(AWidth, AHeight: Single; AHover: Integer): TArray<TDaisyChartShape>;
    // The category (or slice, or ring) under APoint, or -1
    function HitTest(AWidth, AHeight: Single; const APoint: TPointF): Integer;
  end;

function DaisyChartParseNumbers(const AText: string): TArray<Double>;
function DaisyChartParseColor(const AText: string; out AColor: TAlphaColor): Boolean;
function DaisyChartFormat(AValue: Double; ADecimals: Integer): string;

implementation

const
  CAutoPalette: array[0..6] of TDaisyVariant = (dvPrimary, dvSecondary, dvAccent, dvInfo,
    dvSuccess, dvWarning, dvError);

function DaisyChartFormat(AValue: Double; ADecimals: Integer): string;
begin
  if IsNan(AValue) then
    Exit('');
  Result := FloatToStrF(AValue, ffFixed, 18, ADecimals, TFormatSettings.Invariant);
  if Pos('.', Result) > 0 then
  begin
    while Result.EndsWith('0') do
      Delete(Result, Length(Result), 1);
    if Result.EndsWith('.') then
      Delete(Result, Length(Result), 1);
  end;
  if Result = '-0' then
    Result := '0';
end;

function DaisyChartParseNumbers(const AText: string): TArray<Double>;
var
  LToken: string;
  LValue: Double;
  I: Integer;

  procedure Flush;
  begin
    if LToken = '' then
      Exit;
    SetLength(Result, Length(Result) + 1);
    if TryStrToFloat(LToken, LValue, TFormatSettings.Invariant) then
      Result[High(Result)] := LValue
    else
      Result[High(Result)] := NaN;
    LToken := '';
  end;

begin
  Result := nil;
  LToken := '';
  for I := 1 to Length(AText) do
    if CharInSet(AText[I], [',', ';', ' ', #9, #10, #13]) then
      Flush
    else
      LToken := LToken + AText[I];
  Flush;
end;

function DaisyChartParseColor(const AText: string; out AColor: TAlphaColor): Boolean;
var
  LText: string;
  LValue: Int64;
begin
  Result := False;
  LText := Trim(AText);
  if LText.StartsWith('#') then
    Delete(LText, 1, 1);
  if Length(LText) = 3 then
    LText := LText[1] + LText[1] + LText[2] + LText[2] + LText[3] + LText[3];
  if Length(LText) <> 6 then
    Exit;
  if not TryStrToInt64('$' + LText, LValue) then
    Exit;
  AColor := TAlphaColor($FF000000 or Cardinal(LValue));
  Result := True;
end;

{ TDaisyChartSeriesItem }

constructor TDaisyChartSeriesItem.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FVariant := dvDefault;
end;

procedure TDaisyChartSeriesItem.Assign(ASource: TPersistent);
begin
  if ASource is TDaisyChartSeriesItem then
  begin
    FName := TDaisyChartSeriesItem(ASource).FName;
    FData := TDaisyChartSeriesItem(ASource).FData;
    FColor := TDaisyChartSeriesItem(ASource).FColor;
    FVariant := TDaisyChartSeriesItem(ASource).FVariant;
    FParsed := False;
    Changed(False);
  end
  else
    inherited Assign(ASource);
end;

function TDaisyChartSeriesItem.GetDisplayName: string;
begin
  if FName <> '' then
    Result := FName
  else
    Result := inherited GetDisplayName;
end;

function TDaisyChartSeriesItem.Values: TArray<Double>;
begin
  if not FParsed then
  begin
    FValues := DaisyChartParseNumbers(FData);
    FParsed := True;
  end;
  Result := FValues;
end;

procedure TDaisyChartSeriesItem.SetValues(const AValues: array of Double);
var
  LText: string;
  I: Integer;
begin
  LText := '';
  for I := 0 to High(AValues) do
  begin
    if I > 0 then
      LText := LText + ', ';
    if IsNan(AValues[I]) then
      LText := LText + 'null'
    else
      LText := LText + DaisyChartFormat(AValues[I], 6);
  end;
  SetData(LText);
end;

procedure TDaisyChartSeriesItem.SetName(const AValue: string);
begin
  if FName <> AValue then
  begin
    FName := AValue;
    Changed(False);
  end;
end;

procedure TDaisyChartSeriesItem.SetData(const AValue: string);
begin
  if FData <> AValue then
  begin
    FData := AValue;
    FParsed := False;
    Changed(False);
  end;
end;

procedure TDaisyChartSeriesItem.SetColor(const AValue: string);
begin
  if FColor <> AValue then
  begin
    FColor := AValue;
    Changed(False);
  end;
end;

procedure TDaisyChartSeriesItem.SetVariant(const AValue: TDaisyVariant);
begin
  if FVariant <> AValue then
  begin
    FVariant := AValue;
    Changed(False);
  end;
end;

{ TDaisyChartSeriesCollection }

constructor TDaisyChartSeriesCollection.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TDaisyChartSeriesItem);
end;

function TDaisyChartSeriesCollection.Add: TDaisyChartSeriesItem;
begin
  Result := TDaisyChartSeriesItem(inherited Add);
end;

function TDaisyChartSeriesCollection.GetItem(AIndex: Integer): TDaisyChartSeriesItem;
begin
  Result := TDaisyChartSeriesItem(inherited GetItem(AIndex));
end;

procedure TDaisyChartSeriesCollection.SetItem(AIndex: Integer;
  const AValue: TDaisyChartSeriesItem);
begin
  inherited SetItem(AIndex, AValue);
end;

procedure TDaisyChartSeriesCollection.Update(AItem: TCollectionItem);
begin
  inherited Update(AItem);
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

{ Geometry helpers }

procedure AddArcPoints(AList: TList<TPointF>; ACx, ACy, ARadius, AFrom, ATo: Single);
var
  LSteps, I: Integer;
  LAngle: Single;
begin
  LSteps := Max(2, Ceil(Abs(ATo - AFrom) / 4));
  for I := 0 to LSteps do
  begin
    LAngle := DegToRad(AFrom + (ATo - AFrom) * I / LSteps);
    AList.Add(PointF(ACx + ARadius * Cos(LAngle), ACy + ARadius * Sin(LAngle)));
  end;
end;

function ArcPolyline(ACx, ACy, ARadius, AFrom, ATo: Single): TArray<TPointF>;
var
  LList: TList<TPointF>;
begin
  LList := TList<TPointF>.Create;
  try
    AddArcPoints(LList, ACx, ACy, ARadius, AFrom, ATo);
    Result := LList.ToArray;
  finally
    LList.Free;
  end;
end;

// Each corner takes its own radius; 0 keeps it square
function RoundRectPoly(const ARect: TRectF; ATL, ATR, ABR, ABL: Single): TArray<TPointF>;
var
  LList: TList<TPointF>;

  procedure Corner(ACx, ACy, ARadius, AFrom: Single; AX, AY: Single);
  begin
    if ARadius > 0.5 then
      AddArcPoints(LList, ACx, ACy, ARadius, AFrom, AFrom + 90)
    else
      LList.Add(PointF(AX, AY));
  end;

begin
  LList := TList<TPointF>.Create;
  try
    Corner(ARect.Left + ATL, ARect.Top + ATL, ATL, 180, ARect.Left, ARect.Top);
    Corner(ARect.Right - ATR, ARect.Top + ATR, ATR, 270, ARect.Right, ARect.Top);
    Corner(ARect.Right - ABR, ARect.Bottom - ABR, ABR, 0, ARect.Right, ARect.Bottom);
    Corner(ARect.Left + ABL, ARect.Bottom - ABL, ABL, 90, ARect.Left, ARect.Bottom);
    Result := LList.ToArray;
  finally
    LList.Free;
  end;
end;

function NiceNum(AValue: Double; ARound: Boolean): Double;
var
  LExp: Integer;
  LFrac: Double;
begin
  if AValue <= 0 then
    Exit(1);
  LExp := Floor(Log10(AValue));
  LFrac := AValue / Power(10, LExp);
  if ARound then
  begin
    if LFrac < 1.5 then
      LFrac := 1
    else if LFrac < 3 then
      LFrac := 2
    else if LFrac < 7 then
      LFrac := 5
    else
      LFrac := 10;
  end
  else
  begin
    if LFrac <= 1 then
      LFrac := 1
    else if LFrac <= 2 then
      LFrac := 2
    else if LFrac <= 5 then
      LFrac := 5
    else
      LFrac := 10;
  end;
  Result := LFrac * Power(10, LExp);
end;

procedure NiceScale(AMin, AMax: Double; ATarget: Integer; out AStart, AStep: Double;
  out ACount: Integer);
var
  LRange, LLast: Double;
begin
  if AMax <= AMin then
  begin
    if AMax = 0 then
      AMax := 1
    else
      AMax := AMin + Abs(AMin) * 0.1;
  end;
  LRange := NiceNum(AMax - AMin, False);
  AStep := NiceNum(LRange / (ATarget - 1), True);
  AStart := Floor(AMin / AStep + 1E-9) * AStep;
  LLast := Ceil(AMax / AStep - 1E-9) * AStep;
  ACount := Max(2, Round((LLast - AStart) / AStep) + 1);
end;

function ContrastColor(AColor: TAlphaColor): TAlphaColor;
var
  LRec: TAlphaColorRec;
begin
  LRec := TAlphaColorRec(AColor);
  if 0.299 * LRec.R + 0.587 * LRec.G + 0.114 * LRec.B > 160 then
    Result := $FF111827
  else
    Result := $FFFFFFFF;
end;

{ TDaisyChartEngine }

procedure TDaisyChartEngine.Invalidate;
begin
  FLaidOut := False;
end;

function TDaisyChartEngine.Px(AValue: Single): Single;
begin
  Result := AValue * Style.Scale;
end;

function TDaisyChartEngine.LineH(AFontSize: Integer): Single;
begin
  Result := AFontSize * Style.Scale * 1.35;
end;

function TDaisyChartEngine.TextW(const AText: string; AFontSize: Integer; ABold: Boolean): Single;
begin
  if AText = '' then
    Exit(0);
  if Assigned(Measure) then
    Result := Measure(AText, AFontSize, ABold)
  else
    Result := Length(AText) * AFontSize * Style.Scale * 0.55;
end;

function TDaisyChartEngine.IsRound: Boolean;
begin
  Result := Options.ChartType in [dctPie, dctDonut, dctRadial];
end;

function TDaisyChartEngine.IsHorizontal: Boolean;
begin
  Result := Options.ChartType = dctBar;
end;

function TDaisyChartEngine.FmtValue(AValue: Double): string;
begin
  Result := Options.ValuePrefix + DaisyChartFormat(AValue, 2) + Options.ValueSuffix;
end;

function TDaisyChartEngine.CategoryText(AIndex: Integer): string;
begin
  if (AIndex >= 0) and (AIndex < Length(Labels)) then
    Result := Labels[AIndex]
  else
    Result := IntToStr(AIndex + 1);
end;

procedure TDaisyChartEngine.ApplyTheme(const ATheme: TDaisyTheme; AFontSize: Integer;
  AScale: Single);
begin
  Style.TextColor := ATheme.BaseContent;
  Style.MutedColor := DaisyWithAlpha(ATheme.BaseContent, 0.65);
  Style.GridColor := DaisyWithAlpha(ATheme.BaseContent, 0.18);
  Style.SurfaceColor := ATheme.Base100;
  Style.TrackColor := DaisyWithAlpha(ATheme.BaseContent, 0.1);
  Style.TooltipBack := ATheme.Base100;
  Style.TooltipBorder := ATheme.Base300;
  Style.FontSize := AFontSize;
  Style.Scale := AScale;
  Invalidate;
end;

procedure TDaisyChartEngine.LoadData(const ATheme: TDaisyTheme; ASeries: TDaisyChartSeriesCollection;
  ALabels, AColors: TStrings; ASample: Boolean);
var
  I: Integer;
  LColor: TAlphaColor;
  LItem: TDaisyChartSeriesItem;
begin
  Palette := nil;
  for I := 0 to AColors.Count - 1 do
    if DaisyChartParseColor(AColors[I], LColor) then
    begin
      SetLength(Palette, Length(Palette) + 1);
      Palette[High(Palette)] := LColor;
    end;
  if Length(Palette) = 0 then
  begin
    SetLength(Palette, Length(CAutoPalette));
    for I := 0 to High(CAutoPalette) do
      Palette[I] := DaisyVariantPalette(ATheme, CAutoPalette[I]).Fill;
  end;

  SetLength(Series, ASeries.Count);
  for I := 0 to ASeries.Count - 1 do
  begin
    LItem := ASeries[I];
    Series[I].Name := LItem.Name;
    Series[I].Values := LItem.Values;
    if not DaisyChartParseColor(LItem.Color, LColor) then
    begin
      if LItem.Variant <> dvDefault then
        LColor := DaisyVariantPalette(ATheme, LItem.Variant).Fill
      else
        LColor := Palette[I mod Length(Palette)];
    end;
    Series[I].Color := LColor;
  end;
  SetLength(Labels, ALabels.Count);
  for I := 0 to ALabels.Count - 1 do
    Labels[I] := ALabels[I];
  if ASample and (Length(Series) = 0) then
    ApplySample;
  Invalidate;
end;

procedure TDaisyChartEngine.ApplySample;

  procedure AddSeries(const AName: string; const AValues: array of Double);
  var
    LColor: TAlphaColor;
    LIndex: Integer;
  begin
    SetLength(Series, Length(Series) + 1);
    Series[High(Series)].Name := AName;
    LColor := $FF3B82F6;
    if Length(Palette) > 0 then
      LColor := Palette[High(Series) mod Length(Palette)];
    Series[High(Series)].Color := LColor;
    SetLength(Series[High(Series)].Values, Length(AValues));
    for LIndex := 0 to High(AValues) do
      Series[High(Series)].Values[LIndex] := AValues[LIndex];
  end;

begin
  Series := nil;
  Invalidate;
  case Options.ChartType of
    dctPie, dctDonut:
      begin
        Labels := ['Direct', 'Sponsor', 'Affiliate'];
        AddSeries('Share', [52.8, 26.8, 20.4]);
      end;
    dctRadial:
      begin
        Labels := ['Done', 'In progress', 'To do'];
        AddSeries('Tasks', [90, 85, 70]);
      end;
  else
    Labels := ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    AddSeries('Series 1', [30, 45, 38, 60, 52, 70]);
    AddSeries('Series 2', [20, 32, 41, 35, 48, 55]);
  end;
end;

{ Shapes }

procedure TDaisyChartEngine.Push(const AShape: TDaisyChartShape);
begin
  if FCount = Length(FShapes) then
    SetLength(FShapes, Max(64, FCount * 2));
  FShapes[FCount] := AShape;
  Inc(FCount);
end;

procedure TDaisyChartEngine.AddFill(const APoints: TArray<TPointF>; AColor, AStroke: TAlphaColor;
  AStrokeWidth: Single);
var
  LShape: TDaisyChartShape;
begin
  LShape := Default(TDaisyChartShape);
  LShape.Kind := cskFill;
  LShape.Points := APoints;
  LShape.Color := AColor;
  LShape.StrokeColor := AStroke;
  LShape.StrokeWidth := AStrokeWidth;
  Push(LShape);
end;

procedure TDaisyChartEngine.AddGradient(const APoints: TArray<TPointF>; ATop, ABottom: TAlphaColor;
  const ABox: TRectF);
var
  LShape: TDaisyChartShape;
begin
  LShape := Default(TDaisyChartShape);
  LShape.Kind := cskGradient;
  LShape.Points := APoints;
  LShape.Color := ATop;
  LShape.Color2 := ABottom;
  LShape.Box := ABox;
  Push(LShape);
end;

procedure TDaisyChartEngine.AddLine(const APoints: TArray<TPointF>; AColor: TAlphaColor;
  AWidth: Single; ADashed, ARound, AClosed: Boolean);
var
  LShape: TDaisyChartShape;
begin
  LShape := Default(TDaisyChartShape);
  LShape.Kind := cskLine;
  LShape.Points := APoints;
  LShape.Color := AColor;
  LShape.StrokeWidth := AWidth;
  LShape.Dashed := ADashed;
  LShape.RoundCaps := ARound;
  LShape.Closed := AClosed;
  Push(LShape);
end;

procedure TDaisyChartEngine.AddDot(ACx, ACy, ARadius: Single; AFill, AStroke: TAlphaColor;
  AStrokeWidth: Single);
var
  LShape: TDaisyChartShape;
begin
  LShape := Default(TDaisyChartShape);
  LShape.Kind := cskDot;
  LShape.Box := RectF(ACx - ARadius, ACy - ARadius, ACx + ARadius, ACy + ARadius);
  LShape.Color := AFill;
  LShape.StrokeColor := AStroke;
  LShape.StrokeWidth := AStrokeWidth;
  Push(LShape);
end;

procedure TDaisyChartEngine.AddText(const AText: string; const ABox: TRectF;
  AAlign: TDaisyChartTextAlign; AFontSize: Integer; ABold: Boolean; AColor: TAlphaColor);
var
  LShape: TDaisyChartShape;
begin
  if AText = '' then
    Exit;
  LShape := Default(TDaisyChartShape);
  LShape.Kind := cskText;
  LShape.Text := AText;
  LShape.Box := ABox;
  LShape.Align := AAlign;
  LShape.FontSize := AFontSize;
  LShape.Bold := ABold;
  LShape.Color := AColor;
  Push(LShape);
end;

procedure TDaisyChartEngine.AddTooltip(const AHeader: string;
  const ARows: TArray<TDaisyChartTipRow>; const AAnchor: TPointF);
var
  LFs: Integer;
  LPad, LRowH, LDot, LW, LH, LX, LY, LRowW, LTop: Single;
  LBox: TRectF;
  I: Integer;
begin
  if Length(ARows) = 0 then
    Exit;
  LFs := Style.FontSize;
  LPad := Px(8);
  LRowH := LineH(LFs) + Px(2);
  LDot := Px(8);
  LW := 0;
  LH := LPad * 2 + Length(ARows) * LRowH;
  if AHeader <> '' then
  begin
    LW := TextW(AHeader, LFs, True);
    LH := LH + LRowH;
  end;
  for I := 0 to High(ARows) do
  begin
    LRowW := TextW(ARows[I].Text, LFs, False);
    if TAlphaColorRec(ARows[I].Color).A > 0 then
      LRowW := LRowW + LDot + Px(6);
    LW := Max(LW, LRowW);
  end;
  LW := LW + LPad * 2 + Px(2);

  LX := AAnchor.X + Px(14);
  if LX + LW > FW - Px(4) then
    LX := AAnchor.X - Px(14) - LW;
  LX := Max(Px(4), LX);
  LY := Max(Px(4), Min(FH - LH - Px(4), AAnchor.Y - LH / 2));
  LBox := RectF(LX, LY, LX + LW, LY + LH);

  AddFill(RoundRectPoly(RectF(LBox.Left, LBox.Top + Px(2), LBox.Right, LBox.Bottom + Px(2)),
    Px(8), Px(8), Px(8), Px(8)), $22000000, 0, 0);
  AddFill(RoundRectPoly(LBox, Px(8), Px(8), Px(8), Px(8)), Style.TooltipBack,
    Style.TooltipBorder, 1);

  LTop := LBox.Top + LPad;
  if AHeader <> '' then
  begin
    AddText(AHeader, RectF(LBox.Left + LPad, LTop, LBox.Right - LPad, LTop + LRowH), dcaLeft,
      LFs, True, Style.TextColor);
    LTop := LTop + LRowH;
  end;
  for I := 0 to High(ARows) do
  begin
    LX := LBox.Left + LPad;
    if TAlphaColorRec(ARows[I].Color).A > 0 then
    begin
      AddDot(LX + LDot / 2, LTop + LRowH / 2, LDot / 2, ARows[I].Color, 0, 0);
      LX := LX + LDot + Px(6);
    end;
    AddText(ARows[I].Text, RectF(LX, LTop, LBox.Right - LPad, LTop + LRowH), dcaLeft, LFs, False,
      Style.TextColor);
    LTop := LTop + LRowH;
  end;
end;

{ Layout }

procedure TDaisyChartEngine.CollectSlices;
var
  LValues: TArray<Double>;
  I, J, LPal: Integer;
  LTotal, LAcc: Double;
begin
  FSlices := nil;
  if Length(Series) = 0 then
    Exit;
  if Length(Series) = 1 then
  begin
    LValues := Series[0].Values;
    SetLength(FSlices, Length(LValues));
    for I := 0 to High(LValues) do
    begin
      FSlices[I].Value := LValues[I];
      if I < Length(Labels) then
        FSlices[I].Name := Labels[I]
      else
        FSlices[I].Name := Series[0].Name + ' ' + IntToStr(I + 1);
      if Length(Palette) > 0 then
        LPal := I mod Length(Palette)
      else
        LPal := -1;
      if LPal >= 0 then
        FSlices[I].Color := Palette[LPal]
      else
        FSlices[I].Color := $FF3B82F6;
    end;
  end
  else
  begin
    SetLength(FSlices, Length(Series));
    for I := 0 to High(Series) do
    begin
      FSlices[I].Name := Series[I].Name;
      FSlices[I].Color := Series[I].Color;
      FSlices[I].Value := 0;
      for J := 0 to High(Series[I].Values) do
        if not IsNan(Series[I].Values[J]) then
          FSlices[I].Value := FSlices[I].Value + Series[I].Values[J];
    end;
  end;
  LTotal := 0;
  for I := 0 to High(FSlices) do
  begin
    if IsNan(FSlices[I].Value) or (FSlices[I].Value < 0) then
      FSlices[I].Value := 0;
    LTotal := LTotal + FSlices[I].Value;
  end;
  LAcc := 0;
  for I := 0 to High(FSlices) do
  begin
    FSlices[I].From := LAcc;
    if LTotal > 0 then
      LAcc := LAcc + FSlices[I].Value / LTotal;
    FSlices[I].To_ := LAcc;
  end;
end;

procedure TDaisyChartEngine.LayoutLegend;
var
  LCount, LRows, LRow, I: Integer;
  LFs: Integer;
  LDot, LGap, LItemGap, LRowH, LMaxW, LBlockH, LBlockW, LY0, LX: Single;
  LW, LItemX, LRowW: TArray<Single>;
  LRowOf: TArray<Integer>;
  LHorizontal: Boolean;
begin
  FLegend := nil;
  if Options.LegendPosition = dlpNone then
    Exit;
  if IsRound then
  begin
    SetLength(FLegend, Length(FSlices));
    for I := 0 to High(FSlices) do
    begin
      FLegend[I].Text := FSlices[I].Name;
      FLegend[I].Color := FSlices[I].Color;
    end;
  end
  else
  begin
    SetLength(FLegend, Length(Series));
    for I := 0 to High(Series) do
    begin
      if Series[I].Name <> '' then
        FLegend[I].Text := Series[I].Name
      else
        FLegend[I].Text := 'Series ' + IntToStr(I + 1);
      FLegend[I].Color := Series[I].Color;
    end;
  end;
  LCount := Length(FLegend);
  if LCount = 0 then
    Exit;

  LFs := Style.FontSize + 1;
  LDot := Px(10);
  LGap := Px(6);
  LItemGap := Px(16);
  LRowH := LineH(LFs);
  SetLength(LW, LCount);
  SetLength(LItemX, LCount);
  SetLength(LRowW, LCount);
  SetLength(LRowOf, LCount);
  for I := 0 to LCount - 1 do
    LW[I] := LDot + LGap + TextW(FLegend[I].Text, LFs, False) + Px(2);

  LHorizontal := Options.LegendPosition in [dlpTop, dlpBottom];
  if LHorizontal then
  begin
    LMaxW := FArea.Width;
    LRows := 0;
    LRowW[0] := 0;
    for I := 0 to LCount - 1 do
    begin
      if (LRowW[LRows] > 0) and (LRowW[LRows] + LItemGap + LW[I] > LMaxW) then
      begin
        Inc(LRows);
        LRowW[LRows] := 0;
      end;
      if LRowW[LRows] > 0 then
        LRowW[LRows] := LRowW[LRows] + LItemGap;
      LItemX[I] := LRowW[LRows];
      LRowW[LRows] := LRowW[LRows] + LW[I];
      LRowOf[I] := LRows;
    end;
    Inc(LRows);
    LBlockH := LRows * LRowH;
    if Options.LegendPosition = dlpTop then
    begin
      LY0 := FArea.Top;
      FArea.Top := FArea.Top + LBlockH + Px(8);
    end
    else
    begin
      LY0 := FArea.Bottom - LBlockH;
      FArea.Bottom := FArea.Bottom - LBlockH - Px(8);
    end;
    for I := 0 to LCount - 1 do
    begin
      LRow := LRowOf[I];
      LX := FArea.Left + (FArea.Width - LRowW[LRow]) / 2 + LItemX[I];
      FLegend[I].Dot := PointF(LX + LDot / 2, LY0 + LRow * LRowH + LRowH / 2);
      FLegend[I].TextBox := RectF(LX + LDot + LGap, LY0 + LRow * LRowH,
        LX + LW[I] + Px(8), LY0 + (LRow + 1) * LRowH);
    end;
  end
  else
  begin
    LBlockW := 0;
    for I := 0 to LCount - 1 do
      LBlockW := Max(LBlockW, LW[I]);
    LBlockH := LCount * LRowH + (LCount - 1) * Px(6);
    LY0 := FArea.Top + (FArea.Height - LBlockH) / 2;
    if Options.LegendPosition = dlpLeft then
    begin
      LX := FArea.Left;
      FArea.Left := FArea.Left + LBlockW + Px(16);
    end
    else
    begin
      LX := FArea.Right - LBlockW;
      FArea.Right := FArea.Right - LBlockW - Px(16);
    end;
    for I := 0 to LCount - 1 do
    begin
      FLegend[I].Dot := PointF(LX + LDot / 2, LY0 + I * (LRowH + Px(6)) + LRowH / 2);
      FLegend[I].TextBox := RectF(LX + LDot + LGap, LY0 + I * (LRowH + Px(6)),
        LX + LW[I] + Px(8), LY0 + I * (LRowH + Px(6)) + LRowH);
    end;
  end;
end;

procedure TDaisyChartEngine.LayoutCartesian;
var
  I, K, LLabelCount: Integer;
  LVMin, LVMax, V, LPos, LNeg, LBase: Double;
  LAny, LStack, LBars: Boolean;
  LTickW, LCatW, LFirstW, LLastW, LLeft, LBottom, LTop, LRight, LDataW: Single;
  LFs: Integer;

  procedure Extend(AValue: Double);
  begin
    if not LAny then
    begin
      LVMin := AValue;
      LVMax := AValue;
      LAny := True;
    end
    else
    begin
      LVMin := Min(LVMin, AValue);
      LVMax := Max(LVMax, AValue);
    end;
  end;

begin
  LFs := Style.FontSize;
  FCats := Length(Labels);
  for K := 0 to High(Series) do
    FCats := Max(FCats, Length(Series[K].Values));
  LStack := Options.Stacked and (Options.ChartType in [dctColumn, dctBar, dctArea]);
  LBars := Options.ChartType in [dctColumn, dctBar];
  SetLength(FHi, Length(Series));
  SetLength(FLo, Length(Series));
  for K := 0 to High(Series) do
  begin
    SetLength(FHi[K], FCats);
    SetLength(FLo[K], FCats);
  end;

  LAny := False;
  LVMin := 0;
  LVMax := 1;
  for I := 0 to FCats - 1 do
  begin
    LPos := 0;
    LNeg := 0;
    for K := 0 to High(Series) do
    begin
      if I < Length(Series[K].Values) then
        V := Series[K].Values[I]
      else
        V := NaN;
      if IsNan(V) then
      begin
        FHi[K][I] := NaN;
        FLo[K][I] := NaN;
        Continue;
      end;
      if LStack then
      begin
        if V >= 0 then
        begin
          FLo[K][I] := LPos;
          LPos := LPos + V;
          FHi[K][I] := LPos;
        end
        else
        begin
          FLo[K][I] := LNeg;
          LNeg := LNeg + V;
          FHi[K][I] := LNeg;
        end;
        Extend(LPos);
        Extend(LNeg);
      end
      else
      begin
        FHi[K][I] := V;
        Extend(V);
      end;
    end;
  end;
  if LBars or LStack then
    Extend(0);
  NiceScale(LVMin, LVMax, 6, FAxStart, FAxStep, FTickCount);
  FAxMin := FAxStart;
  FAxMax := FAxStart + (FTickCount - 1) * FAxStep;

  if not LStack then
  begin
    if LBars then
      LBase := EnsureRange(0, FAxMin, FAxMax)
    else
      LBase := FAxMin;
    for K := 0 to High(Series) do
      for I := 0 to FCats - 1 do
        FLo[K][I] := LBase;
  end;

  LTickW := 0;
  for I := 0 to FTickCount - 1 do
    LTickW := Max(LTickW, TextW(FmtValue(FAxStart + I * FAxStep), LFs, False));
  LCatW := 0;
  for I := 0 to FCats - 1 do
    LCatW := Max(LCatW, TextW(CategoryText(I), LFs, False));
  LFirstW := TextW(CategoryText(0), LFs, False);
  LLastW := TextW(CategoryText(FCats - 1), LFs, False);

  LLeft := 0;
  if Options.ShowYAxis then
  begin
    if IsHorizontal then
      LLeft := LCatW + Px(10)
    else
      LLeft := LTickW + Px(10);
  end;
  LBottom := 0;
  if Options.ShowXAxis then
    LBottom := LineH(LFs) + Px(8);
  LTop := Px(8);
  if Options.DataLabels and not IsHorizontal then
    LTop := LTop + LineH(LFs);
  LRight := Px(4);
  if IsHorizontal then
  begin
    LRight := Max(LRight, TextW(FmtValue(FAxMax), LFs, False) / 2 + Px(2));
    if Options.DataLabels and not LStack then
    begin
      LDataW := 0;
      for K := 0 to High(Series) do
        for I := 0 to FCats - 1 do
          if not IsNan(FHi[K][I]) then
            LDataW := Max(LDataW, TextW(FmtValue(FHi[K][I]), LFs, False));
      LRight := Max(LRight, LDataW + Px(10));
    end;
  end;

  FInset := 0;
  if Options.ChartType in [dctLine, dctArea] then
  begin
    if Options.ShowXAxis then
      FInset := EnsureRange(Max(LFirstW, LLastW) / 2, Px(4), Px(48))
    else
      FInset := Px(Max(Options.StrokeWidth, Options.MarkerSize) + 2);
  end;
  LLabelCount := FCats;
  if LLabelCount = 0 then
    FInset := 0;

  FPlot := RectF(FArea.Left + LLeft, FArea.Top + LTop, FArea.Right - LRight,
    FArea.Bottom - LBottom);
end;

procedure TDaisyChartEngine.LayoutRound;
var
  LSide: Single;
begin
  LSide := Min(FArea.Width, FArea.Height);
  FCenter := PointF((FArea.Left + FArea.Right) / 2, (FArea.Top + FArea.Bottom) / 2);
  FOuter := Max(0, LSide / 2 - Px(6));
  case Options.ChartType of
    dctDonut:
      FInner := FOuter * EnsureRange(Options.HoleSize, 10, 90) / 100;
    dctRadial:
      begin
        FInner := FOuter * 0.3;
        if Length(FSlices) > 0 then
          FThick := Min((FOuter - FInner) / Length(FSlices) * 0.72, Px(24))
        else
          FThick := 0;
      end;
  else
    FInner := 0;
  end;
end;

procedure TDaisyChartEngine.ComputeLayout(AWidth, AHeight: Single);
begin
  FW := AWidth;
  FH := AHeight;
  FArea := RectF(Px(8), Px(8), AWidth - Px(8), AHeight - Px(8));
  if IsRound then
    CollectSlices
  else
    FSlices := nil;
  LayoutLegend;
  if IsRound then
    LayoutRound
  else
    LayoutCartesian;
  FLaidOut := True;
end;

function TDaisyChartEngine.ValPos(AValue: Double): Single;
var
  LFrac: Double;
begin
  if FAxMax = FAxMin then
    LFrac := 0
  else
    LFrac := (AValue - FAxMin) / (FAxMax - FAxMin);
  if IsHorizontal then
    Result := FPlot.Left + LFrac * FPlot.Width
  else
    Result := FPlot.Bottom - LFrac * FPlot.Height;
end;

function TDaisyChartEngine.BandSize: Single;
begin
  if FCats = 0 then
    Exit(0);
  if IsHorizontal then
    Result := FPlot.Height / FCats
  else
    Result := FPlot.Width / FCats;
end;

function TDaisyChartEngine.CatPos(AIndex: Integer): Single;
begin
  if Options.ChartType in [dctLine, dctArea] then
  begin
    if FCats <= 1 then
      Result := (FPlot.Left + FPlot.Right) / 2
    else
      Result := FPlot.Left + FInset + AIndex * (FPlot.Width - 2 * FInset) / (FCats - 1);
  end
  else if IsHorizontal then
    Result := FPlot.Top + (AIndex + 0.5) * BandSize
  else
    Result := FPlot.Left + (AIndex + 0.5) * BandSize;
end;

function TDaisyChartEngine.IsLastInStack(ASeries, AIndex: Integer): Boolean;
var
  K: Integer;
begin
  Result := True;
  for K := ASeries + 1 to High(Series) do
    if not IsNan(FHi[K][AIndex]) and (FHi[K][AIndex] <> FLo[K][AIndex]) and
      ((FHi[K][AIndex] >= FLo[K][AIndex]) = (FHi[ASeries][AIndex] >= FLo[ASeries][AIndex])) then
      Exit(False);
end;

function TDaisyChartEngine.CurvePoints(const APoints: TArray<TPointF>): TArray<TPointF>;
var
  LList: TList<TPointF>;
  I, J, N, LSteps: Integer;
  LD, LM: TArray<Double>;
  LA, LB, LS, LT, LDX, LH00, LH10, LH01, LH11: Double;
begin
  N := Length(APoints);
  if (N < 2) or (Options.Curve = dccStraight) then
    Exit(APoints);
  LList := TList<TPointF>.Create;
  try
    if Options.Curve = dccStepline then
    begin
      for I := 0 to N - 1 do
      begin
        LList.Add(APoints[I]);
        if I < N - 1 then
          LList.Add(PointF(APoints[I + 1].X, APoints[I].Y));
      end;
      Exit(LList.ToArray);
    end;

    // monotone cubic interpolation: smooth without overshooting the data
    SetLength(LD, N - 1);
    SetLength(LM, N);
    for I := 0 to N - 2 do
      if APoints[I + 1].X = APoints[I].X then
        LD[I] := 0
      else
        LD[I] := (APoints[I + 1].Y - APoints[I].Y) / (APoints[I + 1].X - APoints[I].X);
    LM[0] := LD[0];
    LM[N - 1] := LD[N - 2];
    for I := 1 to N - 2 do
      if LD[I - 1] * LD[I] <= 0 then
        LM[I] := 0
      else
        LM[I] := (LD[I - 1] + LD[I]) / 2;
    for I := 0 to N - 2 do
    begin
      if LD[I] = 0 then
      begin
        LM[I] := 0;
        LM[I + 1] := 0;
      end
      else
      begin
        LA := LM[I] / LD[I];
        LB := LM[I + 1] / LD[I];
        LS := LA * LA + LB * LB;
        if LS > 9 then
        begin
          LT := 3 / Sqrt(LS);
          LM[I] := LT * LA * LD[I];
          LM[I + 1] := LT * LB * LD[I];
        end;
      end;
    end;
    for I := 0 to N - 2 do
    begin
      LDX := APoints[I + 1].X - APoints[I].X;
      LSteps := Max(4, Min(24, Ceil(LDX / 3)));
      for J := 0 to LSteps - 1 do
      begin
        LT := J / LSteps;
        LH00 := 2 * LT * LT * LT - 3 * LT * LT + 1;
        LH10 := LT * LT * LT - 2 * LT * LT + LT;
        LH01 := -2 * LT * LT * LT + 3 * LT * LT;
        LH11 := LT * LT * LT - LT * LT;
        LList.Add(PointF(APoints[I].X + LT * LDX,
          LH00 * APoints[I].Y + LH10 * LDX * LM[I] + LH01 * APoints[I + 1].Y +
          LH11 * LDX * LM[I + 1]));
      end;
    end;
    LList.Add(APoints[N - 1]);
    Result := LList.ToArray;
  finally
    LList.Free;
  end;
end;

{ Building }

function TDaisyChartEngine.Build(AWidth, AHeight: Single; AHover: Integer): TArray<TDaisyChartShape>;
begin
  if (not FLaidOut) or (AWidth <> FW) or (AHeight <> FH) then
    ComputeLayout(AWidth, AHeight);
  FCount := 0;
  BuildLegend;
  if IsRound then
    BuildRound(AHover)
  else
    BuildCartesian(AHover);
  Result := Copy(FShapes, 0, FCount);
end;

procedure TDaisyChartEngine.BuildLegend;
var
  I: Integer;
begin
  for I := 0 to High(FLegend) do
  begin
    AddDot(FLegend[I].Dot.X, FLegend[I].Dot.Y, Px(5), FLegend[I].Color, 0, 0);
    AddText(FLegend[I].Text, FLegend[I].TextBox, dcaLeft, Style.FontSize + 1, False,
      Style.TextColor);
  end;
end;

procedure TDaisyChartEngine.BuildCartesian(AHover: Integer);
var
  LFs, I, LStep: Integer;
  LV, LPos, LSpace, LMaxW, LW: Single;
  LHalf: Single;
begin
  if (FPlot.Width <= 0) or (FPlot.Height <= 0) or (FCats = 0) then
    Exit;
  LFs := Style.FontSize;

  // value axis: grid lines and labels
  for I := 0 to FTickCount - 1 do
  begin
    LV := FAxStart + I * FAxStep;
    LPos := ValPos(LV);
    if IsHorizontal then
    begin
      if Options.ShowGrid then
        AddLine([PointF(LPos, FPlot.Top), PointF(LPos, FPlot.Bottom)], Style.GridColor, 1, True,
          False, False);
      if Options.ShowXAxis then
      begin
        LW := TextW(FmtValue(LV), LFs, False) / 2 + Px(4);
        AddText(FmtValue(LV), RectF(LPos - LW, FPlot.Bottom + Px(6), LPos + LW,
          FPlot.Bottom + Px(6) + LineH(LFs)), dcaCenter, LFs, False, Style.MutedColor);
      end;
    end
    else
    begin
      if Options.ShowGrid then
        AddLine([PointF(FPlot.Left, LPos), PointF(FPlot.Right, LPos)], Style.GridColor, 1, True,
          False, False);
      if Options.ShowYAxis then
        AddText(FmtValue(LV), RectF(FArea.Left, LPos - LineH(LFs) / 2, FPlot.Left - Px(8),
          LPos + LineH(LFs) / 2), dcaRight, LFs, False, Style.MutedColor);
    end;
  end;

  // category axis labels, thinned out when they would overlap
  if IsHorizontal then
  begin
    if Options.ShowYAxis then
    begin
      LSpace := BandSize;
      LStep := Max(1, Ceil((LineH(LFs) + Px(2)) / Max(1, LSpace)));
      I := 0;
      while I < FCats do
      begin
        LPos := CatPos(I);
        AddText(CategoryText(I), RectF(FArea.Left, LPos - LineH(LFs) / 2, FPlot.Left - Px(8),
          LPos + LineH(LFs) / 2), dcaRight, LFs, False, Style.MutedColor);
        Inc(I, LStep);
      end;
    end;
  end
  else if Options.ShowXAxis then
  begin
    LMaxW := 0;
    for I := 0 to FCats - 1 do
      LMaxW := Max(LMaxW, TextW(CategoryText(I), LFs, False));
    if FCats > 1 then
      LSpace := (CatPos(FCats - 1) - CatPos(0)) / (FCats - 1)
    else
      LSpace := FPlot.Width;
    LStep := Max(1, Ceil((LMaxW + Px(8)) / Max(1, LSpace)));
    I := 0;
    while I < FCats do
    begin
      LPos := CatPos(I);
      LHalf := TextW(CategoryText(I), LFs, False) / 2 + Px(4);
      AddText(CategoryText(I), RectF(LPos - LHalf, FPlot.Bottom + Px(6), LPos + LHalf,
        FPlot.Bottom + Px(6) + LineH(LFs)), dcaCenter, LFs, False, Style.MutedColor);
      Inc(I, LStep);
    end;
  end;

  if Options.ChartType in [dctColumn, dctBar] then
    BuildBars(AHover)
  else
    BuildLines(AHover);
end;

procedure TDaisyChartEngine.BuildBars(AHover: Integer);
var
  LFs, I, K, LCount: Integer;
  LBand, LGroup, LBarSize, LStart, LA, LB, LRad, LCenter: Single;
  LRect: TRectF;
  LPositive, LStack, LLast: Boolean;
  LRows: TArray<TDaisyChartTipRow>;
  LAnchor: TPointF;
  LLabel: string;
  LTextColor: TAlphaColor;
  LTL, LTR, LBR, LBL: Single;
begin
  LFs := Style.FontSize;
  LStack := Options.Stacked;
  LBand := BandSize;
  LGroup := LBand * 0.7;
  LCount := Length(Series);
  if LCount = 0 then
    Exit;
  if LStack then
    LBarSize := LGroup
  else
    LBarSize := LGroup / LCount;

  if (AHover >= 0) and (AHover < FCats) then
  begin
    if IsHorizontal then
      LRect := RectF(FPlot.Left, FPlot.Top + AHover * LBand, FPlot.Right,
        FPlot.Top + (AHover + 1) * LBand)
    else
      LRect := RectF(FPlot.Left + AHover * LBand, FPlot.Top, FPlot.Left + (AHover + 1) * LBand,
        FPlot.Bottom);
    AddFill(RoundRectPoly(LRect, 0, 0, 0, 0), DaisyWithAlpha(Style.TextColor, 0.06), 0, 0);
  end;

  for I := 0 to FCats - 1 do
  begin
    LCenter := CatPos(I);
    for K := 0 to LCount - 1 do
    begin
      if IsNan(FHi[K][I]) then
        Continue;
      LPositive := FHi[K][I] >= FLo[K][I];
      if LStack then
        LStart := LCenter - LGroup / 2
      else
        LStart := LCenter - LGroup / 2 + K * LBarSize;
      LA := ValPos(FLo[K][I]);
      LB := ValPos(FHi[K][I]);
      if IsHorizontal then
        LRect := RectF(Min(LA, LB), LStart, Max(LA, LB), LStart + LBarSize)
      else
        LRect := RectF(LStart, Min(LA, LB), LStart + LBarSize, Max(LA, LB));
      if (LRect.Width < 0.5) or (LRect.Height < 0.5) then
        Continue;

      LLast := (not LStack) or IsLastInStack(K, I);
      LRad := 0;
      if LLast then
        LRad := Min(Px(Options.BarRadius), Min(LRect.Width, LRect.Height) / 2);
      LTL := 0;
      LTR := 0;
      LBR := 0;
      LBL := 0;
      if IsHorizontal then
      begin
        // the end of a horizontal bar is its right side (left when negative)
        if LPositive then
        begin
          LTR := LRad;
          LBR := LRad;
        end
        else
        begin
          LTL := LRad;
          LBL := LRad;
        end;
      end
      else if LPositive then
      begin
        LTL := LRad;
        LTR := LRad;
      end
      else
      begin
        LBL := LRad;
        LBR := LRad;
      end;
      AddFill(RoundRectPoly(LRect, LTL, LTR, LBR, LBL), Series[K].Color, 0, 0);

      if Options.DataLabels then
      begin
        LLabel := FmtValue(FHi[K][I] - FLo[K][I]);
        if LStack then
        begin
          LTextColor := ContrastColor(Series[K].Color);
          if (IsHorizontal and (LRect.Width > TextW(LLabel, LFs, True) + Px(6))) or
            ((not IsHorizontal) and (LRect.Height > LineH(LFs)) and
              (LRect.Width > TextW(LLabel, LFs, True) + Px(4))) then
            AddText(LLabel, RectF(LRect.Left, (LRect.Top + LRect.Bottom) / 2 - LineH(LFs) / 2,
              LRect.Right, (LRect.Top + LRect.Bottom) / 2 + LineH(LFs) / 2), dcaCenter, LFs, True,
              LTextColor);
        end
        else if IsHorizontal then
        begin
          if LPositive then
            AddText(LLabel, RectF(LRect.Right + Px(4), (LRect.Top + LRect.Bottom) / 2 -
              LineH(LFs) / 2, LRect.Right + Px(4) + TextW(LLabel, LFs, True) + Px(4),
              (LRect.Top + LRect.Bottom) / 2 + LineH(LFs) / 2), dcaLeft, LFs, True,
              Style.TextColor)
          else
            AddText(LLabel, RectF(LRect.Left - Px(4) - TextW(LLabel, LFs, True) - Px(4),
              (LRect.Top + LRect.Bottom) / 2 - LineH(LFs) / 2, LRect.Left - Px(4),
              (LRect.Top + LRect.Bottom) / 2 + LineH(LFs) / 2), dcaRight, LFs, True,
              Style.TextColor);
        end
        else
        begin
          LA := TextW(LLabel, LFs, True) / 2 + Px(4);
          if LPositive then
            AddText(LLabel, RectF((LRect.Left + LRect.Right) / 2 - LA, LRect.Top - LineH(LFs) -
              Px(2), (LRect.Left + LRect.Right) / 2 + LA, LRect.Top - Px(2)), dcaCenter, LFs, True,
              Style.TextColor)
          else
            AddText(LLabel, RectF((LRect.Left + LRect.Right) / 2 - LA, LRect.Bottom + Px(2),
              (LRect.Left + LRect.Right) / 2 + LA, LRect.Bottom + Px(2) + LineH(LFs)), dcaCenter,
              LFs, True, Style.TextColor);
        end;
      end;
    end;
  end;

  if Options.ShowTooltip and (AHover >= 0) and (AHover < FCats) then
  begin
    SetLength(LRows, 0);
    for K := 0 to LCount - 1 do
      if not IsNan(FHi[K][AHover]) then
      begin
        SetLength(LRows, Length(LRows) + 1);
        LRows[High(LRows)].Color := Series[K].Color;
        LRows[High(LRows)].Text := Series[K].Name + ': ' + FmtValue(FHi[K][AHover] - FLo[K][AHover]);
      end;
    if IsHorizontal then
    begin
      LA := FPlot.Left;
      for K := 0 to LCount - 1 do
        if not IsNan(FHi[K][AHover]) then
          LA := Max(LA, ValPos(Max(FHi[K][AHover], FLo[K][AHover])));
      LAnchor := PointF(LA, CatPos(AHover));
    end
    else
    begin
      LA := FPlot.Bottom;
      for K := 0 to LCount - 1 do
        if not IsNan(FHi[K][AHover]) then
          LA := Min(LA, ValPos(Max(FHi[K][AHover], FLo[K][AHover])));
      LAnchor := PointF(CatPos(AHover) + LGroup / 2, LA + Px(16));
    end;
    AddTooltip(CategoryText(AHover), LRows, LAnchor);
  end;
end;

procedure TDaisyChartEngine.BuildLines(AHover: Integer);
var
  LFs, I, K: Integer;
  LUpper, LLower, LRaw, LPoly: TArray<TPointF>;
  LTop: Single;
  LAreaTop, LAnchorY: Single;
  LRows: TArray<TDaisyChartTipRow>;
  LCount: Integer;
  LBase: Single;
  LStack: Boolean;

  function RawPoints(ASource: TArray<TArray<Double>>; ASeries: Integer): TArray<TPointF>;
  var
    J, N: Integer;
  begin
    SetLength(Result, FCats);
    N := 0;
    for J := 0 to FCats - 1 do
      if not IsNan(ASource[ASeries][J]) then
      begin
        Result[N] := PointF(CatPos(J), ValPos(ASource[ASeries][J]));
        Inc(N);
      end;
    SetLength(Result, N);
  end;

begin
  LFs := Style.FontSize;
  LStack := Options.Stacked and (Options.ChartType = dctArea);

  // areas first, so the lines and markers lie on top
  if Options.ChartType = dctArea then
    for K := 0 to High(Series) do
    begin
      LRaw := RawPoints(FHi, K);
      if Length(LRaw) < 2 then
        Continue;
      LUpper := CurvePoints(LRaw);
      if LStack then
        LLower := CurvePoints(RawPoints(FLo, K))
      else
      begin
        LBase := ValPos(FLo[K][0]);
        LLower := [PointF(LUpper[0].X, LBase), PointF(LUpper[High(LUpper)].X, LBase)];
      end;
      SetLength(LPoly, Length(LUpper) + Length(LLower));
      for I := 0 to High(LUpper) do
        LPoly[I] := LUpper[I];
      for I := 0 to High(LLower) do
        LPoly[Length(LUpper) + I] := LLower[High(LLower) - I];
      LAreaTop := FPlot.Bottom;
      for I := 0 to High(LUpper) do
        LAreaTop := Min(LAreaTop, LUpper[I].Y);
      AddGradient(LPoly, DaisyWithAlpha(Series[K].Color, 0.55), DaisyWithAlpha(Series[K].Color, 0),
        RectF(FPlot.Left, LAreaTop, FPlot.Right, FPlot.Bottom));
    end;

  for K := 0 to High(Series) do
  begin
    LRaw := RawPoints(FHi, K);
    if Length(LRaw) = 0 then
      Continue;
    if Length(LRaw) = 1 then
      AddDot(LRaw[0].X, LRaw[0].Y, Px(Max(Options.StrokeWidth, 3)), Series[K].Color, 0, 0)
    else
      AddLine(CurvePoints(LRaw), Series[K].Color, Px(Options.StrokeWidth), False, True, False);
    if Options.MarkerSize > 0 then
      for I := 0 to High(LRaw) do
        AddDot(LRaw[I].X, LRaw[I].Y, Px(Options.MarkerSize), Series[K].Color, Style.SurfaceColor,
          Px(2));
    if Options.DataLabels then
      for I := 0 to FCats - 1 do
        if not IsNan(FHi[K][I]) then
        begin
          LTop := ValPos(FHi[K][I]) - LineH(LFs) - Px(Max(Options.MarkerSize, 3) + 2);
          AddText(FmtValue(FHi[K][I] - FLo[K][I] * Ord(LStack)),
            RectF(CatPos(I) - Px(40), LTop, CatPos(I) + Px(40), LTop + LineH(LFs)), dcaCenter, LFs,
            True, Style.TextColor);
        end;
  end;

  if (AHover >= 0) and (AHover < FCats) then
  begin
    LAnchorY := 0;
    LCount := 0;
    SetLength(LRows, 0);
    AddLine([PointF(CatPos(AHover), FPlot.Top), PointF(CatPos(AHover), FPlot.Bottom)],
      Style.GridColor, 1, True, False, False);
    for K := 0 to High(Series) do
      if not IsNan(FHi[K][AHover]) then
      begin
        AddDot(CatPos(AHover), ValPos(FHi[K][AHover]), Px(5), Series[K].Color, Style.SurfaceColor,
          Px(2));
        LAnchorY := LAnchorY + ValPos(FHi[K][AHover]);
        Inc(LCount);
        SetLength(LRows, Length(LRows) + 1);
        LRows[High(LRows)].Color := Series[K].Color;
        LRows[High(LRows)].Text := Series[K].Name + ': ' +
          FmtValue(FHi[K][AHover] - FLo[K][AHover] * Ord(LStack));
      end;
    if Options.ShowTooltip and (LCount > 0) then
      AddTooltip(CategoryText(AHover), LRows, PointF(CatPos(AHover), LAnchorY / LCount));
  end;
end;

procedure TDaisyChartEngine.BuildRound(AHover: Integer);
var
  LFs, I, LRings: Integer;
  LList: TList<TPointF>;
  LA0, LA1, LOuter, LMid, LFrac, LRc, LTotal, LAvg: Double;
  LPercent, LText: string;
  LRows: TArray<TDaisyChartTipRow>;
  LAnchor: TPointF;
  LValueFs, LLabelFs: Integer;
  LBlockH, LTopY: Single;
  LStroke: Single;
begin
  if (FOuter <= 0) or (Length(FSlices) = 0) then
    Exit;
  LFs := Style.FontSize;

  if Options.ChartType = dctRadial then
  begin
    LRings := Length(FSlices);
    LAvg := 0;
    for I := 0 to LRings - 1 do
    begin
      LRc := FOuter - (I + 0.5) * (FOuter - FInner) / LRings;
      AddLine(ArcPolyline(FCenter.X, FCenter.Y, LRc, 0, 360), Style.TrackColor, FThick, False,
        False, True);
      LFrac := EnsureRange(FSlices[I].Value, 0, 100) / 100;
      LAvg := LAvg + LFrac;
      if LFrac >= 0.9999 then
        AddLine(ArcPolyline(FCenter.X, FCenter.Y, LRc, -90, 270), FSlices[I].Color, FThick, False,
          False, True)
      else if LFrac > 0.002 then
        AddLine(ArcPolyline(FCenter.X, FCenter.Y, LRc, -90, -90 + LFrac * 360), FSlices[I].Color,
          FThick, False, True, False);
      if Options.DataLabels then
      begin
        LLabelFs := Max(8, Min(LFs, Round(FThick / Style.Scale * 0.8)));
        AddText(DaisyChartFormat(FSlices[I].Value, 1) + '%',
          RectF(FCenter.X - Px(60), FCenter.Y - LRc - LineH(LLabelFs) / 2, FCenter.X - Px(6),
          FCenter.Y - LRc + LineH(LLabelFs) / 2), dcaRight, LLabelFs, True, Style.TextColor);
      end;
    end;
    if Options.ShowTotal and (LRings > 0) then
    begin
      LAvg := LAvg / LRings * 100;
      LValueFs := Max(10, Min(24, Round(FInner / Style.Scale * 0.55)));
      LLabelFs := Max(8, LValueFs div 2 + 1);
      LText := DaisyChartFormat(LAvg, 1) + '%';
      LBlockH := LineH(LValueFs);
      if Options.TotalLabel <> '' then
        LBlockH := LBlockH + LineH(LLabelFs);
      LTopY := FCenter.Y - LBlockH / 2;
      if Options.TotalLabel <> '' then
      begin
        AddText(Options.TotalLabel, RectF(FCenter.X - FInner, LTopY, FCenter.X + FInner,
          LTopY + LineH(LLabelFs)), dcaCenter, LLabelFs, False, Style.MutedColor);
        LTopY := LTopY + LineH(LLabelFs);
      end;
      AddText(LText, RectF(FCenter.X - FInner, LTopY, FCenter.X + FInner, LTopY + LineH(LValueFs)),
        dcaCenter, LValueFs, True, Style.TextColor);
    end;
    if Options.ShowTooltip and (AHover >= 0) and (AHover < LRings) then
    begin
      SetLength(LRows, 1);
      LRows[0].Color := FSlices[AHover].Color;
      LRows[0].Text := FSlices[AHover].Name + ': ' + DaisyChartFormat(FSlices[AHover].Value, 2) + '%';
      LRc := FOuter - (AHover + 0.5) * (FOuter - FInner) / LRings;
      LFrac := EnsureRange(FSlices[AHover].Value, 0, 100) / 100;
      LMid := DegToRad(-90 + LFrac * 360);
      LAnchor := PointF(FCenter.X + LRc * Cos(LMid), FCenter.Y + LRc * Sin(LMid));
      AddTooltip('', LRows, LAnchor);
    end;
    Exit;
  end;

  // pie and donut
  LTotal := 0;
  for I := 0 to High(FSlices) do
    LTotal := LTotal + FSlices[I].Value;
  if LTotal <= 0 then
    Exit;

  LList := TList<TPointF>.Create;
  try
    for I := 0 to High(FSlices) do
    begin
      if FSlices[I].Value <= 0 then
        Continue;
      LA0 := -90 + FSlices[I].From * 360;
      LA1 := -90 + FSlices[I].To_ * 360;
      if LA1 - LA0 > 359.99 then
        LA1 := LA0 + 359.99;
      LOuter := FOuter;
      if I = AHover then
        LOuter := LOuter + Px(5);
      LList.Clear;
      AddArcPoints(LList, FCenter.X, FCenter.Y, LOuter, LA0, LA1);
      if FInner > 0 then
        AddArcPoints(LList, FCenter.X, FCenter.Y, FInner, LA1, LA0)
      else
        LList.Add(FCenter);
      if FSlices[I].To_ - FSlices[I].From > 0.9999 then
        LStroke := 0
      else
        LStroke := Px(2);
      AddFill(LList.ToArray, FSlices[I].Color, Style.SurfaceColor, LStroke);
    end;
  finally
    LList.Free;
  end;

  if Options.DataLabels then
    for I := 0 to High(FSlices) do
    begin
      LFrac := FSlices[I].Value / LTotal;
      if LFrac < 0.03 then
        Continue;
      LMid := DegToRad(-90 + (FSlices[I].From + FSlices[I].To_) * 180);
      if FInner > 0 then
        LRc := (FInner + FOuter) / 2
      else
        LRc := FOuter * 0.65;
      LPercent := DaisyChartFormat(LFrac * 100, 1) + '%';
      AddText(LPercent, RectF(FCenter.X + LRc * Cos(LMid) - Px(30),
        FCenter.Y + LRc * Sin(LMid) - LineH(LFs) / 2, FCenter.X + LRc * Cos(LMid) + Px(30),
        FCenter.Y + LRc * Sin(LMid) + LineH(LFs) / 2), dcaCenter, LFs, True,
        ContrastColor(FSlices[I].Color));
    end;

  if (Options.ChartType = dctDonut) and Options.ShowTotal then
  begin
    LValueFs := Max(10, Min(32, Round(FInner / Style.Scale * 0.42)));
    LLabelFs := Max(8, LValueFs div 2 + 2);
    LBlockH := LineH(LValueFs);
    if Options.TotalLabel <> '' then
      LBlockH := LBlockH + LineH(LLabelFs);
    LTopY := FCenter.Y - LBlockH / 2;
    if Options.TotalLabel <> '' then
    begin
      AddText(Options.TotalLabel, RectF(FCenter.X - FInner, LTopY, FCenter.X + FInner,
        LTopY + LineH(LLabelFs)), dcaCenter, LLabelFs, False, Style.MutedColor);
      LTopY := LTopY + LineH(LLabelFs);
    end;
    AddText(FmtValue(LTotal), RectF(FCenter.X - FInner, LTopY, FCenter.X + FInner,
      LTopY + LineH(LValueFs)), dcaCenter, LValueFs, True, Style.TextColor);
  end;

  if Options.ShowTooltip and (AHover >= 0) and (AHover < Length(FSlices)) then
  begin
    SetLength(LRows, 1);
    LRows[0].Color := FSlices[AHover].Color;
    LRows[0].Text := FSlices[AHover].Name + ': ' + FmtValue(FSlices[AHover].Value);
    LMid := DegToRad(-90 + (FSlices[AHover].From + FSlices[AHover].To_) * 180);
    LRc := (FInner + FOuter) / 2;
    LAnchor := PointF(FCenter.X + LRc * Cos(LMid), FCenter.Y + LRc * Sin(LMid));
    AddTooltip('', LRows, LAnchor);
  end;
end;

{ Hit testing }

function TDaisyChartEngine.HitTest(AWidth, AHeight: Single; const APoint: TPointF): Integer;
var
  I, LRings: Integer;
  LDx, LDy, LDist, LAngle, LFrac, LRc, LSlot: Double;
begin
  Result := -1;
  if (AWidth <= 0) or (AHeight <= 0) then
    Exit;
  if (not FLaidOut) or (AWidth <> FW) or (AHeight <> FH) then
    ComputeLayout(AWidth, AHeight);

  if IsRound then
  begin
    if (Length(FSlices) = 0) or (FOuter <= 0) then
      Exit;
    LDx := APoint.X - FCenter.X;
    LDy := APoint.Y - FCenter.Y;
    LDist := Sqrt(LDx * LDx + LDy * LDy);
    if Options.ChartType = dctRadial then
    begin
      LRings := Length(FSlices);
      LSlot := (FOuter - FInner) / LRings;
      for I := 0 to LRings - 1 do
      begin
        LRc := FOuter - (I + 0.5) * LSlot;
        if Abs(LDist - LRc) <= LSlot / 2 then
          Exit(I);
      end;
      Exit;
    end;
    if (LDist > FOuter + Px(5)) or (LDist < FInner) then
      Exit;
    LAngle := RadToDeg(ArcTan2(LDy, LDx)) + 90;
    if LAngle < 0 then
      LAngle := LAngle + 360;
    LFrac := LAngle / 360;
    for I := 0 to High(FSlices) do
      if (FSlices[I].Value > 0) and (LFrac >= FSlices[I].From) and (LFrac < FSlices[I].To_) then
        Exit(I);
    Exit;
  end;

  if (FCats = 0) or (FPlot.Width <= 0) or (FPlot.Height <= 0) then
    Exit;
  if IsHorizontal then
  begin
    if (APoint.X < FPlot.Left - Px(4)) or (APoint.X > FPlot.Right + Px(4)) or
      (APoint.Y < FPlot.Top) or (APoint.Y >= FPlot.Bottom) then
      Exit;
    Result := EnsureRange(Floor((APoint.Y - FPlot.Top) / BandSize), 0, FCats - 1);
  end
  else if Options.ChartType = dctColumn then
  begin
    if (APoint.Y < FPlot.Top - Px(4)) or (APoint.Y > FPlot.Bottom + Px(4)) or
      (APoint.X < FPlot.Left) or (APoint.X >= FPlot.Right) then
      Exit;
    Result := EnsureRange(Floor((APoint.X - FPlot.Left) / BandSize), 0, FCats - 1);
  end
  else
  begin
    if (APoint.Y < FPlot.Top - Px(4)) or (APoint.Y > FPlot.Bottom + Px(4)) or
      (APoint.X < FPlot.Left) or (APoint.X > FPlot.Right) then
      Exit;
    if FCats = 1 then
      Exit(0);
    Result := EnsureRange(Round((APoint.X - FPlot.Left - FInset) /
      ((FPlot.Width - 2 * FInset) / (FCats - 1))), 0, FCats - 1);
  end;
end;

end.
