unit Daisy.Navigation;

{
  Framework neutral parts of the DaisyUI navigation components: breadcrumbs, dock, link,
  pagination and steps (VCL and FMX).

  * Items       - the collection items of breadcrumbs, dock and steps
  * Pagination  - which page numbers (and gaps) a pager shows
  * Dock layout - where each dock item sits along the dock, evenly or normally spaced
  * Metrics     - the DaisyUI sizes of the dock and steps for each size
  Must not reference Vcl.* or FMX.* units.
}

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Math, System.Generics.Collections,
  Daisy.Theme, Daisy.Widgets;

type
  // Edge of the parent the dock sits on; left and right docks lay their items out vertically
  TDaisyDockPlacement = (ddpBottom, ddpTop, ddpLeft, ddpRight);

  // dspEven spreads the items over the whole dock; dspNormal packs them from the start with a
  // standard gap and leaves the rest of the dock blank
  TDaisyDockSpacing = (dspEven, dspNormal);

  // The direction the dock items flow in. Left / right docks use difTopToBottom or
  // difBottomToTop, top / bottom docks use difLeftToRight or difRightToLeft; a value of the other
  // axis is converted to its equivalent (and back again when the Placement changes).
  // Left and right follow the reading direction, so they are swapped in a right-to-left layout.
  TDaisyDockFlow = (difTopToBottom, difBottomToTop, difLeftToRight, difRightToLeft);

  TDaisyStepsOrientation = (dsoHorizontal, dsoVertical);

  TDaisyBreadcrumbSeparator = (dbsChevron, dbsSlash);

  // dluAlways always underlines the text, dluHover only while the mouse is over it
  TDaisyLinkUnderline = (dluAlways, dluHover);

  // Index is the position of the clicked item in the component's Items
  TDaisyItemClickEvent = procedure(Sender: TObject; AIndex: Integer) of object;

  { Items }

  // What the items of every navigation component share
  TDaisyNavItem = class(TCollectionItem)
  strict private
    FCaption: string;
    FIcon: TDaisyIconSource;
    FEnabled: Boolean;
    FTag: Integer;
    FOnClick: TNotifyEvent;
    procedure SetCaption(const Value: string);
    function GetIcon: TDaisyIconSource;
    procedure SetIcon(const Value: TDaisyIconSource);
    procedure SetEnabled(const Value: Boolean);
    procedure IconChanged(Sender: TObject);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Click;
  published
    property Caption: string read FCaption write SetCaption;
    property Icon: TDaisyIconSource read GetIcon write SetIcon;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property Tag: Integer read FTag write FTag default 0;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
  end;

  TDaisyBreadcrumbItem = class(TDaisyNavItem);

  TDaisyDockItem = class(TDaisyNavItem);

  TDaisyStepItem = class(TDaisyNavItem)
  strict private
    FContent: string;
    FVariant: TDaisyVariant;
    procedure SetContent(const Value: string);
    procedure SetVariant(const Value: TDaisyVariant);
  public
    procedure Assign(Source: TPersistent); override;
  published
    // Text shown inside the step circle instead of its number (DaisyUI data-content)
    property Content: string read FContent write SetContent;
    // The colour of this step; dvDefault follows the steps ActiveStep
    property Variant: TDaisyVariant read FVariant write SetVariant default dvDefault;
  end;

  TDaisyNavItems = class(TOwnedCollection)
  strict private
    FOnChange: TNotifyEvent;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TDaisyBreadcrumbItems = class(TDaisyNavItems)
  strict private
    function GetItem(Index: Integer): TDaisyBreadcrumbItem;
    procedure SetItem(Index: Integer; const Value: TDaisyBreadcrumbItem);
  public
    constructor Create(AOwner: TPersistent);
    function Add: TDaisyBreadcrumbItem;
    property Items[Index: Integer]: TDaisyBreadcrumbItem read GetItem write SetItem; default;
  end;

  TDaisyDockItems = class(TDaisyNavItems)
  strict private
    function GetItem(Index: Integer): TDaisyDockItem;
    procedure SetItem(Index: Integer; const Value: TDaisyDockItem);
  public
    constructor Create(AOwner: TPersistent);
    function Add: TDaisyDockItem;
    property Items[Index: Integer]: TDaisyDockItem read GetItem write SetItem; default;
  end;

  TDaisyStepItems = class(TDaisyNavItems)
  strict private
    function GetItem(Index: Integer): TDaisyStepItem;
    procedure SetItem(Index: Integer; const Value: TDaisyStepItem);
  public
    constructor Create(AOwner: TPersistent);
    function Add: TDaisyStepItem;
    property Items[Index: Integer]: TDaisyStepItem read GetItem write SetItem; default;
  end;

  TDaisyDockSlot = record
    Start: Single;
    Extent: Single;
  end;

