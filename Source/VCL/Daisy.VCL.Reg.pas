unit Daisy.VCL.Reg;

interface

procedure Register;

implementation

{$R Daisy.VCL.Reg.dcr}
{$R Daisy.VCL.Reg2.dcr}
{$R Daisy.VCL.Reg3.dcr}

uses
  System.Classes, DesignIntf, Vcl.Controls, Daisy.VCL.Control, Daisy.VCL.Button, Daisy.VCL.Card, Daisy.VCL.Alert,
  Daisy.VCL.Progress, Daisy.VCL.RadialProgress, Daisy.VCL.Toast, Daisy.VCL.Calendar, Daisy.VCL.DatePicker,
  Daisy.VCL.IconButton, Daisy.VCL.LoadingButton, Daisy.VCL.Dropdown, Daisy.VCL.Fab,
  Daisy.VCL.Accordion, Daisy.VCL.Badge,
  Daisy.VCL.Chat, Daisy.VCL.Countdown, Daisy.VCL.List, Daisy.VCL.Stat,
  Daisy.VCL.Panel, Daisy.VCL.Labels, Daisy.VCL.SVGImage, Daisy.VCL.Status,
  Daisy.VCL.Table, Daisy.VCL.Select, Daisy.VCL.FormStyler, Daisy.VCL.Toggle,
  Daisy.VCL.TextInput, Daisy.VCL.TextArea, Daisy.VCL.Menu, Daisy.VCL.MainMenu,
  Daisy.VCL.PopupMenu, Daisy.VCL.CheckBox, Daisy.VCL.PageControl,
  Daisy.VCL.Indicator, Daisy.VCL.FieldSet, Daisy.VCL.Range, Daisy.VCL.Rating,
  Daisy.VCL.Swap, Daisy.VCL.Stack, Daisy.VCL.ThemeController,
  Daisy.VCL.Breadcrumbs, Daisy.VCL.Dock, Daisy.VCL.Link, Daisy.VCL.Pagination, Daisy.VCL.Steps,
  Daisy.VCL.TitleBarPanel, Daisy.VCL.Loading, Daisy.VCL.Radio,
  Daisy.VCL.Chart;

const
  // Pages follow the component groups in the daisyUI documentation
  CPageActions = 'DaisyUI - Actions';
  CPageDisplay = 'DaisyUI - Display';
  CPageFeedback = 'DaisyUI - Feedback';
  CPageInput = 'DaisyUI - Input';
  CPageNavigation = 'DaisyUI - Navigation';
  CPageLayout = 'DaisyUI - Layout';

procedure Register;
begin
  // a plain TComponent is offered by every designer, so tie it to the VCL one
  GroupDescendentsWith(TDaisyFormStyler, TControl);
  // the dock always uses the default (base) colours
  UnlistPublishedProperty(TDaisyDock, 'Variant');
  UnlistPublishedProperty(TDaisyChart, 'Variant');
  RegisterComponents(CPageActions, [TDaisyButton, TDaisySquareButton, TDaisyCircleButton,
    TDaisyLoadingButton, TDaisyAnimationButton, TDaisyBadgeButton, TDaisyDropdownMenu,
    TDaisyFloatingActionButton, TDaisySwap, TDaisyThemeController]);
  RegisterComponents(CPageDisplay,   [TDaisyAccordion, TDaisyBadge, TDaisyCard, TDaisyChart,
      TDaisyChatBubble, TDaisyCountdown, TDaisyLabel, TDaisyList, TDaisyStat, TDaisyStatus, TDaisySVGImage,
    TDaisyTable]);
  RegisterComponents(CPageFeedback, [TDaisyAlert, TDaisyLoading, TDaisyProgress,
    TDaisyRadialProgress, TDaisyToast]);
  RegisterComponents(CPageInput, [TDaisyCalendar, TDaisyCheckBox, TDaisyDatePicker,
    TDaisyFieldSet, TDaisyRadio, TDaisyRange, TDaisyRating, TDaisySelect, TDaisyTextArea,
    TDaisyTextInput, TDaisyToggle]);
  RegisterComponents(CPageNavigation, [TDaisyBreadcrumbs, TDaisyDock, TDaisyLink, TDaisyMainMenu,
    TDaisyMenu, TDaisyPageControl, TDaisyPagination, TDaisyPopupMenu, TDaisySteps,
    TDaisyTabSheet]);
  RegisterComponents(CPageLayout, [TDaisyFormStyler, TDaisyIndicator, TDaisyPanel, TDaisyStack,
    TDaisyTitleBarPanel]);
end;

end.
