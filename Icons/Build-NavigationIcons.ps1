# Builds the palette icons of the navigation components (Breadcrumbs, Dock, Link, Pagination, Steps)
# and the title bar panel.
#   Icons\<Name>.bmp                        (24 x 24, magenta transparent key)
#   Source\VCL\Daisy.VCL.Reg3.dcr           (TDAISY<NAME>)
#   Source\FMX\Daisy.FMX.Reg3.dcr           (TDAISYFMX<NAME>)
# The VCL and FMX component of a pair share the same artwork.
# Needs C:\Program Files (x86)\Embarcadero\Studio\37.0\bin64 for cgrc.exe.
# Optional: -Preview <folder> also writes an enlarged contact sheet (navigation.png).
param([string]$Preview = '')

Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
if (-not $root) { $root = (Get-Location).Path }
$iconDir = Join-Path $root 'Icons'
$bin = 'C:\Program Files (x86)\Embarcadero\Studio\37.0\bin64'

$key   = [System.Drawing.Color]::FromArgb(255, 0, 255)
$white = [System.Drawing.Color]::FromArgb(255, 255, 255)

function Shade($c, $f) {
    [System.Drawing.Color]::FromArgb([int]($c.R * $f), [int]($c.G * $f), [int]($c.B * $f))
}

function Alpha($a) { [System.Drawing.Color]::FromArgb($a, 255, 255, 255) }

# rounded tile on the transparent key, with a slightly darker rim like the other icons
function New-Tile($base) {
    $b = New-Object System.Drawing.Bitmap 24, 24, ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $rim = Shade $base 0.82
    for ($y = 0; $y -lt 24; $y++) { for ($x = 0; $x -lt 24; $x++) { $b.SetPixel($x, $y, $key) } }
    for ($y = 1; $y -le 22; $y++) {
        for ($x = 1; $x -le 22; $x++) {
            if ($x -eq 1 -or $x -eq 22 -or $y -eq 1 -or $y -eq 22) { $b.SetPixel($x, $y, $rim) } else { $b.SetPixel($x, $y, $base) }
        }
    }
    foreach ($p in @(@(1,1), @(22,1), @(1,22), @(22,22))) { $b.SetPixel($p[0], $p[1], $key) }
    foreach ($p in @(@(2,2), @(21,2), @(2,21), @(21,21))) { $b.SetPixel($p[0], $p[1], $rim) }
    return $b
}

function New-Gfx($bmp) {
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $g.PixelOffsetMode = 'HighQuality'
    return $g
}

function Round-Path([single]$x, [single]$y, [single]$w, [single]$h, [single]$r) {
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = [Math]::Min(2 * $r, [Math]::Min($w, $h))
    $p.AddArc($x, $y, $d, $d, 180, 90)
    $p.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $p.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $p.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $p.CloseFigure()
    return $p
}

function Fill-Round($g, $color, $x, $y, $w, $h, $r) {
    $p = Round-Path $x $y $w $h $r
    $br = New-Object System.Drawing.SolidBrush $color
    $g.FillPath($br, $p)
    $br.Dispose(); $p.Dispose()
}

function Pen($color, $w) {
    $pen = New-Object System.Drawing.Pen $color, $w
    $pen.StartCap = 'Round'; $pen.EndCap = 'Round'; $pen.LineJoin = 'Round'
    return $pen
}

function Chevron($g, $color, $cx, $cy, $half, $w, $dir) {
    $pen = Pen $color $w
    $d = [double]"$dir".Trim()
    $x1 = [single]([double]$cx - $d * [double]$half / 2)
    $x2 = [single]([double]$cx + $d * [double]$half / 2)
    $pts = [System.Drawing.PointF[]]@(
        [System.Drawing.PointF]::new($x1, [single]($cy - $half)),
        [System.Drawing.PointF]::new($x2, [single]$cy),
        [System.Drawing.PointF]::new($x1, [single]($cy + $half))
    )
    $g.DrawLines($pen, $pts)
    $pen.Dispose()
}

