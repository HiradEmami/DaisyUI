param(
  [string]$Compiler = 'C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\dcc32.exe'
)

$root = Split-Path -Parent $PSScriptRoot
$out = Join-Path $PSScriptRoot 'Output'
New-Item -ItemType Directory -Force "$out\dcu" | Out-Null

$units = "$root\Source\Common;$root\Source\VCL"
$args = @('-Q', '-B', "-E$out", "-NU$out\dcu",
  '-NSWinapi;System.Win;System;Vcl;Vcl.Imaging;Data',
  "-U$units", "-I$units", "$PSScriptRoot\ImeTest.dpr")

& $Compiler @args
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& "$out\ImeTest.exe"
exit $LASTEXITCODE
