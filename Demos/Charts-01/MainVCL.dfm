object FormCharts: TFormCharts
  Left = 0
  Top = 0
  Caption = 'DaisyUI VCL demo - charts'
  ClientHeight = 600
  ClientWidth = 1284
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnShow = FormShow
  TextHeight = 15
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 1284
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    object lblTheme: TLabel
      Left = 24
      Top = 22
      Width = 40
      Height = 15
      Caption = 'Theme:'
    end
    object chkRTL: TDaisyCheckBox
      Left = 470
      Top = 16
      Width = 116
      Height = 30
      Cursor = crHandPoint
      TabOrder = 2
      TabStop = True
      Caption = 'Right-to-left'
      OnChange = RTLChange
    end
    object chkTitleBar: TDaisyCheckBox
      Left = 300
      Top = 16
      Width = 156
      Height = 30
      Cursor = crHandPoint
      TabOrder = 1
      TabStop = True
      Checked = True
      Caption = 'Theme the title bar'
      OnChange = chkTitleBarClick
    end
    object selTheme: TDaisySelect
      Left = 80
      Top = 10
      Width = 200
      Height = 40
      Hint = ''
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
      ItemIndex = 4
      Placeholder = 'Pick one'
      OnChange = ThemeSelectChange
    end
    object themeCtl: TDaisyThemeController
      Left = 1000
      Top = 4
      Width = 94
      Height = 58
      Cursor = crHandPoint
      TabOrder = 3
      TabStop = True
      Kind = tkRadio
      Caption = ''
      OnChange = ThemeControllerChange
    end
  end
  object pcMain: TDaisyPageControl
    Left = 0
    Top = 60
    Width = 1284
    Height = 540
    Align = alClient
    TabOrder = 1
    TabStop = True
    ActivePageIndex = 0
    object tsLine: TDaisyTabSheet
      Left = 1
      Top = 41
      Width = 1282
      Height = 498
      TabOrder = 0
      Caption = 'Line'
      object lblLine: TDaisyLabel
        Left = 24
        Top = 8
        Width = 300
        Height = 19
        TabOrder = 0
        Caption = 'Line - two series'
      end
      object lblArea: TDaisyLabel
        Left = 652
        Top = 8
        Width = 300
        Height = 19
        TabOrder = 1
        Caption = 'Line - area, no y axis'
      end
      object chLine: TDaisyChart
        Left = 24
        Top = 36
        Width = 600
        Height = 400
        TabOrder = 2
        ChartType = dctLine
        Series = <
          item
            Name = 'Clicks'
            Data = '6500, 6418, 6456, 6526, 6356, 6456'
            Color = '#1A56DB'
          end
          item
            Name = 'CPC'
            Data = '6456, 6356, 6526, 6332, 6418, 6500'
            Color = '#7E3AF2'
          end>
        Labels.Strings = (
          '01 Feb'
          '02 Feb'
          '03 Feb'
          '04 Feb'
          '05 Feb'
          '06 Feb')
        LegendPosition = dlpBottom
      end
      object chArea: TDaisyChart
        Left = 652
        Top = 36
        Width = 600
        Height = 400
        TabOrder = 3
        ChartType = dctArea
        Series = <
          item
            Name = 'New users'
            Data = '6500, 6418, 6456, 6526, 6356, 6456'
            Color = '#1A56DB'
          end>
        Labels.Strings = (
          '01 Feb'
          '02 Feb'
          '03 Feb'
          '04 Feb'
          '05 Feb'
          '06 Feb')
        LegendPosition = dlpNone
        ShowYAxis = False
      end
    end
    object tsColumn: TDaisyTabSheet
      Left = 1
      Top = 41
      Width = 1282
      Height = 498
      TabOrder = 1
      Caption = 'Column'
      object lblColumn: TDaisyLabel
        Left = 24
        Top = 8
        Width = 300
        Height = 19
        TabOrder = 0
        Caption = 'Column - two series'
      end
      object lblColumnStacked: TDaisyLabel
        Left = 652
        Top = 8
        Width = 300
        Height = 19
        TabOrder = 1
        Caption = 'Column - stacked'
      end
      object chColumn: TDaisyChart
        Left = 24
        Top = 36
        Width = 600
        Height = 400
        TabOrder = 2
        ChartType = dctColumn
        Series = <
          item
            Name = 'Organic'
            Data = '231, 122, 63, 421, 122, 323, 111'
            Color = '#1A56DB'
          end
          item
            Name = 'Social media'
            Data = '232, 113, 341, 224, 522, 411, 243'
            Color = '#FDBA8C'
          end>
        Labels.Strings = (
          'Mon'
          'Tue'
          'Wed'
          'Thu'
          'Fri'
          'Sat'
          'Sun')
      end
      object chColumnStacked: TDaisyChart
        Left = 652
        Top = 36
        Width = 600
        Height = 400
        TabOrder = 3
        ChartType = dctColumn
        Series = <
          item
            Name = 'Organic'
            Data = '231, 122, 63, 421, 122, 323, 111'
            Color = '#1A56DB'
          end
          item
            Name = 'Social media'
            Data = '232, 113, 341, 224, 522, 411, 243'
            Color = '#FDBA8C'
          end>
        Labels.Strings = (
          'Mon'
          'Tue'
          'Wed'
          'Thu'
          'Fri'
          'Sat'
          'Sun')
        Stacked = True
      end
    end
    object tsBar: TDaisyTabSheet
      Left = 1
      Top = 41
      Width = 1282
      Height = 498
      TabOrder = 2
      Caption = 'Bar'
      object lblBar: TDaisyLabel
        Left = 24
        Top = 8
        Width = 300
        Height = 19
        TabOrder = 0
        Caption = 'Bar - income and expense'
      end
      object lblBarLabels: TDaisyLabel
        Left = 652
        Top = 8
        Width = 300
        Height = 19
        TabOrder = 1
        Caption = 'Bar - data labels'
      end
      object chBar: TDaisyChart
        Left = 24
        Top = 36
        Width = 600
        Height = 400
        TabOrder = 2
        ChartType = dctBar
        Series = <
          item
            Name = 'Income'
            Data = '1420, 1620, 1820, 1420, 1650, 2120'
            Color = '#007A55'
          end
          item
            Name = 'Expense'
            Data = '788, 810, 866, 788, 1100, 1200'
            Color = '#C70036'
          end>
        Labels.Strings = (
          'Jul'
          'Aug'
          'Sep'
          'Oct'
          'Nov'
          'Dec')
        BarRadius = 6
        ValuePrefix = '$'
      end
      object chBarLabels: TDaisyChart
        Left = 652
        Top = 36
        Width = 600
        Height = 400
        TabOrder = 3
        ChartType = dctBar
        Series = <
          item
            Name = 'Visits'
            Data = '420, 380, 290, 210, 160'
            Color = '#1A56DB'
          end>
        Labels.Strings = (
          'Direct'
          'Google'
          'Facebook'
          'LinkedIn'
          'Twitter')
        DataLabels = True
        LegendPosition = dlpNone
        ShowGrid = False
        ShowXAxis = False
      end
    end
    object tsPie: TDaisyTabSheet
      Left = 1
      Top = 41
      Width = 1282
      Height = 498
      TabOrder = 3
      Caption = 'Pie'
      object lblPie: TDaisyLabel
        Left = 24
        Top = 8
        Width = 300
        Height = 19
        TabOrder = 0
        Caption = 'Pie - data labels'
      end
      object lblPieRight: TDaisyLabel
        Left = 652
        Top = 8
        Width = 300
        Height = 19
        TabOrder = 1
        Caption = 'Pie - legend on the right'
      end
      object chPie: TDaisyChart
        Left = 24
        Top = 36
        Width = 600
        Height = 400
        TabOrder = 2
        ChartType = dctPie
        Series = <
          item
            Name = 'Traffic'
            Data = '52.8, 26.8, 20.4'
          end>
        Labels.Strings = (
          'Direct'
          'Sponsor'
          'Affiliate')
        Colors.Strings = (
          '#1C64F2'
          '#16BDCA'
          '#9061F9')
        DataLabels = True
        ValueSuffix = '%'
      end
      object chPieRight: TDaisyChart
        Left = 652
        Top = 36
        Width = 600
        Height = 400
        TabOrder = 3
        ChartType = dctPie
        Series = <
          item
            Name = 'Browsers'
            Data = '63, 20, 10, 7'
          end>
        Labels.Strings = (
          'Chrome'
          'Safari'
          'Firefox'
          'Edge')
        LegendPosition = dlpRight
        ValueSuffix = '%'
      end
    end
    object tsDonut: TDaisyTabSheet
      Left = 1
      Top = 41
      Width = 1282
      Height = 498
      TabOrder = 4
      Caption = 'Donut'
      object lblDonut: TDaisyLabel
        Left = 24
        Top = 8
        Width = 300
        Height = 19
        TabOrder = 0
        Caption = 'Donut - total in the centre'
      end
      object lblDonutThin: TDaisyLabel
        Left = 652
        Top = 8
        Width = 300
        Height = 19
        TabOrder = 1
        Caption = 'Donut - thin ring, legend on the right'
      end
      object chDonut: TDaisyChart
        Left = 24
        Top = 36
        Width = 600
        Height = 400
        TabOrder = 2
        ChartType = dctDonut
        Series = <
          item
            Name = 'Visitors'
            Data = '3500, 2350, 240, 540'
          end>
        Labels.Strings = (
          'Direct'
          'Sponsor'
          'Affiliate'
          'Email marketing')
        Colors.Strings = (
          '#1C64F2'
          '#16BDCA'
          '#FDBA8C'
          '#E74694')
        TotalLabel = 'Unique visitors'
      end
      object chDonutThin: TDaisyChart
        Left = 652
        Top = 36
        Width = 600
        Height = 400
        TabOrder = 3
        ChartType = dctDonut
        Series = <
          item
            Name = 'Devices'
            Data = '58, 31, 11'
          end>
        Labels.Strings = (
          'Desktop'
          'Mobile'
          'Tablet')
        DataLabels = True
        HoleSize = 80
        LegendPosition = dlpRight
        ShowTotal = False
        ValueSuffix = '%'
      end
    end
    object tsRadial: TDaisyTabSheet
      Left = 1
      Top = 41
      Width = 1282
      Height = 498
      TabOrder = 5
      Caption = 'Radial'
      object lblRadial: TDaisyLabel
        Left = 24
        Top = 8
        Width = 300
        Height = 19
        TabOrder = 0
        Caption = 'Radial - three rings'
      end
      object lblRadialSingle: TDaisyLabel
        Left = 652
        Top = 8
        Width = 300
        Height = 19
        TabOrder = 1
        Caption = 'Radial - one ring'
      end
      object chRadial: TDaisyChart
        Left = 24
        Top = 36
        Width = 600
        Height = 400
        TabOrder = 2
        ChartType = dctRadial
        Series = <
          item
            Name = 'Progress'
            Data = '90, 85, 70'
          end>
        Labels.Strings = (
          'Done tasks'
          'In progress'
          'To do')
        Colors.Strings = (
          '#1C64F2'
          '#16BDCA'
          '#FDBA8C')
        TotalLabel = 'Average'
        ValueSuffix = '%'
      end
      object chRadialSingle: TDaisyChart
        Left = 652
        Top = 36
        Width = 600
        Height = 400
        TabOrder = 3
        ChartType = dctRadial
        Series = <
          item
            Name = 'Progress'
            Data = '75'
          end>
        Labels.Strings = (
          'Progress')
        LegendPosition = dlpNone
        TotalLabel = 'Progress'
        ValueSuffix = '%'
      end
    end
  end
  object Styler: TDaisyFormStyler
    Theme = dtCorporate
    Left = 1200
    Top = 60
  end
end
