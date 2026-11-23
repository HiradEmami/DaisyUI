unit MainVCL;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.StrUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.ActnList, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Daisy.Theme, Daisy.VCL.Control, Daisy.VCL.Button, Daisy.VCL.Panel, Daisy.VCL.Card, Daisy.VCL.Alert,
  Daisy.VCL.Select, Daisy.VCL.FormStyler, Daisy.VCL.PageControl, Daisy.VCL.CheckBox,
  Daisy.VCL.TextInput, Daisy.VCL.Indicator, Daisy.VCL.FieldSet,
  Daisy.VCL.Swap, Daisy.VCL.Stack, Daisy.VCL.ThemeController, System.Actions,
  Daisy.Navigation, Daisy.VCL.Breadcrumbs, Daisy.VCL.Dock, Daisy.VCL.Link, Daisy.VCL.Pagination,
  Daisy.VCL.Steps, Daisy.VCL.Badge, Daisy.VCL.Toggle, Daisy.VCL.TitleBarPanel,
  Vcl.TitleBarCtrls;

type
  TForm10 = class(TForm)
    lblTheme: TLabel;
    selTheme: TDaisySelect;
    Styler: TDaisyFormStyler;
    tbpMain: TDaisyTitleBarPanel;
    badgeTitle: TDaisyBadge;
    edtTitleSearch: TDaisyTextInput;
    togTitle: TDaisyToggle;
    pcMain: TDaisyPageControl;
    tsVariants: TDaisyTabSheet;
    tsStyles: TDaisyTabSheet;
    tsSizes: TDaisyTabSheet;
    tsCards: TDaisyTabSheet;
    tsAlerts: TDaisyTabSheet;
    lblVariants: TLabel;
    btnDefault: TDaisyButton;
    btnNeutral: TDaisyButton;
    btnPrimary: TDaisyButton;
    btnSecondary: TDaisyButton;
    btnAccent: TDaisyButton;
    btnInfo: TDaisyButton;
    btnSuccess: TDaisyButton;
    btnWarning: TDaisyButton;
    btnError: TDaisyButton;
    lblStyles: TLabel;
    btnOutline: TDaisyButton;
    btnDash: TDaisyButton;
    btnSoft: TDaisyButton;
    btnGhost: TDaisyButton;
    btnDisabled: TDaisyButton;
    lblSizes: TLabel;
    btnXS: TDaisyButton;
    btnSM: TDaisyButton;
    btnMD: TDaisyButton;
    btnLG: TDaisyButton;
    btnXL: TDaisyButton;
    lblCards: TLabel;
    cardDefault: TDaisyCard;
    btnBuyDefault: TDaisyButton;
    cardPrimary: TDaisyCard;
    btnBuyPrimary: TDaisyButton;
    cardBordered: TDaisyCard;
    btnBuyBordered: TDaisyButton;
    lblAlerts: TLabel;
    alertStatus: TDaisyAlert;
    alertSuccess: TDaisyAlert;
    alertWarning: TDaisyAlert;
    alertError: TDaisyAlert;
    alertDefault: TDaisyAlert;
    tsIndicator: TDaisyTabSheet;
    lblIndicator: TLabel;
    lblIndicatorPlacement: TLabel;
    lblIndicatorResult: TLabel;
    indBadge: TDaisyIndicator;
    pnlBadge: TDaisyPanel;
    indStatus: TDaisyIndicator;
    pnlStatus: TDaisyPanel;
    indButton: TDaisyIndicator;
    pnlButton: TDaisyPanel;
    indLarge: TDaisyIndicator;
    pnlLarge: TDaisyPanel;
    indNew: TDaisyIndicator;
    pnlNew: TDaisyPanel;
    indP1: TDaisyIndicator;
    pnlP1: TDaisyPanel;
    indP2: TDaisyIndicator;
    pnlP2: TDaisyPanel;
    indP3: TDaisyIndicator;
    pnlP3: TDaisyPanel;
    indP4: TDaisyIndicator;
    pnlP4: TDaisyPanel;
    indP5: TDaisyIndicator;
    pnlP5: TDaisyPanel;
    indP6: TDaisyIndicator;
    pnlP6: TDaisyPanel;
    tsFieldSet: TDaisyTabSheet;
    lblFieldSet: TLabel;
    fsBasic: TDaisyFieldSet;
    edtFsTitle: TDaisyTextInput;
    fsLogin: TDaisyFieldSet;
    edtFsEmail: TDaisyTextInput;
    edtFsPassword: TDaisyTextInput;
    btnFsLogin: TDaisyButton;
    fsSoft: TDaisyFieldSet;
    chkFsNews: TDaisyCheckBox;
    chkFsTips: TDaisyCheckBox;
    fsOutline: TDaisyFieldSet;
    tsSwap: TDaisyTabSheet;
    lblSwap: TLabel;
    lblSwapText: TLabel;
    lblSwapVolume: TLabel;
    lblSwapRotate: TLabel;
    lblSwapFlip: TLabel;
    lblSwapInd: TLabel;
    lblSwapResult: TLabel;
    swText: TDaisySwap;
    swVolume: TDaisySwap;
    swRotate: TDaisySwap;
    swFlip: TDaisySwap;
    swInd: TDaisySwap;
    tsStack: TDaisyTabSheet;
    lblStack: TLabel;
    lblStackBottom: TLabel;
    lblStackTop: TLabel;
    lblStackStart: TLabel;
    lblStackEnd: TLabel;
    stkBottom: TDaisyStack;
    stkBottomC: TDaisyCard;
    stkBottomB: TDaisyCard;
    stkBottomA: TDaisyCard;
    stkTop: TDaisyStack;
    stkTopC: TDaisyCard;
    stkTopB: TDaisyCard;
    stkTopA: TDaisyCard;
    stkStart: TDaisyStack;
    stkStartC: TDaisyCard;
    stkStartB: TDaisyCard;
    stkStartA: TDaisyCard;
    stkEnd: TDaisyStack;
    stkEndC: TDaisyCard;
    stkEndB: TDaisyCard;
    stkEndA: TDaisyCard;
    lblStackHint: TLabel;
    stkPlainBottom: TDaisyStack;
    stkPlainBottomC: TDaisyCard;
    stkPlainBottomB: TDaisyCard;
    stkPlainBottomA: TDaisyCard;
    stkNeutralTop: TDaisyStack;
    stkNeutralTopC: TDaisyCard;
    stkNeutralTopB: TDaisyCard;
    stkNeutralTopA: TDaisyCard;
    stkPlainStart: TDaisyStack;
    stkPlainStartC: TDaisyCard;
    stkPlainStartB: TDaisyCard;
    stkPlainStartA: TDaisyCard;
    stkNeutralEnd: TDaisyStack;
    stkNeutralEndC: TDaisyCard;
    stkNeutralEndB: TDaisyCard;
    stkNeutralEndA: TDaisyCard;
    themeCtl: TDaisyThemeController;
    alMain: TActionList;
    actBuyNow: TAction;
    chkRTL: TDaisyCheckBox;
    tsNavigation: TDaisyTabSheet;
    lblNavCrumbs: TLabel;
    lblNavLink: TLabel;
    lblNavPagination: TLabel;
    lblNavSteps: TLabel;
    lblNavResult: TLabel;
    lblCrumbsScroll: TLabel;
    lblStepsResponsive: TLabel;
    crumbsIcons: TDaisyBreadcrumbs;
    crumbsSlash: TDaisyBreadcrumbs;
    crumbsScroll: TDaisyBreadcrumbs;
    lnkDefault: TDaisyLink;
    lnkPrimary: TDaisyLink;
    lnkHover: TDaisyLink;
    lnkAccent: TDaisyLink;
    lnkSuccess: TDaisyLink;
    lnkWarning: TDaisyLink;
    lnkError: TDaisyLink;
    lnkUrl: TDaisyLink;
    pagBasic: TDaisyPagination;
    pagSmall: TDaisyPagination;
    pagPrevNext: TDaisyPagination;
    pagSeparate: TDaisyPagination;
    stepsIcons: TDaisySteps;
    stepsColors: TDaisySteps;
    stepsVertical: TDaisySteps;
    stepsResponsive: TDaisySteps;
    tsDock: TDaisyTabSheet;
    lblDock: TLabel;
    lblDockEven: TLabel;
    lblDockNormal: TLabel;
    lblDockSmall: TLabel;
    lblDockLarge: TLabel;
    lblDockLeft: TLabel;
    lblDockLeftNormal: TLabel;
    lblDockRight: TLabel;
    lblDockRightNormal: TLabel;
    lblDockResult: TLabel;
    dockBottomEven: TDaisyDock;
    dockBottomNormal: TDaisyDock;
    dockSmall: TDaisyDock;
    dockLarge: TDaisyDock;
    dockLeft: TDaisyDock;
    dockLeftNormal: TDaisyDock;
    dockRight: TDaisyDock;
    dockRightNormal: TDaisyDock;
    procedure CrumbClick(Sender: TObject; AIndex: Integer);
    procedure PageChange(Sender: TObject);
    procedure DockChange(Sender: TObject);
    procedure RTLChange(Sender: TObject);
    procedure SwapChange(Sender: TObject);
    procedure ThemeControllerChange(Sender: TObject);
    procedure IndicatorItemClick(Sender: TObject);
    procedure ThemeSelectChange(Sender: TObject);
    procedure CardActionClick(Sender: TObject);
  end;

