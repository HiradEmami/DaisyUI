# Builds the component palette icons (24 x 24 line drawings on white).
# Only four colours are used: white, black, dark grey and dark green.
#   Icons\<Name>.bmp                (white tile, corner pixels use the magenta transparent key)
#   Source\VCL\Daisy.VCL.Reg.dcr, Reg2.dcr, Reg3.dcr   (resource TDAISY<NAME>)
#   Source\FMX\Daisy.FMX.Reg.dcr, Reg2.dcr, Reg3.dcr   (resource TDAISYFMX<NAME>)
# The VCL and FMX component of a pair share the same artwork.
# Needs C:\Program Files (x86)\Embarcadero\Studio\37.0\bin64 for cgrc.exe.
# Optional: -Preview <folder> also writes an enlarged contact sheet (icons.png).
param([string]$Preview = '')

Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
if (-not $root) { $root = (Get-Location).Path }
$iconDir = Join-Path $root 'Icons'
$bin = 'C:\Program Files (x86)\Embarcadero\Studio\37.0\bin64'

$key = [System.Drawing.Color]::FromArgb(255, 0, 255)
$W = [System.Drawing.Color]::FromArgb(255, 255, 255)
$K = [System.Drawing.Color]::FromArgb(0, 0, 0)
$G = [System.Drawing.Color]::FromArgb(80, 80, 80)
$D = [System.Drawing.Color]::FromArgb(0, 100, 0)

$script:bmp = $null

function New-Canvas {
    $script:bmp = New-Object System.Drawing.Bitmap 24, 24, ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
    for ($y = 0; $y -lt 24; $y++) { for ($x = 0; $x -lt 24; $x++) { $script:bmp.SetPixel($x, $y, $W) } }
    foreach ($p in @(@(0, 0), @(23, 0), @(0, 23), @(23, 23))) { $script:bmp.SetPixel($p[0], $p[1], $key) }
}

function P($x, $y, $c) {
    $x = [int][Math]::Round($x); $y = [int][Math]::Round($y)
    if ($x -ge 0 -and $x -le 23 -and $y -ge 0 -and $y -le 23) { $script:bmp.SetPixel($x, $y, $c) }
}
function HL($x1, $x2, $y, $c) { for ($x = $x1; $x -le $x2; $x++) { P $x $y $c } }
function VL($x, $y1, $y2, $c) { for ($y = $y1; $y -le $y2; $y++) { P $x $y $c } }
function Rc($x1, $y1, $x2, $y2, $c) { HL $x1 $x2 $y1 $c; HL $x1 $x2 $y2 $c; VL $x1 $y1 $y2 $c; VL $x2 $y1 $y2 $c }
function FRc($x1, $y1, $x2, $y2, $c) { for ($y = $y1; $y -le $y2; $y++) { HL $x1 $x2 $y $c } }
# rectangle with the corner pixels left out
function RRc($x1, $y1, $x2, $y2, $c) {
    HL ($x1 + 1) ($x2 - 1) $y1 $c; HL ($x1 + 1) ($x2 - 1) $y2 $c
    VL $x1 ($y1 + 1) ($y2 - 1) $c; VL $x2 ($y1 + 1) ($y2 - 1) $c
}
function Ln($x1, $y1, $x2, $y2, $c) {
    $dx = [Math]::Abs($x2 - $x1); $dy = [Math]::Abs($y2 - $y1)
    $sx = if ($x1 -lt $x2) { 1 } else { -1 }
    $sy = if ($y1 -lt $y2) { 1 } else { -1 }
    $e = $dx - $dy
    while ($true) {
        P $x1 $y1 $c
        if ($x1 -eq $x2 -and $y1 -eq $y2) { break }
        $e2 = 2 * $e
        if ($e2 -gt -$dy) { $e -= $dy; $x1 += $sx }
        if ($e2 -lt $dx) { $e += $dx; $y1 += $sy }
    }
}
function Ci($cx, $cy, $r, $c) {
    for ($y = 0; $y -lt 24; $y++) { for ($x = 0; $x -lt 24; $x++) {
        $d = [Math]::Sqrt(($x - $cx) * ($x - $cx) + ($y - $cy) * ($y - $cy))
        if ($d -ge $r - 0.5 -and $d -lt $r + 0.5) { P $x $y $c }
    } }
}
function FCi($cx, $cy, $r, $c) {
    for ($y = 0; $y -lt 24; $y++) { for ($x = 0; $x -lt 24; $x++) {
        $d = [Math]::Sqrt(($x - $cx) * ($x - $cx) + ($y - $cy) * ($y - $cy))
        if ($d -le $r) { P $x $y $c }
    } }
}
function FF($x, $y, $c) {
    $target = $script:bmp.GetPixel($x, $y)
    if ($target.ToArgb() -eq $c.ToArgb()) { return }
    $stack = New-Object System.Collections.Generic.Stack[object]
    $stack.Push(@($x, $y))
    while ($stack.Count -gt 0) {
        $p = $stack.Pop()
        if ($p[0] -lt 0 -or $p[0] -gt 23 -or $p[1] -lt 0 -or $p[1] -gt 23) { continue }
        if ($script:bmp.GetPixel($p[0], $p[1]).ToArgb() -ne $target.ToArgb()) { continue }
        $script:bmp.SetPixel($p[0], $p[1], $c)
        $stack.Push(@(($p[0] + 1), $p[1])); $stack.Push(@(($p[0] - 1), $p[1]))
        $stack.Push(@($p[0], ($p[1] + 1))); $stack.Push(@($p[0], ($p[1] - 1)))
    }
}
# white box with an outline, used to lay one shape over another
function Box($x1, $y1, $x2, $y2, $c) { FRc $x1 $y1 $x2 $y2 $W; Rc $x1 $y1 $x2 $y2 $c }

