unit Daisy.FMX.Reg;

interface

procedure Register;

implementation

{$R Daisy.FMX.Reg.dcr}
{$R Daisy.FMX.Reg2.dcr}
{$R Daisy.FMX.Reg3.dcr}

uses
  System.Classes, DesignIntf, FMX.Types, Daisy.FMX.Control, Daisy.FMX.Button, Daisy.FMX.Card, Daisy.FMX.Alert,
  Daisy.FMX.Progress, Daisy.FMX.RadialProgress, Daisy.FMX.Toast, Daisy.FMX.Calendar, Daisy.FMX.DatePicker,
  Daisy.FMX.IconButton, Daisy.FMX.LoadingButton, Daisy.FMX.Dropdown, Daisy.FMX.Fab,
  Daisy.FMX.Accordion, Daisy.FMX.Badge,
  Daisy.FMX.Chat, Daisy.FMX.Countdown, Daisy.FMX.List, Daisy.FMX.Stat,
  Daisy.FMX.Panel, Daisy.FMX.Labels, Daisy.FMX.SVGImage, Daisy.FMX.Status,
  Daisy.FMX.Table, Daisy.FMX.Select, Daisy.FMX.FormStyler, Daisy.FMX.Toggle,
  Daisy.FMX.TextInput, Daisy.FMX.TextArea, Daisy.FMX.Menu, Daisy.FMX.MainMenu,
  Daisy.FMX.PopupMenu, Daisy.FMX.CheckBox, Daisy.FMX.PageControl,
  Daisy.FMX.Indicator, Daisy.FMX.FieldSet, Daisy.FMX.Range, Daisy.FMX.Rating,
  Daisy.FMX.Swap, Daisy.FMX.Stack, Daisy.FMX.ThemeController,
  Daisy.FMX.Breadcrumbs, Daisy.FMX.Dock, Daisy.FMX.Link, Daisy.FMX.Pagination, Daisy.FMX.Steps,
  Daisy.FMX.TitleBarPanel;

const
  // Pages follow the component groups in the daisyUI documentation
  CPageActions = 'DaisyUI FMX - Actions';
  CPageDisplay = 'DaisyUI FMX - Display';
  CPageFeedback = 'DaisyUI FMX - Feedback';
  CPageInput = 'DaisyUI FMX - Input';
  CPageNavigation = 'DaisyUI FMX - Navigation';
  CPageLayout = 'DaisyUI FMX - Layout';

procedure Register;
begin
  // a plain TComponent is offered by every designer, so tie it to the FMX one
  GroupDescendentsWith(TDaisyFmxFormStyler, TFmxObject);
  // the dock and the title bar panel always use the default (base) colours
  UnlistPublishedProperty(TDaisyFmxDock, 'Variant');
  UnlistPublishedProperty(TDaisyFmxTitleBarPanel, 'Variant');
  RegisterComponents(CPageActions, [TDaisyFmxButton, TDaisyFmxSquareButton,
    TDaisyFmxCircleButton, TDaisyFmxLoadingButton, TDaisyFmxAnimationButton,
    TDaisyFmxBadgeButton, TDaisyFmxDropdownMenu, TDaisyFmxFloatingActionButton, TDaisyFmxSwap,
    TDaisyFmxThemeController]);
  RegisterComponents(CPageDisplay, [TDaisyFmxAccordion, TDaisyFmxBadge, TDaisyFmxCard,
    TDaisyFmxChatBubble, TDaisyFmxCountdown, TDaisyFmxLabel, TDaisyFmxList, TDaisyFmxStat,
    TDaisyFmxStatus, TDaisyFmxSVGImage, TDaisyFmxTable]);
  RegisterComponents(CPageFeedback, [TDaisyFmxAlert, TDaisyFmxProgress, TDaisyFmxRadialProgress,
    TDaisyFmxToast]);
  RegisterComponents(CPageInput, [TDaisyFmxCalendar, TDaisyFmxCheckBox, TDaisyFmxDatePicker,
    TDaisyFmxFieldSet, TDaisyFmxRange, TDaisyFmxRating, TDaisyFmxSelect,
    TDaisyFmxTextArea, TDaisyFmxTextInput, TDaisyFmxToggle]);
  RegisterComponents(CPageNavigation, [TDaisyFmxBreadcrumbs, TDaisyFmxDock, TDaisyFmxLink,
    TDaisyFmxMainMenu, TDaisyFmxMenu, TDaisyFmxPageControl, TDaisyFmxPagination,
    TDaisyFmxPopupMenu, TDaisyFmxSteps, TDaisyFmxTabSheet]);
  RegisterComponents(CPageLayout, [TDaisyFmxFormStyler, TDaisyFmxIndicator, TDaisyFmxPanel,
    TDaisyFmxStack, TDaisyFmxTitleBarPanel]);
end;

end.