# TDaisyBreadcrumbs: a trail of links joined by chevrons, the last one is the current page
function Draw-Breadcrumbs {
    $b = New-Tile ([System.Drawing.Color]::FromArgb(101, 163, 13))
    $g = New-Gfx $b
    Fill-Round $g (Alpha 170) 3 8.5 4.4 4.4 1.4
    Fill-Round $g (Alpha 170) 10.3 8.5 4.4 4.4 1.4
    Fill-Round $g $white 17.6 8.5 3.4 4.4 1.4
    Chevron $g $white 8.6 10.7 1.9 1.6 1
    Chevron $g $white 15.9 10.7 1.9 1.6 1
    Fill-Round $g (Alpha 110) 3 15.4 4.4 1.8 0.9
    Fill-Round $g (Alpha 110) 10.3 15.4 4.4 1.8 0.9
    Fill-Round $g (Alpha 160) 17.6 15.4 3.4 1.8 0.9
    $g.Dispose()
    return $b
}
# TDaisyDock: a bar of icons with the active one marked, along the bottom of a window
function Draw-Dock {
    $b = New-Tile ([System.Drawing.Color]::FromArgb(14, 165, 233))
    $g = New-Gfx $b
    Fill-Round $g (Alpha 70) 4 4.5 16 8 2
    Fill-Round $g $white 3.5 14 17 6 2.6
    $base = [System.Drawing.Color]::FromArgb(14, 165, 233)
    $dim = [System.Drawing.Color]::FromArgb(150, 205, 235)
    Fill-Round $g $dim 6 15.6 3 3 0.9
    Fill-Round $g $base 10.5 15.2 3 3 0.9
    Fill-Round $g $dim 15 15.6 3 3 0.9
    Fill-Round $g $base 10.3 19 3.4 1 0.5
    $g.Dispose()
    return $b
}

# TDaisyLink: two chain links
function Draw-Link {
    $b = New-Tile ([System.Drawing.Color]::FromArgb(192, 38, 211))
    $g = New-Gfx $b
    $pen = Pen $white 2.1
    foreach ($s in @(-1, 1)) {
        $m = New-Object System.Drawing.Drawing2D.Matrix
        $m.RotateAt(-45, [System.Drawing.PointF]::new(12, 12))
        $m.Translate($s * 3.1, 0)
        $path = Round-Path 4.6 9.2 8.4 5.6 2.8
        $path.Transform($m)
        $g.DrawPath($pen, $path)
        $path.Dispose(); $m.Dispose()
    }
    $pen.Dispose()
    $g.Dispose()
    return $b
}

# TDaisyPagination: previous / current / next page buttons
function Draw-Pagination {
    $base = [System.Drawing.Color]::FromArgb(217, 154, 6)
    $b = New-Tile $base
    $g = New-Gfx $b
    Fill-Round $g (Alpha 90) 2.8 5.5 5.6 9 1.8
    Fill-Round $g $white 9.2 5.5 5.6 9 1.8
    Fill-Round $g (Alpha 90) 15.6 5.5 5.6 9 1.8
    Chevron $g $white 5.7 10 2 1.8 -1
    Chevron $g $white 18.3 10 2 1.8 1
    Fill-Round $g $base 11 8.2 2 3.6 0.8
    foreach ($x in @(8.6, 11.3, 14)) {
        Fill-Round $g $white $x 17 2.2 2.2 1.1
    }
    $g.Dispose()
    return $b
}

# TDaisySteps: three circles on a line, the last one not reached yet
function Draw-Steps {
    $base = [System.Drawing.Color]::FromArgb(240, 83, 28)
    $b = New-Tile $base
    $g = New-Gfx $b
    $line = Pen $white 1.8
    $g.DrawLine($line, 5.5, 9, 12, 9)
    $line.Dispose()
    $faint = Pen (Alpha 120) 1.8
    $g.DrawLine($faint, 12, 9, 18.5, 9)
    $faint.Dispose()
    $br = New-Object System.Drawing.SolidBrush $white
    $g.FillEllipse($br, 3, 6.5, 5, 5)
    $g.FillEllipse($br, 9.5, 6.5, 5, 5)
    $br.Dispose()
    $br = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(252, 190, 165))
    $g.FillEllipse($br, 16, 6.5, 5, 5)
    $br.Dispose()
    Fill-Round $g $white 2.6 15 5.8 1.8 0.9
    Fill-Round $g $white 9.1 15 5.8 1.8 0.9
    Fill-Round $g (Alpha 120) 15.6 15 5.8 1.8 0.9
    Fill-Round $g (Alpha 150) 3.6 18 3.8 1.6 0.8
    Fill-Round $g (Alpha 150) 10.1 18 3.8 1.6 0.8
    $g.Dispose()
    return $b
}

