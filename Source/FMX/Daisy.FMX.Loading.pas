unit Daisy.FMX.Loading;

{
  TDaisyFmxLoading - the DaisyUI "loading" indicator on its own: spinner, ring, dots,
  ball, bars or infinity. Variant tints it (the default follows the text colour)
  and SizeKind gives xs..xl (16, 20, 24, 32 and 40 px). It animates while Active.

  The animation clock ticks on a background thread but delivers on the main
  thread, where the listener only repaints.
}

interface

uses
  System.Classes, System.Types, System.UITypes, System.Math, FMX.Types, Daisy.Theme,
  Daisy.Animation, Daisy.FMX.Control;

type
  TDaisyFmxLoading = class(TDaisyControl)
  strict private
    FKind: TDaisyLoadingKind;
    FActive: Boolean;
    FAutoFit: Boolean;
    FUpdating: Boolean;
    procedure SetKind(const Value: TDaisyLoadingKind);
    procedure SetActive(const Value: Boolean);
    procedure SetAutoFit(const Value: Boolean);
    function IndicatorSize: Single;
    procedure UpdateSize;
    procedure AnimationTick(Sender: TObject);
  protected
    function DefaultCornerRadius: Integer; override;
    function DefaultShadowSize: Integer; override;
    function DefaultContentPadding: Integer; override;
    function DefaultStyleColors(AState: TDaisyState): TDaisyColors; override;
    procedure SizeChanged; override;
    procedure Loaded; override;
    procedure DrawContent(const AColors: TDaisyColors; const ARect: TRectF); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Kind: TDaisyLoadingKind read FKind write SetKind default dlSpinner;
    // The indicator animates while True; False freezes it
    property Active: Boolean read FActive write SetActive default True;
    // The size follows SizeKind; when off the control keeps its own size
    property AutoFit: Boolean read FAutoFit write SetAutoFit default True;
  end;

implementation

const
  CIndicatorSizes: array[TDaisySize] of Integer = (16, 20, 24, 32, 40);

{ TDaisyFmxLoading }

constructor TDaisyFmxLoading.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FKind := dlSpinner;
  FAutoFit := True;
  FActive := True;
  SetBounds(Position.X, Position.Y, 24, 24);
  DaisyAnimationClock.AddListener(AnimationTick);
end;

destructor TDaisyFmxLoading.Destroy;
begin
  if FActive then
    DaisyAnimationClock.RemoveListener(AnimationTick);
  inherited;
end;

function TDaisyFmxLoading.DefaultCornerRadius: Integer;
begin
  Result := 0;
end;

function TDaisyFmxLoading.DefaultShadowSize: Integer;
begin
  Result := 0;
end;

function TDaisyFmxLoading.DefaultContentPadding: Integer;
begin
  Result := 0;
end;

// The indicator is transparent; DrawContent picks the colour
function TDaisyFmxLoading.DefaultStyleColors(AState: TDaisyState): TDaisyColors;
begin
  Result := Default(TDaisyColors);
  Result.Text := Theme.BaseContent;
end;

procedure TDaisyFmxLoading.SetKind(const Value: TDaisyLoadingKind);
begin
  if FKind <> Value then
  begin
    FKind := Value;
    Repaint;
  end;
end;

procedure TDaisyFmxLoading.SetActive(const Value: Boolean);
begin
  if FActive = Value then
    Exit;
  FActive := Value;
  if FActive then
    DaisyAnimationClock.AddListener(AnimationTick)
  else
    DaisyAnimationClock.RemoveListener(AnimationTick);
  Repaint;
end;

procedure TDaisyFmxLoading.SetAutoFit(const Value: Boolean);
begin
  if FAutoFit <> Value then
  begin
    FAutoFit := Value;
    UpdateSize;
  end;
end;

function TDaisyFmxLoading.IndicatorSize: Single;
begin
  Result := CIndicatorSizes[SizeKind];
end;

procedure TDaisyFmxLoading.UpdateSize;
begin
  if (not FAutoFit) or FUpdating or (csLoading in ComponentState) then
    Exit;
  FUpdating := True;
  try
    SetBounds(Position.X, Position.Y, IndicatorSize, IndicatorSize);
  finally
    FUpdating := False;
  end;
end;

procedure TDaisyFmxLoading.SizeChanged;
begin
  UpdateSize;
  Repaint;
end;

procedure TDaisyFmxLoading.Loaded;
begin
  inherited;
  UpdateSize;
end;

procedure TDaisyFmxLoading.AnimationTick(Sender: TObject);
begin
  if FActive and Visible then
    Repaint;
end;

procedure TDaisyFmxLoading.DrawContent(const AColors: TDaisyColors; const ARect: TRectF);
var
  LSize: Single;
  LBox: TRectF;
  LColor: TAlphaColor;
  LTime: Double;
begin
  if Variant = dvDefault then
    LColor := Theme.BaseContent
  else
    LColor := DaisyVariantPalette(Theme, Variant).Fill;
  if not Enabled then
    LColor := DaisyWithAlpha(LColor, 0.4);

  LSize := Min(Width, Height);
  LBox := RectF((Width - LSize) / 2, (Height - LSize) / 2, (Width + LSize) / 2, (Height + LSize) / 2);
  if FActive then
    LTime := DaisyAnimationClock.Time
  else
    LTime := 0;
  DrawPrims(DaisyLoadingPrims(FKind, LTime), LBox, LColor);
end;

end.
