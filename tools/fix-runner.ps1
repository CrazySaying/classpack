param(
  [Parameter(Mandatory = $true)][string]$Base,
  [Parameter(Mandatory = $true)][string]$FixesFile
)
$ErrorActionPreference = 'Stop'
$fixes = Get-Content -LiteralPath $FixesFile -Raw -Encoding UTF8 | ConvertFrom-Json
$utf8 = New-Object System.Text.UTF8Encoding($false)
$report = New-Object System.Collections.Generic.List[string]
foreach ($fx in $fixes) {
  $dir = if ($fx.glob -ne '') { Join-Path $Base ($fx.glob -replace '/', '\') } else { $Base }
  $files = @(Get-ChildItem -LiteralPath $dir -Filter *.json -File -Recurse | Select-Object -ExpandProperty FullName)
  $total = 0; $touched = 0; $bad = @()
  foreach ($f in $files) {
    $t = [System.IO.File]::ReadAllText($f, [System.Text.Encoding]::UTF8)
    $ms = [regex]::Matches($t, $fx.find)
    if ($ms.Count -eq 0) { continue }
    $total += $ms.Count; $touched++
    $t = [regex]::Replace($t, $fx.find, $fx.replace)
    [System.IO.File]::WriteAllText($f, $t, $utf8)
    try { Get-Content -LiteralPath $f -Raw -Encoding UTF8 | ConvertFrom-Json | Out-Null } catch { $bad += ("JSON INVALID: " + $f + " :: " + $_.Exception.Message) }
  }
  $status = if ($total -eq $fx.expect) { 'OK' } else { 'MISMATCH expect=' + $fx.expect }
  $report.Add(('{0,-32} files={1} count={2}  {3}' -f $fx.name, $touched, $total, $status))
  foreach ($b in $bad) { $report.Add('  ' + $b) }
}
$report