$draw = [ordered]@{}

$draw['Accordion'] = {
    RRc 3 2 20 6 $K; HL 5 11 4 $G; P 16 3 $D; P 17 4 $D; P 18 3 $D
    HL 5 15 8 $G; HL 5 12 10 $G
    RRc 3 12 20 16 $K; HL 5 11 14 $G; P 17 13 $D; P 18 14 $D; P 17 15 $D
    RRc 3 18 20 22 $K; HL 5 11 20 $G; P 17 19 $D; P 18 20 $D; P 17 21 $D
}
$draw['Alert'] = {
    RRc 2 5 21 18 $K; Ci 7 11 3 $D; P 7 9 $D; VL 7 11 13 $D
    HL 12 19 9 $G; HL 12 17 12 $G; HL 12 18 15 $G
}
$draw['AnimationButton'] = {
    RRc 7 7 21 16 $K; HL 10 18 11 $D; HL 10 15 13 $G
    HL 1 4 9 $G; HL 2 4 11 $G; HL 1 4 13 $G
    VL 19 2 4 $D; HL 18 20 3 $D; P 22 5 $D
}
$draw['Badge'] = {
    RRc 3 8 20 15 $K; HL 6 12 11 $G; HL 6 12 12 $G; FCi 16.5 11.5 2.2 $D
}
$draw['BadgeButton'] = {
    RRc 2 8 16 18 $K; HL 5 13 12 $G; HL 5 11 14 $G
    FCi 18 6 3.6 $W; Ci 18 6 3.5 $K; FCi 18 6 1.5 $D
}
$draw['Breadcrumbs'] = {
    HL 1 4 11 $G; HL 1 4 12 $G
    Ln 6 9 8 11 $K; Ln 8 11 6 13 $K
    HL 10 13 11 $G; HL 10 13 12 $G
    Ln 15 9 17 11 $K; Ln 17 11 15 13 $K
    HL 19 22 11 $D; HL 19 22 12 $D; HL 19 22 15 $D
}
$draw['Button'] = {
    RRc 2 7 21 16 $K; HL 6 17 11 $D; HL 6 17 12 $D; HL 4 19 18 $G
}
$draw['Calendar'] = {
    RRc 3 4 20 21 $K; HL 3 20 8 $K; VL 7 2 5 $K; VL 16 2 5 $K
    foreach ($y in 11, 14, 17) { foreach ($x in 6, 10, 14, 17) { P $x $y $G } }
    FRc 13 13 15 15 $D
}
$draw['Card'] = {
    RRc 3 3 20 20 $K; HL 3 20 11 $K
    Ln 5 10 8 6 $G; Ln 8 6 11 10 $G; Ln 11 10 13 8 $G; Ln 13 8 15 10 $G; FCi 17 6 1.3 $D
    HL 6 14 14 $K; HL 6 17 16 $G; HL 6 13 18 $G
}
$draw['ChatBubble'] = {
    RRc 2 4 21 15 $K; HL 5 9 15 $W; Ln 5 15 4 19 $K; Ln 4 19 9 15 $K
    HL 6 17 8 $G; HL 6 13 11 $D
}
$draw['CheckBox'] = {
    RRc 4 4 19 19 $K
    Ln 7 11 10 15 $D; Ln 10 15 16 7 $D; Ln 7 12 10 16 $D; Ln 10 16 16 8 $D
}
$draw['CircleButton'] = {
    Ci 11.5 11.5 9.5 $K; HL 7 16 11 $D; HL 7 16 12 $D; VL 11 7 16 $D; VL 12 7 16 $D
}
$draw['Countdown'] = {
    RRc 2 4 10 16 $K; RRc 13 4 21 16 $K
    Rc 5 7 7 13 $G
    HL 16 18 7 $D; VL 18 7 13 $D; HL 16 18 10 $D; HL 16 18 13 $D
    HL 4 8 19 $G; HL 15 19 19 $G
}
$draw['DatePicker'] = {
    HL 3 9 4 $G; RRc 2 7 21 19 $K; HL 5 11 13 $G
    Rc 15 10 19 16 $D; HL 15 19 12 $D
}
$draw['Dock'] = {
    Rc 4 3 19 9 $G; RRc 2 13 21 20 $K
    Rc 5 15 8 18 $G; Rc 10 15 13 18 $D; HL 10 13 19 $D; Rc 15 15 18 18 $G
}
$draw['DropdownMenu'] = {
    RRc 3 2 15 7 $K; HL 5 8 4 $G; P 11 4 $D; P 12 5 $D; P 13 4 $D
    RRc 3 9 17 21 $K; HL 6 13 12 $G; HL 6 13 15 $G; HL 6 13 18 $D
}
$draw['Fab'] = {
    RRc 2 3 21 20 $G; HL 5 12 7 $G; HL 5 10 10 $G
    FCi 16 14 5.7 $W; Ci 16 14 5.5 $K; HL 13 19 14 $D; VL 16 11 17 $D
}
$draw['FieldSet'] = {
    RRc 2 6 21 20 $K; HL 5 13 6 $W; HL 6 12 6 $D
    Rc 5 10 18 13 $G; Rc 5 15 18 18 $G
}
$draw['FormStyler'] = {
    RRc 2 3 21 20 $K; HL 2 21 7 $K; P 4 5 $G; P 6 5 $G
    Rc 5 10 8 13 $G; Rc 10 10 13 13 $D; Rc 15 10 18 13 $K; HL 5 18 16 $G; HL 5 14 18 $G
}
$draw['Indicator'] = {
    Rc 3 7 16 19 $K; HL 6 13 11 $G; HL 6 11 14 $G
    FCi 17 7 3.7 $W; Ci 17 7 3.5 $K; FCi 17 7 1.5 $D
}
$draw['Label'] = {
    Ln 3 18 7 6 $K; Ln 7 6 11 18 $K; HL 5 9 13 $K
    HL 14 21 8 $G; HL 14 21 11 $G; HL 14 19 14 $G; HL 3 20 20 $D
}
$draw['Link'] = {
    RRc 2 7 13 15 $K; RRc 10 7 21 15 $D; HL 5 18 19 $G
}
$draw['List'] = {
    RRc 2 3 21 21 $K
    foreach ($y in 7, 12, 17) { Ci 6 $y 2 $D; HL 10 18 ($y - 1) $G; HL 10 15 ($y + 1) $G }
    HL 3 20 9 $G; HL 3 20 14 $G
}
$draw['LoadingButton'] = {
    RRc 2 7 21 16 $K
    $cx = 8; $cy = 11
    $o = @(@(0, -3), @(2, -2), @(3, 0), @(2, 2), @(0, 3), @(-2, 2), @(-3, 0), @(-2, -2))
    for ($i = 0; $i -lt 8; $i++) { P ($cx + $o[$i][0]) ($cy + $o[$i][1]) $(if ($i -lt 5) { $D } else { $G }) }
    HL 14 19 11 $G; HL 14 18 13 $G
}
$draw['MainMenu'] = {
    RRc 2 3 21 8 $K; HL 4 7 5 $D; HL 10 13 5 $G; HL 16 19 5 $G
    Rc 3 9 12 20 $K; HL 5 10 12 $D; HL 5 10 15 $G; HL 5 10 18 $G
}
$draw['Menu'] = {
    RRc 4 2 19 21 $K; Rc 6 4 17 8 $D
    foreach ($y in 6, 11, 15, 19) { P 8 $y $K; HL 11 15 $y $G }
}
$draw['PageControl'] = {
    Rc 2 8 21 20 $K; Rc 2 4 9 8 $K; HL 3 8 8 $W; HL 3 8 4 $D; HL 4 7 6 $G
    Rc 10 5 15 8 $G; Rc 16 5 21 8 $G
    HL 5 17 12 $G; HL 5 14 15 $G; HL 5 16 18 $G
}
$draw['Pagination'] = {
    Rc 1 8 6 15 $K; P 4 10 $K; P 3 11 $K; P 3 12 $K; P 4 13 $K
    Rc 9 8 14 15 $D; VL 11 10 13 $D
    Rc 17 8 22 15 $K; P 19 10 $K; P 20 11 $K; P 20 12 $K; P 19 13 $K
    P 8 19 $G; P 11 19 $G; P 14 19 $G; P 17 19 $G
}
$draw['Panel'] = {
    RRc 2 3 21 20 $K; HL 5 12 5 $D
    for ($x = 5; $x -le 18; $x += 2) { P $x 8 $G; P $x 16 $G }
    for ($y = 8; $y -le 16; $y += 2) { P 5 $y $G; P 18 $y $G }
}
$draw['PopupMenu'] = {
    Rc 8 6 21 20 $K; HL 11 18 9 $G; HL 11 18 12 $D; HL 11 18 15 $G; HL 11 16 18 $G
    Ln 2 2 2 12 $D; Ln 2 12 5 9 $D; Ln 5 9 9 9 $D; Ln 9 9 2 2 $D
}
$draw['Progress'] = {
    HL 3 8 5 $G; HL 17 20 5 $G; RRc 2 8 21 14 $K; FRc 4 10 12 12 $D
    foreach ($x in 3, 7, 11, 15, 19) { P $x 17 $G }
}
$draw['RadialProgress'] = {
    for ($y = 0; $y -lt 24; $y++) { for ($x = 0; $x -lt 24; $x++) {
        $dx = $x - 11.5; $dy = $y - 11.5
        $dist = [Math]::Sqrt($dx * $dx + $dy * $dy)
        $a = [Math]::Atan2($dx, -$dy); if ($a -lt 0) { $a += 2 * [Math]::PI }
        if ($dist -ge 7.4 -and $dist -lt 9.7 -and $a -le 1.5 * [Math]::PI) { P $x $y $D }
        elseif ($dist -ge 8.7 -and $dist -lt 9.7) { P $x $y $G }
    } }
    HL 9 14 11 $K; HL 9 14 12 $K
}
$draw['Range'] = {
    HL 3 13 11 $D; HL 3 13 12 $D; HL 14 20 12 $G
    FCi 14 11.5 3.6 $W; Ci 14 11.5 3.5 $K
    foreach ($x in 3, 6, 9, 12, 15, 18) { P $x 18 $G }
}
$draw['Rating'] = {
    $cx = 11.5; $cy = 10.5
    $pts = @()
    for ($i = 0; $i -lt 10; $i++) {
        $r = if ($i % 2 -eq 0) { 9 } else { 3.9 }
        $a = -[Math]::PI / 2 + $i * [Math]::PI / 5
        $pts += , @([int][Math]::Round($cx + $r * [Math]::Cos($a)), [int][Math]::Round($cy + $r * [Math]::Sin($a)))
    }
    for ($i = 0; $i -lt 10; $i++) { $n = ($i + 1) % 10; Ln $pts[$i][0] $pts[$i][1] $pts[$n][0] $pts[$n][1] $K }
    FF 11 11 $D
    P 5 21 $D; P 8 21 $D; P 11 21 $D; P 14 21 $G; P 17 21 $G
}
$draw['Select'] = {
    RRc 2 6 21 14 $K; HL 5 11 10 $G; VL 16 7 13 $G; P 17 9 $D; P 18 10 $D; P 19 9 $D
    Rc 2 16 21 21 $G; HL 5 14 18 $G; HL 5 11 20 $D
}
$draw['SquareButton'] = {
    Rc 4 4 19 19 $K; Ln 9 8 15 12 $D; Ln 15 12 9 16 $D; VL 9 8 16 $D
}
$draw['Stack'] = {
    Rc 6 3 21 11 $G
    Box 4 6 19 14 $G
    Box 2 9 17 20 $K; HL 5 12 13 $D; HL 5 14 16 $G
}
$draw['Stat'] = {
    RRc 2 3 21 20 $K; HL 5 11 6 $G
    VL 6 9 14 $K; P 5 10 $K
    HL 9 12 9 $K; P 12 10 $K; HL 9 12 11 $K; P 9 12 $K; HL 9 12 14 $K; P 9 13 $K
    VL 6 16 18 $D; P 5 17 $D; P 7 17 $D; HL 10 17 17 $D
}
$draw['Status'] = {
    FCi 11.5 11.5 3 $D; Ci 11.5 11.5 6 $K; Ci 11.5 11.5 9 $G
}
$draw['Steps'] = {
    HL 7 9 8 $K; HL 15 17 8 $G
    FCi 4 8 2.5 $D; FCi 12 8 2.5 $D; Ci 20 8 2.5 $K
    HL 2 6 14 $G; HL 10 14 14 $G; HL 18 22 14 $G
    HL 3 5 17 $G; HL 11 13 17 $G; HL 19 21 17 $G
}
$draw['SVGImage'] = {
    Rc 4 5 19 18 $K
    Ln 5 16 9 10 $G; Ln 9 10 12 14 $G; Ln 12 14 14 12 $G; Ln 14 12 18 16 $G; FCi 15 8 1.4 $D
    Box 2 3 6 7 $D; Box 17 3 21 7 $D; Box 2 16 6 20 $D; Box 17 16 21 20 $D
}
$draw['Swap'] = {
    HL 3 17 8 $K; Ln 17 8 14 5 $K; Ln 17 8 14 11 $K
    HL 6 20 16 $D; Ln 6 16 9 13 $D; Ln 6 16 9 19 $D
}
$draw['Table'] = {
    Rc 2 3 21 20 $K; HL 3 20 8 $D; HL 4 6 5 $G; HL 10 13 5 $G; HL 17 19 5 $G
    VL 8 3 20 $G; VL 15 3 20 $G; HL 3 20 12 $G; HL 3 20 16 $G
}
$draw['TabSheet'] = {
    Rc 2 8 21 20 $K; Rc 2 4 10 8 $K; HL 3 9 8 $W; HL 3 9 4 $D; HL 4 8 6 $G
    HL 5 17 12 $G; HL 5 14 15 $G; HL 5 16 18 $G
}
$draw['TextArea'] = {
    RRc 2 3 21 20 $K; HL 5 18 7 $G; HL 5 16 10 $G; HL 5 17 13 $G; HL 5 10 16 $G; VL 12 15 17 $D
    Ln 18 16 16 18 $G; Ln 18 13 13 18 $G
}
$draw['TextInput'] = {
    HL 3 9 4 $G; RRc 2 7 21 17 $K; HL 5 12 12 $G; VL 14 10 14 $D; HL 3 12 20 $G
}
$draw['ThemeController'] = {
    Ci 11.5 11.5 6.5 $K
    for ($y = 6; $y -le 17; $y += 2) { for ($x = 5; $x -le 11; $x++) {
        $dx = $x - 11.5; $dy = $y - 11.5
        if ([Math]::Sqrt($dx * $dx + $dy * $dy) -lt 5.7) { P $x $y $D }
    } }
    for ($ray = 0; $ray -lt 8; $ray++) {
        $a = $ray * [Math]::PI / 4
        Ln ([Math]::Round(11.5 + 8.8 * [Math]::Cos($a))) ([Math]::Round(11.5 + 8.8 * [Math]::Sin($a))) ([Math]::Round(11.5 + 10.8 * [Math]::Cos($a))) ([Math]::Round(11.5 + 10.8 * [Math]::Sin($a))) $G
    }
}
$draw['TitleBarPanel'] = {
    Rc 2 3 21 20 $K; HL 2 21 8 $K
    Rc 4 4 10 7 $D; HL 12 14 6 $G; Rc 15 4 17 6 $G; Ln 18 4 20 6 $D; Ln 20 4 18 6 $D
    HL 5 17 12 $G; HL 5 14 15 $G; HL 5 16 18 $G
}
$draw['Toast'] = {
    RRc 2 3 21 20 $G
    Box 11 5 21 9 $K; HL 13 18 7 $G
    Box 8 12 21 19 $K; FCi 11.5 15.5 1.6 $D; HL 14 19 15 $G
}
$draw['Toggle'] = {
    RRc 2 7 21 16 $K; HL 5 9 11 $G; FCi 16.5 11.5 3.5 $D
}