var
  Form10: TForm10;

implementation

{$R *.dfm}

procedure TForm10.RTLChange(Sender: TObject);
const
  Modes: array[Boolean] of TBiDiMode = (bdLeftToRight, bdRightToLeft);
begin
  if BiDiMode = Modes[chkRTL.Checked] then
    Exit;
  TDaisyControl.ApplyBiDiMode(Self, Modes[chkRTL.Checked]);
end;

procedure TForm10.ThemeSelectChange(Sender: TObject);
begin
  Styler.ApplyTheme(TDaisyThemeKind(selTheme.ItemIndex + 1));
end;

procedure TForm10.CardActionClick(Sender: TObject);
begin
  alertStatus.Variant := dvSuccess;
  alertStatus.Caption := 'Thanks! Your order was placed at ' + FormatDateTime('hh:nn:ss', Now) + '.';
end;

procedure TForm10.IndicatorItemClick(Sender: TObject);
begin
  lblIndicatorResult.Caption := 'Inbox clicked at ' + FormatDateTime('hh:nn:ss', Now);
end;

procedure TForm10.CrumbClick(Sender: TObject; AIndex: Integer);
var
  LCrumbs: TDaisyBreadcrumbs;
begin
  LCrumbs := Sender as TDaisyBreadcrumbs;
  lblNavResult.Caption := 'Breadcrumb "' + LCrumbs.Items[AIndex].Caption + '" clicked';
end;

procedure TForm10.PageChange(Sender: TObject);
begin
  lblNavResult.Caption := 'Page ' + IntToStr((Sender as TDaisyPagination).CurrentPage) + ' selected';
end;

procedure TForm10.DockChange(Sender: TObject);
var
  LDock: TDaisyDock;
begin
  LDock := Sender as TDaisyDock;
  lblDockResult.Caption := LDock.Items[LDock.ItemIndex].Caption + ' selected in ' + LDock.Name;
end;

procedure TForm10.ThemeControllerChange(Sender: TObject);
begin
  selTheme.ItemIndex := Ord(DaisyThemes.Current) - 1;
end;

procedure TForm10.SwapChange(Sender: TObject);
begin
  if Sender is TDaisySwap then
    lblSwapResult.Caption := TDaisySwap(Sender).Name + ' is now ' +
      IfThen(TDaisySwap(Sender).Active, 'on', 'off');
end;

end.
