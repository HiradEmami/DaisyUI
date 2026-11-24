object Form10: TForm10
  Left = 0
  Top = 0
  Caption = 'DaisyUI VCL demo'
  ClientHeight = 632
  ClientWidth = 1000
  Color = clBtnFace
  CustomTitleBar.Control = tbpMain
  CustomTitleBar.Enabled = True
  CustomTitleBar.Height = 31
  CustomTitleBar.BackgroundColor = clWhite
  CustomTitleBar.ForegroundColor = 65793
  CustomTitleBar.InactiveBackgroundColor = clWhite
  CustomTitleBar.InactiveForegroundColor = 10066329
  CustomTitleBar.ButtonForegroundColor = 65793
  CustomTitleBar.ButtonBackgroundColor = clWhite
  CustomTitleBar.ButtonHoverForegroundColor = 65793
  CustomTitleBar.ButtonHoverBackgroundColor = 16053492
  CustomTitleBar.ButtonPressedForegroundColor = 65793
  CustomTitleBar.ButtonPressedBackgroundColor = 15395562
  CustomTitleBar.ButtonInactiveForegroundColor = 10066329
  CustomTitleBar.ButtonInactiveBackgroundColor = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  GlassFrame.Enabled = True
  GlassFrame.Top = 31
  Position = poScreenCenter
  StyleElements = [seFont, seClient]
  DesignSize = (
    1000
    632)
  TextHeight = 15
  object lblTheme: TLabel
    Left = 24
    Top = 58
    Width = 52
    Height = 21
    Caption = 'Theme'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object themeCtl: TDaisyThemeController
    Left = 400
    Top = 54
    Width = 128
    Height = 30
    Cursor = crHandPoint
    TabOrder = 2
    TabStop = True
    Caption = 'Dark mode'
    OnChange = ThemeControllerChange
  end
  object chkRTL: TDaisyCheckBox
    Left = 560
    Top = 54
    Width = 116
    Height = 30
    Cursor = crHandPoint
    TabOrder = 3
    TabStop = True
    Caption = 'Right-to-left'
    OnChange = RTLChange
  end
  object selTheme: TDaisySelect
    Left = 96
    Top = 48
    Width = 200
    Height = 40
    Hint = ''
    Variant = dvNeutral
    TabOrder = 0
    TabStop = True
    Items.Strings = (
      'Light'
      'Dark'
      'Cupcake'
      'Dracula'
      'Corporate'
      'Pastel'
      'Wireframe'
      'CMYK'
      'Winter'
      'Dim'
      'Nord'
      'Silk'
      'Bumblebee'
      'Emerald'
      'Halloween'
      'Garden'
      'Forest'
      'Lofi'
      'Fantasy'
      'Autumn')
    ItemIndex = 0
    Placeholder = 'Pick one'
    OnChange = ThemeSelectChange
  end
  object pcMain: TDaisyPageControl
    Left = 16
    Top = 104
    Width = 968
    Height = 512
    ContentPadding = 0
    CornerRadius = 0
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
    TabStop = True
    ActivePageIndex = 0
    object tsAlerts: TDaisyTabSheet
      Left = 1
      Top = 41
      Width = 966
      Height = 470
      TabOrder = 4
      Caption = 'Alerts'
      object lblAlerts: TLabel
        Left = 16
        Top = 8
        Width = 44
        Height = 21
        Caption = 'Alerts'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object alertStatus: TDaisyAlert
        Left = 16
        Top = 40
        Width = 560
        Height = 48
        Variant = dvInfo
        TabOrder = 0
        Caption = 'Click "Buy Now" on a card to update this alert.'
      end
      object alertSuccess: TDaisyAlert
        Left = 16
        Top = 100
        Width = 560
        Height = 48
        Variant = dvSuccess
        TabOrder = 1
        Caption = 'Your purchase has been confirmed!'
      end
      object alertWarning: TDaisyAlert
        Left = 16
        Top = 160
        Width = 560
        Height = 48
        Variant = dvWarning
        Style = dsSoft
        TabOrder = 2
        Caption = 'Warning: Invalid email address!'
      end
      object alertError: TDaisyAlert
        Left = 16
        Top = 220
        Width = 560
        Height = 48
        Variant = dvError
        Style = dsOutline
        TabOrder = 3
        Caption = 'Error! Task failed successfully.'
      end
      object alertDefault: TDaisyAlert
        Left = 16
        Top = 280
        Width = 560
        Height = 48
        TabOrder = 4
        Caption = 'New software update available.'
      end
    end
    object tsIndicator: TDaisyTabSheet
      Left = 1
      Top = 41
      Width = 966
      Height = 470
      TabOrder = 5
      Caption = 'Indicator'
      object lblIndicator: TLabel
        Left = 16
        Top = 8
        Width = 69
        Height = 21
        Caption = 'Indicator'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblIndicatorPlacement: TLabel
        Left = 16
        Top = 148
        Width = 160
        Height = 15
        Caption = 'Placement: start / center / end'
      end
      object lblIndicatorResult: TLabel
        Left = 16
        Top = 280
        Width = 245
        Height = 15
        Caption = 'Click the Inbox button item to update this text.'
      end
      object indBadge: TDaisyIndicator
        Left = 16
        Top = 40
        Width = 120
        Height = 88
        TabOrder = 0
        ItemText = '99'
        object pnlBadge: TDaisyPanel
          Left = 0
          Top = 10
          Width = 106
          Height = 78
          Variant = dvNeutral
          Style = dsSoft
          ShadowSize = 0
          TabOrder = 0
        end
      end
      object indStatus: TDaisyIndicator
        Left = 156
        Top = 40
        Width = 120
        Height = 88
        TabOrder = 1
        ItemKind = ikStatus
        ItemText = '99'
        ItemVariant = dvSuccess
        object pnlStatus: TDaisyPanel
          Left = 0
          Top = 4
          Width = 116
          Height = 84
          Variant = dvNeutral
          Style = dsSoft
          ShadowSize = 0
          TabOrder = 0
        end
      end
      object indButton: TDaisyIndicator
        Left = 296
        Top = 40
        Width = 160
        Height = 88
        TabOrder = 2
        ItemKind = ikButton
        ItemText = 'Inbox'
        ItemVariant = dvPrimary
        OnItemClick = IndicatorItemClick
        object pnlButton: TDaisyPanel
          Left = 0
          Top = 20
          Width = 130
          Height = 68
          Variant = dvNeutral
          Style = dsSoft
          ShadowSize = 0
          TabOrder = 0
        end
      end
      object indLarge: TDaisyIndicator
        Left = 476
        Top = 40
        Width = 120
        Height = 88
        TabOrder = 3
        ItemText = '12'
        ItemVariant = dvError
        ItemSize = dzLG
        object pnlLarge: TDaisyPanel
          Left = 0
          Top = 14
          Width = 104
          Height = 74
          Variant = dvNeutral
          Style = dsSoft
          ShadowSize = 0
          TabOrder = 0
        end
      end
      object indNew: TDaisyIndicator
        Left = 616
        Top = 40
        Width = 140
        Height = 88
        TabOrder = 4
        ItemText = 'NEW'
        ItemVariant = dvInfo
        ItemSize = dzSM
        object pnlNew: TDaisyPanel
          Left = 0
          Top = 10
          Width = 124
          Height = 78
          Variant = dvNeutral
          Style = dsSoft
          ShadowSize = 0
          TabOrder = 0
        end
      end
      object indP1: TDaisyIndicator
        Left = 16
        Top = 172
        Width = 104
        Height = 72
        TabOrder = 5
        ItemKind = ikStatus
        ItemText = '99'
        ItemVariant = dvPrimary
        HorizontalPlacement = ihStart
        object pnlP1: TDaisyPanel
          Left = 4
          Top = 4
          Width = 96
          Height = 64
          Variant = dvNeutral
          Style = dsSoft
          ShadowSize = 0
          TabOrder = 0
        end
      end
      object indP2: TDaisyIndicator
        Left = 136
        Top = 172
        Width = 104
        Height = 72
        TabOrder = 6
        ItemKind = ikStatus
        ItemText = '99'
        HorizontalPlacement = ihCenter
        object pnlP2: TDaisyPanel
          Left = 4
          Top = 4
          Width = 96
          Height = 64
          Variant = dvNeutral
          Style = dsSoft
          ShadowSize = 0
          TabOrder = 0
        end
      end
      object indP3: TDaisyIndicator
        Left = 256
        Top = 172
        Width = 104
        Height = 72
        TabOrder = 7
        ItemKind = ikStatus
        ItemText = '99'
        ItemVariant = dvAccent
        VerticalPlacement = ivMiddle
        object pnlP3: TDaisyPanel
          Left = 4
          Top = 4
          Width = 96
          Height = 64
          Variant = dvNeutral
          Style = dsSoft
          ShadowSize = 0
          TabOrder = 0
        end
      end
      object indP4: TDaisyIndicator
        Left = 376
        Top = 172
        Width = 104
        Height = 72
        TabOrder = 8
        ItemKind = ikStatus
        ItemText = '99'
        ItemVariant = dvWarning
        HorizontalPlacement = ihStart
        VerticalPlacement = ivBottom
        object pnlP4: TDaisyPanel
          Left = 4
          Top = 4
          Width = 96
          Height = 64
          Variant = dvNeutral
          Style = dsSoft
          ShadowSize = 0
          TabOrder = 0
        end
      end
      object indP5: TDaisyIndicator
        Left = 496
        Top = 172
        Width = 104
        Height = 72
        TabOrder = 9
        ItemKind = ikStatus
        ItemText = '99'
        ItemVariant = dvInfo
        HorizontalPlacement = ihCenter
        VerticalPlacement = ivBottom
        object pnlP5: TDaisyPanel
          Left = 4
          Top = 4
          Width = 96
          Height = 64
          Variant = dvNeutral
          Style = dsSoft
          ShadowSize = 0
          TabOrder = 0
        end
      end
      object indP6: TDaisyIndicator
        Left = 616
        Top = 172
        Width = 104
        Height = 72
        TabOrder = 10
        ItemKind = ikStatus
        ItemText = '99'
        ItemVariant = dvError
        VerticalPlacement = ivBottom
        object pnlP6: TDaisyPanel
          Left = 4
          Top = 4
          Width = 96
          Height = 64
          Variant = dvNeutral
          Style = dsSoft
          ShadowSize = 0
          TabOrder = 0
        end
      end
    end
    object tsNavigation: TDaisyTabSheet
      Left = 1
      Top = 41
      Width = 966
      Height = 470
      TabOrder = 9
      Caption = 'Navigation'
      object lblNavCrumbs: TLabel
        Left = 16
        Top = 8
        Width = 100
        Height = 21
        Caption = 'Breadcrumbs'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblNavLink: TLabel
        Left = 16
        Top = 176
        Width = 32
        Height = 21
        Caption = 'Link'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblNavPagination: TLabel
        Left = 480
        Top = 8
        Width = 84
        Height = 21
        Caption = 'Pagination'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblNavSteps: TLabel
        Left = 16
        Top = 280
        Width = 41
        Height = 21
        Caption = 'Steps'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblNavResult: TLabel
        Left = 480
        Top = 232
        Width = 125
        Height = 15
        Caption = 'Click a crumb or a page'
      end
      object lblCrumbsScroll: TLabel
        Left = 272
        Top = 128
        Width = 201
        Height = 15
        Caption = 'Too wide: scroll with the mouse wheel'
      end
      object lblStepsResponsive: TLabel
        Left = 730
        Top = 240
        Width = 203
        Height = 15
        Caption = 'Vertical because it is narrower than 300'
      end
      object crumbsIcons: TDaisyBreadcrumbs
        Left = 16
        Top = 40
        Width = 440
        Height = 32
        TabOrder = 12
        Items = <
          item
            Caption = 'Home'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              '<path d="M3 12l9 -9l9 9"/><path d="M5 10v10h14v-10"/></svg>')
          end
          item
            Caption = 'Documents'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              
                '<path d="M5 4h4l3 3h7a2 2 0 0 1 2 2v8a2 2 0 0 1 -2 2h-14a2 2 0 0' +
                ' 1 -2 -2v-11a2 2 0 0 1 2 -2"/></svg>')
          end
          item
            Caption = 'Add Document'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              
                '<path d="M14 3v4a1 1 0 0 0 1 1h4"/><path d="M17 21h-10a2 2 0 0 1' +
                ' -2 -2v-14a2 2 0 0 1 2 -2h7l5 5v11a2 2 0 0 1 -2 2z"/></svg>')
          end>
        OnItemClick = CrumbClick
      end
      object crumbsSlash: TDaisyBreadcrumbs
        Left = 16
        Top = 80
        Width = 440
        Height = 32
        TabOrder = 13
        Items = <
          item
            Caption = 'Home'
          end
          item
            Caption = 'Library'
          end
          item
            Caption = 'Data'
          end>
        Separator = dbsSlash
        OnItemClick = CrumbClick
      end
      object crumbsScroll: TDaisyBreadcrumbs
        Left = 16
        Top = 120
        Width = 240
        Height = 32
        Variant = dvPrimary
        TabOrder = 14
        Items = <
          item
            Caption = 'Home'
          end
          item
            Caption = 'Products'
          end
          item
            Caption = 'Electronics'
          end
          item
            Caption = 'Phones'
          end
          item
            Caption = 'Details'
          end>
        OnItemClick = CrumbClick
      end
      object lnkDefault: TDaisyLink
        Left = 16
        Top = 208
        Width = 73
        Height = 23
        Cursor = crHandPoint
        TabOrder = 0
        TabStop = True
        Caption = 'Default link'
      end
      object lnkPrimary: TDaisyLink
        Left = 130
        Top = 208
        Width = 76
        Height = 23
        Cursor = crHandPoint
        Variant = dvPrimary
        TabOrder = 1
        TabStop = True
        Caption = 'Primary link'
      end
      object lnkHover: TDaisyLink
        Left = 260
        Top = 208
        Width = 122
        Height = 23
        Cursor = crHandPoint
        Variant = dvSecondary
        TabOrder = 2
        TabStop = True
        Caption = 'Underline on hover'
        Underline = dluHover
      end
      object lnkAccent: TDaisyLink
        Left = 400
        Top = 208
        Width = 70
        Height = 23
        Cursor = crHandPoint
        Variant = dvAccent
        TabOrder = 3
        TabStop = True
        Caption = 'Accent link'
      end
      object lnkSuccess: TDaisyLink
        Left = 16
        Top = 240
        Width = 75
        Height = 23
        Cursor = crHandPoint
        Variant = dvSuccess
        TabOrder = 4
        TabStop = True
        Caption = 'Success link'
      end
      object lnkWarning: TDaisyLink
        Left = 130
        Top = 240
        Width = 81
        Height = 23
        Cursor = crHandPoint
        Variant = dvWarning
        TabOrder = 5
        TabStop = True
        Caption = 'Warning link'
      end
      object lnkError: TDaisyLink
        Left = 260
        Top = 240
        Width = 59
        Height = 23
        Cursor = crHandPoint
        Variant = dvError
        TabOrder = 6
        TabStop = True
        Caption = 'Error link'
      end
      object lnkUrl: TDaisyLink
        Left = 400
        Top = 240
        Width = 113
        Height = 23
        Cursor = crHandPoint
        Variant = dvInfo
        TabOrder = 7
        TabStop = True
        Caption = 'Open daisyui.com'
        URL = 'https://daisyui.com'
      end
      object pagBasic: TDaisyPagination
        Left = 480
        Top = 40
        Width = 470
        Height = 40
        TabOrder = 8
        TabStop = True
        CurrentPage = 4
        PrevCaption = #171
        NextCaption = #187
        OnChange = PageChange
      end
      object pagSmall: TDaisyPagination
        Left = 480
        Top = 88
        Width = 470
        Height = 32
        Variant = dvPrimary
        SizeKind = dzSM
        TabOrder = 9
        TabStop = True
        PageCount = 20
        CurrentPage = 10
        PrevCaption = #171
        NextCaption = #187
        OnChange = PageChange
      end
      object pagPrevNext: TDaisyPagination
        Left = 480
        Top = 128
        Width = 300
        Height = 40
        TabOrder = 10
        TabStop = True
        PageCount = 5
        ShowPageNumbers = False
        PrevCaption = 'Previous'
        NextCaption = 'Next'
        OnChange = PageChange
      end
      object pagSeparate: TDaisyPagination
        Left = 480
        Top = 176
        Width = 470
        Height = 40
        Variant = dvSecondary
        TabOrder = 11
        TabStop = True
        PageCount = 7
        CurrentPage = 2
        PrevCaption = #171
        NextCaption = #187
        Joined = False
        OnChange = PageChange
      end
      object stepsIcons: TDaisySteps
        Left = 16
        Top = 312
        Width = 440
        Height = 64
        TabOrder = 15
        Items = <
          item
            Caption = 'Register'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              
                '<circle cx="12" cy="8" r="4"/><path d="M4 21c0 -4 4 -6 8 -6s8 2 ' +
                '8 6"/></svg>')
          end
          item
            Caption = 'Choose plan'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              '<circle cx="11" cy="11" r="7"/><path d="M21 21l-5 -5"/></svg>')
          end
          item
            Caption = 'Purchase'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              
                '<rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9' +
                ' 6l9 -6"/></svg>')
          end>
        ActiveStep = 2
      end
      object stepsColors: TDaisySteps
        Left = 16
        Top = 392
        Width = 440
        Height = 64
        TabOrder = 16
        Items = <
          item
            Caption = 'Step 1'
            Content = '$'
          end
          item
            Caption = 'Step 2'
            Content = '?'
          end
          item
            Caption = 'Step 3'
            Content = '*'
          end
          item
            Caption = 'Failed'
            Content = '!'
            Variant = dvError
          end>
        ActiveStep = 3
        ActiveVariant = dvSecondary
      end
      object stepsVertical: TDaisySteps
        Left = 480
        Top = 264
        Width = 220
        Height = 192
        TabOrder = 17
        Items = <
          item
            Caption = 'Register'
          end
          item
            Caption = 'Choose plan'
          end
          item
            Caption = 'Purchase'
          end>
        Orientation = dsoVertical
        ActiveStep = 2
        ActiveVariant = dvAccent
      end
      object stepsResponsive: TDaisySteps
        Left = 730
        Top = 264
        Width = 220
        Height = 192
        TabOrder = 18
        Items = <
          item
            Caption = 'Cart'
          end
          item
            Caption = 'Address'
          end
          item
            Caption = 'Payment'
          end>
        ActiveStep = 2
        ActiveVariant = dvSuccess
        BreakWidth = 300
      end
    end
    object tsSwap: TDaisyTabSheet
      Left = 1
      Top = 41
      Width = 966
      Height = 470
      TabOrder = 7
      Caption = 'Swap'
      object lblSwap: TLabel
        Left = 16
        Top = 8
        Width = 41
        Height = 21
        Caption = 'Swap'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblSwapText: TLabel
        Left = 16
        Top = 48
        Width = 85
        Height = 15
        Caption = 'Text, fade (click)'
      end
      object lblSwapVolume: TLabel
        Left = 216
        Top = 48
        Width = 95
        Height = 15
        Caption = 'Volume, fade icon'
      end
      object lblSwapRotate: TLabel
        Left = 416
        Top = 48
        Width = 100
        Height = 15
        Caption = 'Sun / moon, rotate'
      end
      object lblSwapFlip: TLabel
        Left = 616
        Top = 48
        Width = 86
        Height = 15
        Caption = 'Sun / moon, flip'
      end
      object lblSwapInd: TLabel
        Left = 816
        Top = 48
        Width = 74
        Height = 15
        Caption = 'Indeterminate'
      end
      object lblSwapResult: TLabel
        Left = 16
        Top = 176
        Width = 126
        Height = 15
        Caption = 'Click a swap to toggle it'
      end
      object swText: TDaisySwap
        Left = 16
        Top = 72
        Width = 64
        Height = 32
        Cursor = crHandPoint
        TabOrder = 0
        TabStop = True
        OnText = 'ON'
        OffText = 'OFF'
        OnChange = SwapChange
      end
      object swVolume: TDaisySwap
        Left = 216
        Top = 72
        Width = 48
        Height = 48
        Cursor = crHandPoint
        TabOrder = 1
        TabStop = True
        OnIcon = 
          'M3 9h4l5 -4v14l-5 -4h-4z M15.5 8.5a5 5 0 0 1 0 7 M18.5 5.5a9 9 0' +
          ' 0 1 0 13'
        OffIcon = 'M3 9h4l5 -4v14l-5 -4h-4z M16 9l5 6 M21 9l-5 6'
        OnChange = SwapChange
      end
      object swRotate: TDaisySwap
        Left = 416
        Top = 72
        Width = 32
        Height = 32
        Cursor = crHandPoint
        TabOrder = 2
        TabStop = True
        Effect = seRotate
        OnIcon = 
          'M12 8a4 4 0 1 0 0 8a4 4 0 1 0 0 -8z M12 2v2 M12 20v2 M4.93 4.93l' +
          '1.41 1.41 M17.66 17.66l1.41 1.41 M2 12h2 M20 12h2 M6.34 17.66l-1' +
          '.41 1.41 M19.07 4.93l-1.41 1.41'
        OffIcon = 'M12 3a6 6 0 0 0 9 9a9 9 0 1 1 -9 -9z'
        OnChange = SwapChange
      end
      object swFlip: TDaisySwap
        Left = 616
        Top = 72
        Width = 48
        Height = 48
        Cursor = crHandPoint
        TabOrder = 3
        TabStop = True
        Effect = seFlip
        OnIcon = 
          'M12 8a4 4 0 1 0 0 8a4 4 0 1 0 0 -8z M12 2v2 M12 20v2 M4.93 4.93l' +
          '1.41 1.41 M17.66 17.66l1.41 1.41 M2 12h2 M20 12h2 M6.34 17.66l-1' +
          '.41 1.41 M19.07 4.93l-1.41 1.41'
        OffIcon = 'M12 3a6 6 0 0 0 9 9a9 9 0 1 1 -9 -9z'
        OnChange = SwapChange
      end
      object swInd: TDaisySwap
        Left = 816
        Top = 72
        Width = 64
        Height = 32
        Cursor = crHandPoint
        TabOrder = 4
        TabStop = True
        Indeterminate = True
        OnText = 'ON'
        OffText = 'OFF'
        IndeterminateText = '?'
        OnChange = SwapChange
      end
    end
    object tsDock: TDaisyTabSheet
      Left = 1
      Top = 41
      Width = 966
      Height = 470
      TabOrder = 10
      Caption = 'Dock'
      object lblDock: TLabel
        Left = 16
        Top = 8
        Width = 39
        Height = 21
        Caption = 'Dock'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblDockEven: TLabel
        Left = 16
        Top = 40
        Width = 120
        Height = 15
        Caption = 'Bottom, evenly spaced'
      end
      object lblDockNormal: TLabel
        Left = 16
        Top = 144
        Width = 219
        Height = 15
        Caption = 'Bottom, normal spacing (IconSpacing 16)'
      end
      object lblDockSmall: TLabel
        Left = 16
        Top = 248
        Width = 156
        Height = 15
        Caption = 'Small (SM) with labels hidden'
      end
      object lblDockLarge: TLabel
        Left = 16
        Top = 340
        Width = 119
        Height = 15
        Caption = 'Large (LG), right to left'
      end
      object lblDockLeft: TLabel
        Left = 520
        Top = 40
        Width = 56
        Height = 15
        Caption = 'Left (even)'
      end
      object lblDockLeftNormal: TLabel
        Left = 620
        Top = 40
        Width = 85
        Height = 15
        Caption = 'Left, bottom-up'
      end
      object lblDockRight: TLabel
        Left = 720
        Top = 40
        Width = 64
        Height = 15
        Caption = 'Right (even)'
      end
      object lblDockRightNormal: TLabel
        Left = 820
        Top = 40
        Width = 68
        Height = 15
        Caption = 'Right (gap 6)'
      end
      object lblDockResult: TLabel
        Left = 16
        Top = 444
        Width = 91
        Height = 15
        Caption = 'Click a dock item'
      end
      object dockBottomEven: TDaisyDock
        Left = 16
        Top = 64
        Width = 440
        Height = 64
        TabOrder = 0
        TabStop = True
        Items = <
          item
            Caption = 'Home'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              '<path d="M3 12l9 -9l9 9"/><path d="M5 10v10h14v-10"/></svg>')
          end
          item
            Caption = 'Search'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              '<circle cx="11" cy="11" r="7"/><path d="M21 21l-5 -5"/></svg>')
          end
          item
            Caption = 'Inbox'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              
                '<rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9' +
                ' 6l9 -6"/></svg>')
          end
          item
            Caption = 'Settings'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              
                '<path d="M4 8h4m4 0h8"/><circle cx="10" cy="8" r="2"/><path d="M' +
                '4 16h10m4 0h2"/><circle cx="16" cy="16" r="2"/></svg>')
          end>
        OnChange = DockChange
      end
      object dockBottomNormal: TDaisyDock
        Left = 16
        Top = 168
        Width = 440
        Height = 64
        TabOrder = 1
        TabStop = True
        Items = <
          item
            Caption = 'Home'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              '<path d="M3 12l9 -9l9 9"/><path d="M5 10v10h14v-10"/></svg>')
          end
          item
            Caption = 'Search'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              '<circle cx="11" cy="11" r="7"/><path d="M21 21l-5 -5"/></svg>')
          end
          item
            Caption = 'Inbox'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              
                '<rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9' +
                ' 6l9 -6"/></svg>')
          end>
        Spacing = dspNormal
        IconSpacing = 16
        OnChange = DockChange
      end
      object dockSmall: TDaisyDock
        Left = 16
        Top = 272
        Width = 300
        Height = 52
        SizeKind = dzSM
        TabOrder = 2
        TabStop = True
        Items = <
          item
            Caption = 'Home'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              '<path d="M3 12l9 -9l9 9"/><path d="M5 10v10h14v-10"/></svg>')
          end
          item
            Caption = 'Search'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              '<circle cx="11" cy="11" r="7"/><path d="M21 21l-5 -5"/></svg>')
          end
          item
            Caption = 'Profile'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              
                '<circle cx="12" cy="8" r="4"/><path d="M4 21c0 -4 4 -6 8 -6s8 2 ' +
                '8 6"/></svg>')
          end>
        ShowLabels = False
        OnChange = DockChange
      end
      object dockLarge: TDaisyDock
        Left = 16
        Top = 364
        Width = 440
        Height = 72
        SizeKind = dzLG
        TabOrder = 3
        TabStop = True
        Items = <
          item
            Caption = 'Home'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              '<path d="M3 12l9 -9l9 9"/><path d="M5 10v10h14v-10"/></svg>')
          end
          item
            Caption = 'Inbox'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              
                '<rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9' +
                ' 6l9 -6"/></svg>')
          end
          item
            Caption = 'Settings'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              
                '<path d="M4 8h4m4 0h8"/><circle cx="10" cy="8" r="2"/><path d="M' +
                '4 16h10m4 0h2"/><circle cx="16" cy="16" r="2"/></svg>')
          end>
        DirectionFlow = difRightToLeft
        OnChange = DockChange
      end
      object dockLeft: TDaisyDock
        Left = 520
        Top = 64
        Width = 64
        Height = 300
        TabOrder = 4
        TabStop = True
        Items = <
          item
            Caption = 'Home'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              '<path d="M3 12l9 -9l9 9"/><path d="M5 10v10h14v-10"/></svg>')
          end
          item
            Caption = 'Search'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              '<circle cx="11" cy="11" r="7"/><path d="M21 21l-5 -5"/></svg>')
          end
          item
            Caption = 'Profile'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              
                '<circle cx="12" cy="8" r="4"/><path d="M4 21c0 -4 4 -6 8 -6s8 2 ' +
                '8 6"/></svg>')
          end>
        Placement = ddpLeft
        DirectionFlow = difTopToBottom
        OnChange = DockChange
      end
      object dockLeftNormal: TDaisyDock
        Left = 620
        Top = 64
        Width = 64
        Height = 300
        TabOrder = 5
        TabStop = True
        Items = <
          item
            Caption = 'Home'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              '<path d="M3 12l9 -9l9 9"/><path d="M5 10v10h14v-10"/></svg>')
          end
          item
            Caption = 'Search'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              '<circle cx="11" cy="11" r="7"/><path d="M21 21l-5 -5"/></svg>')
          end
          item
            Caption = 'Profile'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              
                '<circle cx="12" cy="8" r="4"/><path d="M4 21c0 -4 4 -6 8 -6s8 2 ' +
                '8 6"/></svg>')
          end>
        Placement = ddpLeft
        Spacing = dspNormal
        DirectionFlow = difBottomToTop
        OnChange = DockChange
      end
      object dockRight: TDaisyDock
        Left = 720
        Top = 64
        Width = 64
        Height = 300
        TabOrder = 6
        TabStop = True
        Items = <
          item
            Caption = 'Home'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              '<path d="M3 12l9 -9l9 9"/><path d="M5 10v10h14v-10"/></svg>')
          end
          item
            Caption = 'Search'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              '<circle cx="11" cy="11" r="7"/><path d="M21 21l-5 -5"/></svg>')
          end
          item
            Caption = 'Profile'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              
                '<circle cx="12" cy="8" r="4"/><path d="M4 21c0 -4 4 -6 8 -6s8 2 ' +
                '8 6"/></svg>')
          end>
        Placement = ddpRight
        DirectionFlow = difTopToBottom
        OnChange = DockChange
      end
      object dockRightNormal: TDaisyDock
        Left = 820
        Top = 64
        Width = 64
        Height = 300
        TabOrder = 7
        TabStop = True
        Items = <
          item
            Caption = 'Home'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              '<path d="M3 12l9 -9l9 9"/><path d="M5 10v10h14v-10"/></svg>')
          end
          item
            Caption = 'Search'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              '<circle cx="11" cy="11" r="7"/><path d="M21 21l-5 -5"/></svg>')
          end
          item
            Caption = 'Profile'
            Icon.SVG.Strings = (
              
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strok' +
                'e-width="2" stroke-linecap="round" stroke-linejoin="round">'
              
                '<circle cx="12" cy="8" r="4"/><path d="M4 21c0 -4 4 -6 8 -6s8 2 ' +
                '8 6"/></svg>')
          end>
        Placement = ddpRight
        Spacing = dspNormal
        IconSpacing = 6
        DirectionFlow = difTopToBottom
        OnChange = DockChange
      end
    end
    object tsStack: TDaisyTabSheet
      Left = 1
      Top = 41
      Width = 966
      Height = 470
      TabOrder = 8
      Caption = 'Stack'
      object lblStack: TLabel
        Left = 16
        Top = 8
        Width = 41
        Height = 21
        Caption = 'Stack'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblStackHint: TLabel
        Left = 90
        Top = 12
        Width = 225
        Height = 15
        Caption = 'Click a stack to bring the next card forward'
      end
      object lblStackBottom: TLabel
        Left = 16
        Top = 44
        Width = 40
        Height = 15
        Caption = 'Bottom'
      end
      object lblStackTop: TLabel
        Left = 256
        Top = 44
        Width = 20
        Height = 15
        Caption = 'Top'
      end
      object lblStackStart: TLabel
        Left = 496
        Top = 44
        Width = 24
        Height = 15
        Caption = 'Start'
      end
      object lblStackEnd: TLabel
        Left = 736
        Top = 44
        Width = 20
        Height = 15
        Caption = 'End'
      end
      object stkBottom: TDaisyStack
        Left = 16
        Top = 72
        Width = 200
        Height = 150
        TabOrder = 0
        object stkBottomC: TDaisyCard
          Left = 20
          Top = 43
          Width = 160
          Height = 107
          Variant = dvAccent
          TabOrder = 0
          Title = 'Three'
        end
        object stkBottomB: TDaisyCard
          Left = 10
          Top = 21
          Width = 180
          Height = 121
          Variant = dvSecondary
          TabOrder = 1
          Title = 'Two'
        end
        object stkBottomA: TDaisyCard
          Left = 0
          Top = 0
          Width = 200
          Height = 134
          Variant = dvPrimary
          TabOrder = 2
          Title = 'One'
          Body = 'The front card'
        end
      end
      object stkTop: TDaisyStack
        Left = 256
        Top = 72
        Width = 200
        Height = 150
        TabOrder = 1
        Direction = sdTop
        object stkTopC: TDaisyCard
          Left = 20
          Top = 0
          Width = 160
          Height = 107
          Variant = dvAccent
          TabOrder = 0
          Title = 'Three'
        end
        object stkTopB: TDaisyCard
          Left = 10
          Top = 8
          Width = 180
          Height = 121
          Variant = dvSecondary
          TabOrder = 1
          Title = 'Two'
        end
        object stkTopA: TDaisyCard
          Left = 0
          Top = 16
          Width = 200
          Height = 134
          Variant = dvPrimary
          TabOrder = 2
          Title = 'One'
          Body = 'The front card'
        end
      end
      object stkStart: TDaisyStack
        Left = 496
        Top = 72
        Width = 200
        Height = 150
        TabOrder = 2
        Direction = sdStart
        object stkStartC: TDaisyCard
          Left = 0
          Top = 15
          Width = 147
          Height = 120
          Variant = dvAccent
          TabOrder = 0
          Title = 'Three'
        end
        object stkStartB: TDaisyCard
          Left = 8
          Top = 8
          Width = 166
          Height = 135
          Variant = dvSecondary
          TabOrder = 1
          Title = 'Two'
        end
        object stkStartA: TDaisyCard
          Left = 16
          Top = 0
          Width = 184
          Height = 150
          Variant = dvPrimary
          TabOrder = 2
          Title = 'One'
          Body = 'The front card'
        end
      end
      object stkEnd: TDaisyStack
        Left = 736
        Top = 72
        Width = 200
        Height = 150
        TabOrder = 3
        Direction = sdEnd
        object stkEndC: TDaisyCard
          Left = 53
          Top = 15
          Width = 147
          Height = 120
          Variant = dvAccent
          TabOrder = 0
          Title = 'Three'
        end
        object stkEndB: TDaisyCard
          Left = 26
          Top = 8
          Width = 166
          Height = 135
          Variant = dvSecondary
          TabOrder = 1
          Title = 'Two'
        end
        object stkEndA: TDaisyCard
          Left = 0
          Top = 0
          Width = 184
          Height = 150
          Variant = dvPrimary
          TabOrder = 2
          Title = 'One'
          Body = 'The front card'
        end
      end
      object stkPlainBottom: TDaisyStack
        Left = 16
        Top = 244
        Width = 200
        Height = 140
        TabOrder = 4
        object stkPlainBottomC: TDaisyCard
          Left = 20
          Top = 41
          Width = 160
          Height = 99
          TabOrder = 0
          Title = 'Three'
        end
        object stkPlainBottomB: TDaisyCard
          Left = 10
          Top = 20
          Width = 180
          Height = 112
          TabOrder = 1
          Title = 'Two'
        end
        object stkPlainBottomA: TDaisyCard
          Left = 0
          Top = 0
          Width = 200
          Height = 124
          TabOrder = 2
          Title = 'One'
          Body = 'Click to see the next'
        end
      end
      object stkNeutralTop: TDaisyStack
        Left = 256
        Top = 244
        Width = 200
        Height = 140
        TabOrder = 5
        Direction = sdTop
        object stkNeutralTopC: TDaisyCard
          Left = 20
          Top = 0
          Width = 160
          Height = 99
          Variant = dvNeutral
          TabOrder = 0
          Title = 'Three'
        end
        object stkNeutralTopB: TDaisyCard
          Left = 10
          Top = 8
          Width = 180
          Height = 112
          Variant = dvNeutral
          TabOrder = 1
          Title = 'Two'
        end
        object stkNeutralTopA: TDaisyCard
          Left = 0
          Top = 16
          Width = 200
          Height = 124
          Variant = dvNeutral
          TabOrder = 2
          Title = 'One'
          Body = 'Click to see the next'
        end
      end
      object stkPlainStart: TDaisyStack
        Left = 496
        Top = 244
        Width = 200
        Height = 140
        TabOrder = 6
        Direction = sdStart
        object stkPlainStartC: TDaisyCard
          Left = 0
          Top = 14
          Width = 147
          Height = 112
          TabOrder = 0
          Title = 'Three'
        end
        object stkPlainStartB: TDaisyCard
          Left = 8
          Top = 7
          Width = 166
          Height = 126
          TabOrder = 1
          Title = 'Two'
        end
        object stkPlainStartA: TDaisyCard
          Left = 16
          Top = 0
          Width = 184
          Height = 140
          TabOrder = 2
          Title = 'One'
          Body = 'Click to see the next'
        end
      end
      object stkNeutralEnd: TDaisyStack
        Left = 736
        Top = 244
        Width = 200
        Height = 140
        TabOrder = 7
        Direction = sdEnd
        object stkNeutralEndC: TDaisyCard
          Left = 53
          Top = 14
          Width = 147
          Height = 112
          Variant = dvNeutral
          TabOrder = 0
          Title = 'Three'
        end
        object stkNeutralEndB: TDaisyCard
          Left = 26
          Top = 7
          Width = 166
          Height = 126
          Variant = dvNeutral
          TabOrder = 1
          Title = 'Two'
        end
        object stkNeutralEndA: TDaisyCard
          Left = 0
          Top = 0
          Width = 184
          Height = 140
          Variant = dvNeutral
          TabOrder = 2
          Title = 'One'
          Body = 'Click to see the next'
        end
      end
    end
    object tsSizes: TDaisyTabSheet
      Left = 1
      Top = 41
      Width = 966
      Height = 470
      TabOrder = 2
      Caption = 'Sizes'
      object lblSizes: TLabel
        Left = 16
        Top = 8
        Width = 92
        Height = 21
        Caption = 'Button sizes'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object btnXS: TDaisyButton
        Left = 16
        Top = 40
        Width = 96
        Height = 24
        Cursor = crHandPoint
        Variant = dvSecondary
        SizeKind = dzXS
        TabOrder = 0
        TabStop = True
        Caption = 'XS'
      end
      object btnSM: TDaisyButton
        Left = 120
        Top = 40
        Width = 96
        Height = 32
        Cursor = crHandPoint
        Variant = dvSecondary
        SizeKind = dzSM
        TabOrder = 1
        TabStop = True
        Caption = 'SM'
      end
      object btnMD: TDaisyButton
        Left = 224
        Top = 40
        Width = 96
        Height = 40
        Cursor = crHandPoint
        Variant = dvSecondary
        TabOrder = 2
        TabStop = True
        Caption = 'MD'
      end
      object btnLG: TDaisyButton
        Left = 328
        Top = 40
        Width = 96
        Height = 48
        Cursor = crHandPoint
        Variant = dvSecondary
        SizeKind = dzLG
        TabOrder = 3
        TabStop = True
        Caption = 'LG'
      end
      object btnXL: TDaisyButton
        Left = 432
        Top = 40
        Width = 96
        Height = 56
        Cursor = crHandPoint
        Variant = dvSecondary
        SizeKind = dzXL
        TabOrder = 4
        TabStop = True
        Caption = 'XL'
      end
    end
    object tsStyles: TDaisyTabSheet
      Left = 1
      Top = 41
      Width = 966
      Height = 470
      TabOrder = 1
      Caption = 'Styles'
      object lblStyles: TLabel
        Left = 16
        Top = 8
        Width = 99
        Height = 21
        Caption = 'Button styles'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object btnOutline: TDaisyButton
        Left = 16
        Top = 40
        Width = 96
        Height = 40
        Cursor = crHandPoint
        Variant = dvPrimary
        Style = dsOutline
        TabOrder = 0
        TabStop = True
        Caption = 'Outline'
      end
      object btnDash: TDaisyButton
        Left = 120
        Top = 40
        Width = 96
        Height = 40
        Cursor = crHandPoint
        Variant = dvPrimary
        Style = dsDash
        TabOrder = 1
        TabStop = True
        Caption = 'Dash'
      end
      object btnSoft: TDaisyButton
        Left = 224
        Top = 40
        Width = 96
        Height = 40
        Cursor = crHandPoint
        Variant = dvPrimary
        Style = dsSoft
        TabOrder = 2
        TabStop = True
        Caption = 'Soft'
      end
      object btnGhost: TDaisyButton
        Left = 328
        Top = 40
        Width = 96
        Height = 40
        Cursor = crHandPoint
        Variant = dvPrimary
        Style = dsGhost
        TabOrder = 3
        TabStop = True
        Caption = 'Ghost'
      end
      object btnDisabled: TDaisyButton
        Left = 432
        Top = 40
        Width = 96
        Height = 40
        Cursor = crHandPoint
        Variant = dvPrimary
        Enabled = False
        TabOrder = 4
        TabStop = True
        Caption = 'Disabled'
      end
    end
    object tsFieldSet: TDaisyTabSheet
      Left = 1
      Top = 41
      Width = 966
      Height = 470
      TabOrder = 6
      Caption = 'FieldSet'
      object lblFieldSet: TLabel
        Left = 16
        Top = 8
        Width = 61
        Height = 21
        Caption = 'FieldSet'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object fsBasic: TDaisyFieldSet
        Left = 16
        Top = 40
        Width = 300
        Height = 150
        TabOrder = 0
        Legend = 'Page title'
        Description = 'You can edit the page title later on from settings'
        object edtFsTitle: TDaisyTextInput
          Left = 16
          Top = 44
          Width = 268
          Height = 40
          Cursor = crIBeam
          TabOrder = 0
          TabStop = True
          Text = ''
          Placeholder = 'My awesome page'
        end
      end
      object fsLogin: TDaisyFieldSet
        Left = 336
        Top = 40
        Width = 300
        Height = 220
        TabOrder = 1
        Legend = 'Login'
        object edtFsEmail: TDaisyTextInput
          Left = 16
          Top = 44
          Width = 268
          Height = 40
          Cursor = crIBeam
          TabOrder = 0
          TabStop = True
          Text = ''
          Placeholder = 'Email'
        end
        object edtFsPassword: TDaisyTextInput
          Left = 16
          Top = 92
          Width = 268
          Height = 40
          Cursor = crIBeam
          TabOrder = 1
          TabStop = True
          Text = ''
          Placeholder = 'Password'
          PasswordChar = '*'
        end
        object btnFsLogin: TDaisyButton
          Left = 16
          Top = 148
          Width = 268
          Height = 40
          Cursor = crHandPoint
          Variant = dvNeutral
          TabOrder = 2
          TabStop = True
          Caption = 'Login'
        end
      end
      object fsSoft: TDaisyFieldSet
        Left = 656
        Top = 40
        Width = 300
        Height = 150
        Variant = dvPrimary
        Style = dsSoft
        TabOrder = 2
        Legend = 'Preferences'
        object chkFsNews: TDaisyCheckBox
          Left = 16
          Top = 48
          Width = 184
          Height = 30
          Cursor = crHandPoint
          TabOrder = 0
          TabStop = True
          Caption = 'Send me the newsletter'
        end
        object chkFsTips: TDaisyCheckBox
          Left = 16
          Top = 88
          Width = 173
          Height = 30
          Cursor = crHandPoint
          TabOrder = 1
          TabStop = True
          Caption = 'Show tips on start-up'
        end
      end
      object fsOutline: TDaisyFieldSet
        Left = 16
        Top = 210
        Width = 300
        Height = 110
        Variant = dvAccent
        Style = dsOutline
        TabOrder = 3
        Legend = 'Outline'
        Description = 'Border only, no background'
      end
    end
    object tsCards: TDaisyTabSheet
      Left = 1
      Top = 41
      Width = 966
      Height = 470
      TabOrder = 3
      Caption = 'Cards'
      object lblCards: TLabel
        Left = 16
        Top = 8
        Width = 42
        Height = 21
        Caption = 'Cards'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object cardDefault: TDaisyCard
        Left = 16
        Top = 40
        Width = 300
        Height = 210
        TabOrder = 0
        Title = 'Life hack'
        Body = 
          'How to park your car at your garage, and then actually get out o' +
          'f it.'
        DesignSize = (
          300
          210)
        object btnBuyDefault: TDaisyButton
          Left = 172
          Top = 142
          Width = 96
          Height = 40
          Cursor = crHandPoint
          Variant = dvPrimary
          Anchors = [akRight, akBottom]
          TabOrder = 0
          TabStop = True
          Action = actBuyNow
          Caption = 'Button'
        end
      end
      object cardPrimary: TDaisyCard
        Left = 336
        Top = 40
        Width = 300
        Height = 210
        Variant = dvPrimary
        BiDiMode = bdLeftToRight
        ParentBiDiMode = False
        TabOrder = 1
        Title = 'Primary card'
        Body = 'Cards can use any variant, just like buttons.'
        DesignSize = (
          300
          210)
        object btnBuyPrimary: TDaisyButton
          Left = 172
          Top = 142
          Width = 96
          Height = 40
          Cursor = crHandPoint
          Variant = dvNeutral
          Anchors = [akRight, akBottom]
          TabOrder = 0
          TabStop = True
          Action = actBuyNow
          Caption = 'Button'
        end
      end
      object cardBordered: TDaisyCard
        Left = 656
        Top = 40
        Width = 300
        Height = 210
        Style = dsOutline
        ShadowSize = 0
        TabOrder = 2
        Title = 'Bordered'
        Body = 'A flat card with a border and no shadow.'
        DesignSize = (
          300
          210)
        object btnBuyBordered: TDaisyButton
          Left = 172
          Top = 142
          Width = 96
          Height = 40
          Cursor = crHandPoint
          Variant = dvNeutral
          Anchors = [akRight, akBottom]
          TabOrder = 0
          TabStop = True
          Action = actBuyNow
          Caption = 'Button'
        end
      end
    end
    object tsVariants: TDaisyTabSheet
      Left = 1
      Top = 41
      Width = 966
      Height = 470
      ContentPadding = 0
      CornerRadius = 0
      TabOrder = 0
      Caption = 'Variants'
      object lblVariants: TLabel
        Left = 16
        Top = 8
        Width = 117
        Height = 21
        Caption = 'Button variants'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object btnDefault: TDaisyButton
        Left = 16
        Top = 40
        Width = 96
        Height = 40
        Cursor = crHandPoint
        TabOrder = 0
        TabStop = True
        Caption = 'Default'
      end
      object btnNeutral: TDaisyButton
        Left = 120
        Top = 40
        Width = 96
        Height = 40
        Cursor = crHandPoint
        Variant = dvNeutral
        TabOrder = 1
        TabStop = True
        Caption = 'Neutral'
      end
      object btnPrimary: TDaisyButton
        Left = 224
        Top = 40
        Width = 96
        Height = 40
        Cursor = crHandPoint
        Variant = dvPrimary
        TabOrder = 2
        TabStop = True
        Caption = 'Primary'
      end
      object btnSecondary: TDaisyButton
        Left = 328
        Top = 40
        Width = 96
        Height = 40
        Cursor = crHandPoint
        Variant = dvSecondary
        TabOrder = 3
        TabStop = True
        Caption = 'Secondary'
      end
      object btnAccent: TDaisyButton
        Left = 432
        Top = 40
        Width = 96
        Height = 40
        Cursor = crHandPoint
        Variant = dvAccent
        TabOrder = 4
        TabStop = True
        Caption = 'Accent'
      end
      object btnInfo: TDaisyButton
        Left = 536
        Top = 40
        Width = 96
        Height = 40
        Cursor = crHandPoint
        Variant = dvInfo
        TabOrder = 5
        TabStop = True
        Caption = 'Info'
      end
      object btnSuccess: TDaisyButton
        Left = 640
        Top = 40
        Width = 96
        Height = 40
        Cursor = crHandPoint
        Variant = dvSuccess
        TabOrder = 6
        TabStop = True
        Caption = 'Success'
      end
      object btnWarning: TDaisyButton
        Left = 744
        Top = 40
        Width = 96
        Height = 40
        Cursor = crHandPoint
        Variant = dvWarning
        TabOrder = 7
        TabStop = True
        Caption = 'Warning'
      end
      object btnError: TDaisyButton
        Left = 848
        Top = 40
        Width = 96
        Height = 40
        Cursor = crHandPoint
        Variant = dvError
        TabOrder = 8
        TabStop = True
        Caption = 'Error'
      end
    end
  end
  object tbpMain: TDaisyTitleBarPanel
    Left = 0
    Top = 0
    Width = 1000
    Height = 30
    CustomButtons = <>
    object badgeTitle: TDaisyBadge
      Left = 232
      Top = 5
      Width = 76
      Height = 24
      Variant = dvPrimary
      TabOrder = 2
      Caption = 'Basic-01'
    end
    object edtTitleSearch: TDaisyTextInput
      Left = 320
      Top = 3
      Width = 220
      Height = 24
      Cursor = crIBeam
      SizeKind = dzXS
      TabOrder = 0
      TabStop = True
      Text = ''
      Placeholder = 'Search'
    end
    object togTitle: TDaisyToggle
      Left = 560
      Top = 3
      Width = 60
      Height = 22
      Cursor = crHandPoint
      SizeKind = dzXS
      TabOrder = 1
      TabStop = True
      Caption = 'Pin'
    end
  end
  object alMain: TActionList
    Left = 776
    Top = 22
    object actBuyNow: TAction
      Caption = 'Buy Now'
      OnExecute = CardActionClick
    end
  end
  object Styler: TDaisyFormStyler
    Left = 320
    Top = 16
  end
end