const
  // Marks a gap ("...") in the result of DaisyPaginationPages
  CDaisyPageGap = 0;

// The page numbers a pager shows for ACurrent of ACount pages: ABoundary pages at each end and
// ASiblings pages around ACurrent. A gap is CDaisyPageGap, and is only used when it hides at
// least two pages (a single hidden page is shown instead).
function DaisyPaginationPages(ACurrent, ACount, ASiblings, ABoundary: Integer): TArray<Integer>;

// Positions ACount dock items along ATotal. dspEven gives every item ATotal / ACount;
// dspNormal gives each AItemLength (shrunk to fit if needed) separated by AGap.
// AReverse starts the first item at the far end of ATotal instead of the near end.
function DaisyDockSlots(ACount: Integer; ATotal, AItemLength, AGap: Single;
  ASpacing: TDaisyDockSpacing; AReverse: Boolean = False): TArray<TDaisyDockSlot>;

// AFlow converted to the axis of APlacement (top to bottom <-> left to right)
function DaisyDockFlowFor(APlacement: TDaisyDockPlacement; AFlow: TDaisyDockFlow): TDaisyDockFlow;

// True when the items start at the end (bottom / right) of the dock
function DaisyDockFlowReversed(AFlow: TDaisyDockFlow): Boolean;

// How far content of AContent may be scrolled inside a view of AView (0 when it fits)
function DaisyClampScroll(AOffset, AContent, AView: Single): Single;

// Dock thickness (height of a top / bottom dock, width of a left / right dock), icon and label sizes
function DaisyDockThickness(ASize: TDaisySize): Integer;
function DaisyDockIconSize(ASize: TDaisySize): Integer;
function DaisyDockFontSize(ASize: TDaisySize): Integer;

// Diameter of a step circle and thickness of the line joining the circles
function DaisyStepCircle(ASize: TDaisySize): Integer;
function DaisyStepLine(ASize: TDaisySize): Integer;

implementation

{ TDaisyNavItem }

constructor TDaisyNavItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FEnabled := True;
  FCaption := 'Item ' + IntToStr(ID + 1);
end;

// The collection notifies its owner while the base constructor runs, before FIcon exists
function TDaisyNavItem.GetIcon: TDaisyIconSource;
begin
  if FIcon = nil then
    FIcon := TDaisyIconSource.Create(IconChanged);
  Result := FIcon;
end;

destructor TDaisyNavItem.Destroy;
begin
  FIcon.Free;
  inherited Destroy;
end;

procedure TDaisyNavItem.Assign(Source: TPersistent);
var
  LSource: TDaisyNavItem;
begin
  if Source is TDaisyNavItem then
  begin
    LSource := TDaisyNavItem(Source);
    FCaption := LSource.FCaption;
    Icon.Assign(LSource.Icon);
    FEnabled := LSource.FEnabled;
    FTag := LSource.FTag;
    FOnClick := LSource.FOnClick;
    Changed(False);
  end
  else
    inherited Assign(Source);
end;