# resource name (without TDAISY / TDAISYFMX) -> icon file
$groups = @(
    @{ Vcl = 'Daisy.VCL.Reg.dcr'; Fmx = 'Daisy.FMX.Reg.dcr'; Items = @(
        'Accordion', 'Alert', 'AnimationButton', 'Badge', 'BadgeButton', 'Button', 'Card', 'ChatBubble', 'CheckBox',
        'CircleButton', 'Countdown', 'DropdownMenu', 'FloatingActionButton=Fab', 'FormStyler', 'Label', 'List',
        'LoadingButton', 'MainMenu', 'Menu', 'PageControl', 'Panel', 'PopupMenu', 'Select', 'SquareButton', 'Stat',
        'Status', 'SVGImage', 'Table', 'TabSheet', 'TextArea', 'TextInput', 'Toggle') },
    @{ Vcl = 'Daisy.VCL.Reg2.dcr'; Fmx = 'Daisy.FMX.Reg2.dcr'; Items = @(
        'Calendar', 'DatePicker', 'FieldSet', 'Indicator', 'Progress', 'RadialProgress', 'Range', 'Rating', 'Stack',
        'Swap', 'ThemeController', 'Toast') },
    @{ Vcl = 'Daisy.VCL.Reg3.dcr'; Fmx = 'Daisy.FMX.Reg3.dcr'; Items = @(
        'Breadcrumbs', 'Dock', 'Link', 'Pagination', 'Steps', 'TitleBarPanel') }
)