# TDaisyTitleBarPanel: a window whose title bar carries a control and the caption buttons
function Draw-TitleBarPanel {
    $base = [System.Drawing.Color]::FromArgb(13, 148, 136)
    $b = New-Tile $base
    $g = New-Gfx $b
    Fill-Round $g $white 3.5 4.5 17 15 2
    $bar = [System.Drawing.Color]::FromArgb(45, 55, 72)
    Fill-Round $g $bar 3.5 4.5 17 5.4 2
    $bar2 = New-Object System.Drawing.SolidBrush $bar
    $g.FillRectangle($bar2, 3.5, 7, 17, 2.9)
    $bar2.Dispose()
    Fill-Round $g ([System.Drawing.Color]::FromArgb(251, 191, 36)) 5 5.9 5 2.6 1.3
    Fill-Round $g (Alpha 200) 11.2 6.7 3.2 1 0.5
    $x = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(248, 113, 113))
    $g.FillEllipse($x, 15.2, 6.1, 2.2, 2.2)
    $x.Dispose()
    $x = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(134, 239, 172))
    $g.FillEllipse($x, 17.8, 6.1, 2.2, 2.2)
    $x.Dispose()
    Fill-Round $g ([System.Drawing.Color]::FromArgb(153, 246, 228)) 5 12 10 1.8 0.9
    Fill-Round $g ([System.Drawing.Color]::FromArgb(153, 246, 228)) 5 15.2 7 1.8 0.9
    $g.Dispose()
    return $b
}
$icons = [ordered]@{
    'Breadcrumbs' = (Draw-Breadcrumbs)
    'Dock'        = (Draw-Dock)
    'Link'        = (Draw-Link)
    'Pagination'  = (Draw-Pagination)
    'Steps'       = (Draw-Steps)
    'TitleBarPanel' = (Draw-TitleBarPanel)
}

function Build-Dcr($prefix, $dcr) {
    $rc = Join-Path $iconDir 'Navigation.Reg3.rc'
    $lines = @()
    foreach ($name in $icons.Keys) {
        $lines += ('T' + ($prefix + $name).ToUpper() + ' BITMAP "' + $name + '.bmp"')
    }
    Set-Content -Path $rc -Value $lines -Encoding ASCII
    Push-Location $iconDir
    try {
        $env:PATH = $bin + ';' + $env:PATH
        & (Join-Path $bin 'cgrc.exe') '-c65001' '-=' 'resinator.exe' $rc "-fo$dcr" | Out-Null
    } finally {
        Pop-Location
        Remove-Item $rc -ErrorAction SilentlyContinue
    }
    'DCR ' + $dcr + ': ' + (Test-Path $dcr)
}

foreach ($name in $icons.Keys) {
    $icons[$name].Save((Join-Path $iconDir "$name.bmp"), [System.Drawing.Imaging.ImageFormat]::Bmp)
}
Build-Dcr 'Daisy' (Join-Path $root 'Source\VCL\Daisy.VCL.Reg3.dcr')
Build-Dcr 'DaisyFmx' (Join-Path $root 'Source\FMX\Daisy.FMX.Reg3.dcr')

if ($Preview -ne '') {
    $scale = 10
    $sheet = New-Object System.Drawing.Bitmap ($icons.Count * (24 * $scale + 10) + 10), (24 * $scale + 20)
    $g = [System.Drawing.Graphics]::FromImage($sheet)
    $g.Clear([System.Drawing.Color]::FromArgb(240, 240, 240))
    $g.InterpolationMode = 'NearestNeighbor'
    $g.PixelOffsetMode = 'Half'
    $i = 0
    foreach ($name in $icons.Keys) {
        $copy = $icons[$name].Clone()
        $copy.MakeTransparent($key)
        $g.DrawImage($copy, 10 + $i * (24 * $scale + 10), 10, 24 * $scale, 24 * $scale)
        $i++
    }
    $g.Dispose()
    $sheet.Save((Join-Path $Preview 'navigation.png'), [System.Drawing.Imaging.ImageFormat]::Png)
}