function TDaisyNavItem.GetDisplayName: string;
begin
  Result := FCaption;
  if Result = '' then
    Result := inherited GetDisplayName;
end;

procedure TDaisyNavItem.Click;
begin
  if Assigned(FOnClick) then
    FOnClick(Self);
end;

procedure TDaisyNavItem.IconChanged(Sender: TObject);
begin
  Changed(False);
end;

procedure TDaisyNavItem.SetCaption(const Value: string);
begin
  if FCaption <> Value then
  begin
    FCaption := Value;
    Changed(False);
  end;
end;

procedure TDaisyNavItem.SetIcon(const Value: TDaisyIconSource);
begin
  Icon.Assign(Value);
end;

procedure TDaisyNavItem.SetEnabled(const Value: Boolean);
begin
  if FEnabled <> Value then
  begin
    FEnabled := Value;
    Changed(False);
  end;
end;

{ TDaisyStepItem }

procedure TDaisyStepItem.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
  if Source is TDaisyStepItem then
  begin
    FContent := TDaisyStepItem(Source).FContent;
    FVariant := TDaisyStepItem(Source).FVariant;
    Changed(False);
  end;
end;

procedure TDaisyStepItem.SetContent(const Value: string);
begin
  if FContent <> Value then
  begin
    FContent := Value;
    Changed(False);
  end;
end;

procedure TDaisyStepItem.SetVariant(const Value: TDaisyVariant);
begin
  if FVariant <> Value then
  begin
    FVariant := Value;
    Changed(False);
  end;
end;

{ Collections }

procedure TDaisyNavItems.Update(Item: TCollectionItem);
begin
  inherited;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

constructor TDaisyBreadcrumbItems.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TDaisyBreadcrumbItem);
end;

function TDaisyBreadcrumbItems.Add: TDaisyBreadcrumbItem;
begin
  Result := TDaisyBreadcrumbItem(inherited Add);
end;

function TDaisyBreadcrumbItems.GetItem(Index: Integer): TDaisyBreadcrumbItem;
begin
  Result := TDaisyBreadcrumbItem(inherited GetItem(Index));
end;

procedure TDaisyBreadcrumbItems.SetItem(Index: Integer; const Value: TDaisyBreadcrumbItem);
begin
  inherited SetItem(Index, Value);
end;

constructor TDaisyDockItems.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TDaisyDockItem);
end;

function TDaisyDockItems.Add: TDaisyDockItem;
begin
  Result := TDaisyDockItem(inherited Add);
end;

function TDaisyDockItems.GetItem(Index: Integer): TDaisyDockItem;
begin
  Result := TDaisyDockItem(inherited GetItem(Index));
end;

procedure TDaisyDockItems.SetItem(Index: Integer; const Value: TDaisyDockItem);
begin
  inherited SetItem(Index, Value);
end;

constructor TDaisyStepItems.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TDaisyStepItem);
end;

function TDaisyStepItems.Add: TDaisyStepItem;
begin
  Result := TDaisyStepItem(inherited Add);
end;

function TDaisyStepItems.GetItem(Index: Integer): TDaisyStepItem;
begin
  Result := TDaisyStepItem(inherited GetItem(Index));
end;

procedure TDaisyStepItems.SetItem(Index: Integer; const Value: TDaisyStepItem);
begin
  inherited SetItem(Index, Value);
end;

{ Pagination }

function DaisyPaginationPages(ACurrent, ACount, ASiblings, ABoundary: Integer): TArray<Integer>;
var
  LPages: TList<Integer>;
  LStart, LEnd, I: Integer;
