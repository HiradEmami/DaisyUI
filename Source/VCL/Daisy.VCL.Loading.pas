unit Daisy.VCL.Loading;

{
  TDaisyLoading - the DaisyUI "loading" indicator on its own: spinner, ring, dots,
  ball, bars or infinity. Variant tints it (the default follows the text colour)
  and SizeKind gives xs..xl (16, 20, 24, 32 and 40 px). It animates while Active.

  The animation is driven by Daisy.Animation's clock: a background thread ticks, the
  tick is delivered on the main thread and only invalidates the control.
}

interface

uses
  Winapi.Windows, Winapi.GDIPAPI, Winapi.GDIPOBJ, System.Classes, System.Types, System.UITypes,
  System.Math,
  Vcl.Controls, Daisy.Theme, Daisy.Animation, Daisy.VCL.Control;

type
  TDaisyLoading = class(TDaisyControl)
  strict private
    FKind: TDaisyLoadingKind;
    FActive: Boolean;
    FAutoFit: Boolean;
    FUpdating: Boolean;
    procedure SetKind(const Value: TDaisyLoadingKind);
    procedure SetActive(const Value: Boolean);
    procedure SetAutoFit(const Value: Boolean);
    function IndicatorSize: Integer;
    procedure UpdateSize;
    procedure AnimationTick(Sender: TObject);
  protected
    function DefaultCornerRadius: Integer; override;
    function DefaultShadowSize: Integer; override;
    function DefaultContentPadding: Integer; override;
    function DefaultStyleColors(AState: TDaisyState): TDaisyColors; override;
    procedure SizeChanged; override;
    procedure Loaded; override;
    procedure DrawContent(const AColors: TDaisyColors; const ARect: TRect); override;
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

{ TDaisyLoading }

constructor TDaisyLoading.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FKind := dlSpinner;
  FAutoFit := True;
  FActive := True;
  SetBounds(Left, Top, 24, 24);
  DaisyAnimationClock.AddListener(AnimationTick);
end;

destructor TDaisyLoading.Destroy;
begin
  if FActive then
    DaisyAnimationClock.RemoveListener(AnimationTick);
  inherited;
end;

function TDaisyLoading.DefaultCornerRadius: Integer;
begin
  Result := 0;
end;

function TDaisyLoading.DefaultShadowSize: Integer;
begin
  Result := 0;
end;

function TDaisyLoading.DefaultContentPadding: Integer;
begin
  Result := 0;
end;

// The indicator is transparent; DrawContent picks the colour
function TDaisyLoading.DefaultStyleColors(AState: TDaisyState): TDaisyColors;
begin
  Result := Default(TDaisyColors);
  Result.Text := Theme.BaseContent;
end;

procedure TDaisyLoading.SetKind(const Value: TDaisyLoadingKind);
begin
  if FKind <> Value then
  begin
    FKind := Value;
    Invalidate;
  end;
end;

procedure TDaisyLoading.SetActive(const Value: Boolean);
begin
  if FActive = Value then
    Exit;
  FActive := Value;
  if FActive then
    DaisyAnimationClock.AddListener(AnimationTick)
  else
    DaisyAnimationClock.RemoveListener(AnimationTick);
  Invalidate;
end;

procedure TDaisyLoading.SetAutoFit(const Value: Boolean);
begin
  if FAutoFit <> Value then
  begin
    FAutoFit := Value;
    UpdateSize;
  end;
end;

function TDaisyLoading.IndicatorSize: Integer;
begin
  Result := ScaleValue(CIndicatorSizes[SizeKind]);
end;

procedure TDaisyLoading.UpdateSize;
begin
  if (not FAutoFit) or FUpdating or (csLoading in ComponentState) then
    Exit;
  FUpdating := True;
  try
    SetBounds(Left, Top, IndicatorSize, IndicatorSize);
  finally
    FUpdating := False;
  end;
end;

procedure TDaisyLoading.SizeChanged;
begin
  UpdateSize;
end;

procedure TDaisyLoading.Loaded;
begin
  inherited;
  UpdateSize;
end;

procedure TDaisyLoading.AnimationTick(Sender: TObject);
begin
  if FActive and HandleAllocated and Visible then
    Invalidate;
end;

procedure TDaisyLoading.DrawContent(const AColors: TDaisyColors; const ARect: TRect);
var
  LGraphics: TGPGraphics;
  LSize: Integer;
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

  LSize := Min(ClientWidth, ClientHeight);
  LBox := RectF((ClientWidth - LSize) / 2, (ClientHeight - LSize) / 2,
    (ClientWidth + LSize) / 2, (ClientHeight + LSize) / 2);
  if FActive then
    LTime := DaisyAnimationClock.Time
  else
    LTime := 0;

  LGraphics := NewGraphics;
  try
    DrawPrims(LGraphics, DaisyLoadingPrims(FKind, LTime), LBox, LColor);
  finally
    LGraphics.Free;
  end;
end;

end.