$images = [ordered]@{}
foreach ($name in $draw.Keys) {
    New-Canvas
    & $draw[$name]
    $script:bmp.Save((Join-Path $iconDir "$name.bmp"), [System.Drawing.Imaging.ImageFormat]::Bmp)
    $images[$name] = $script:bmp
}

function Build-Dcr($group, $prefix, $dcr) {
    $rc = Join-Path $iconDir 'Palette.rc'
    $lines = @()
    foreach ($item in $group.Items) {
        $pair = $item -split '='
        $res = $pair[0]
        $file = if ($pair.Count -gt 1) { $pair[1] } else { $pair[0] }
        $lines += ('T' + ($prefix + $res).ToUpper() + ' BITMAP "' + $file + '.bmp"')
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

foreach ($group in $groups) {
    Build-Dcr $group 'Daisy' (Join-Path $root ('Source\VCL\' + $group.Vcl))
    Build-Dcr $group 'DaisyFmx' (Join-Path $root ('Source\FMX\' + $group.Fmx))
}

if ($Preview -ne '') {
    $scale = 6; $cols = 10
    $cell = 24 * $scale + 24
    $rows = [Math]::Ceiling($images.Count / $cols)
    $sheet = New-Object System.Drawing.Bitmap ($cols * $cell + 10), ($rows * $cell + 10)
    $g = [System.Drawing.Graphics]::FromImage($sheet)
    $g.Clear([System.Drawing.Color]::FromArgb(236, 236, 236))
    $g.InterpolationMode = 'NearestNeighbor'
    $g.PixelOffsetMode = 'Half'
    $font = New-Object System.Drawing.Font 'Segoe UI', 8
    $i = 0
    foreach ($name in $images.Keys) {
        $copy = $images[$name].Clone()
        $copy.MakeTransparent($key)
        $x = 10 + ($i % $cols) * $cell; $y = 10 + [Math]::Floor($i / $cols) * $cell
        $g.DrawImage($copy, $x, $y, 24 * $scale, 24 * $scale)
        $g.DrawString($name, $font, [System.Drawing.Brushes]::Black, $x, $y + 24 * $scale + 2)
        $i++
    }
    $g.Dispose()
    $sheet.Save((Join-Path $Preview 'icons.png'), [System.Drawing.Imaging.ImageFormat]::Png)
}