begin
  SetLength(Result, 0);
  if ACount <= 0 then
    Exit;
  ACurrent := EnsureRange(ACurrent, 1, ACount);
  ASiblings := Max(0, ASiblings);
  ABoundary := Max(1, ABoundary);

  LPages := TList<Integer>.Create;
  try
    if ACount <= 2 * ABoundary + 2 * ASiblings + 3 then
      for I := 1 to ACount do
        LPages.Add(I)
    else
    begin
      // the window of pages around ACurrent, kept clear of the boundary pages
      LStart := Max(Min(ACurrent - ASiblings, ACount - ABoundary - ASiblings * 2 - 1), ABoundary + 2);
      LEnd := Min(Max(ACurrent + ASiblings, ABoundary + ASiblings * 2 + 2), ACount - ABoundary - 1);
      for I := 1 to ABoundary do
        LPages.Add(I);
      if LStart > ABoundary + 2 then
        LPages.Add(CDaisyPageGap)
      else
        LPages.Add(ABoundary + 1);
      for I := LStart to LEnd do
        LPages.Add(I);
      if LEnd < ACount - ABoundary - 1 then
        LPages.Add(CDaisyPageGap)
      else
        LPages.Add(ACount - ABoundary);
      for I := ACount - ABoundary + 1 to ACount do
        LPages.Add(I);
    end;
    Result := LPages.ToArray;
  finally
    LPages.Free;
  end;
end;

{ Dock }

function DaisyDockFlowFor(APlacement: TDaisyDockPlacement; AFlow: TDaisyDockFlow): TDaisyDockFlow;
begin
  Result := AFlow;
  if APlacement in [ddpLeft, ddpRight] then
  begin
    case AFlow of
      difLeftToRight: Result := difTopToBottom;
      difRightToLeft: Result := difBottomToTop;
    end;
  end
  else
    case AFlow of
      difTopToBottom: Result := difLeftToRight;
      difBottomToTop: Result := difRightToLeft;
    end;
end;

function DaisyDockFlowReversed(AFlow: TDaisyDockFlow): Boolean;
begin
  Result := AFlow in [difBottomToTop, difRightToLeft];
end;

function DaisyDockSlots(ACount: Integer; ATotal, AItemLength, AGap: Single;
  ASpacing: TDaisyDockSpacing; AReverse: Boolean): TArray<TDaisyDockSlot>;
var
  I: Integer;
  LLength: Single;
begin
  SetLength(Result, Max(0, ACount));
  if ACount <= 0 then
    Exit;
  if ASpacing = dspEven then
    LLength := ATotal / ACount
  else
    LLength := Min(AItemLength, (ATotal - AGap * (ACount - 1)) / ACount);
  LLength := Max(0, LLength);
  for I := 0 to ACount - 1 do
  begin
    Result[I].Extent := LLength;
    if ASpacing = dspEven then
      Result[I].Start := I * LLength
    else
      Result[I].Start := I * (LLength + AGap);
    if AReverse then
      Result[I].Start := ATotal - Result[I].Start - LLength;
  end;
end;

function DaisyClampScroll(AOffset, AContent, AView: Single): Single;
begin
  Result := EnsureRange(AOffset, 0, Max(0, AContent - AView));
end;

function DaisyDockThickness(ASize: TDaisySize): Integer;
const
  C: array[TDaisySize] of Integer = (44, 52, 64, 72, 80);
begin
  Result := C[ASize];
end;

function DaisyDockIconSize(ASize: TDaisySize): Integer;
const
  C: array[TDaisySize] of Integer = (16, 18, 20, 24, 28);
begin
  Result := C[ASize];
end;

function DaisyDockFontSize(ASize: TDaisySize): Integer;
const
  C: array[TDaisySize] of Integer = (9, 10, 11, 12, 14);
begin
  Result := C[ASize];
end;

function DaisyStepCircle(ASize: TDaisySize): Integer;
const
  C: array[TDaisySize] of Integer = (20, 26, 32, 40, 48);
begin
  Result := C[ASize];
end;

function DaisyStepLine(ASize: TDaisySize): Integer;
const
  C: array[TDaisySize] of Integer = (4, 6, 8, 10, 12);
begin
  Result := C[ASize];
end;

end.
