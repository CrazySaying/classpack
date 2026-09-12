# Summarize one or more classpack item JSONs for review
param([Parameter(Mandatory=$true)][string]$Path)
$j = Get-Content $Path -Raw -Encoding UTF8 | ConvertFrom-Json
"FILE: $(Split-Path $Path -Leaf)"
"_id: $($j._id)   name: $($j.name)   type: $($j.type)   img: $($j.img)"
"identifier: $($j.system.identifier)   properties: $($j.system.properties -join ',')"
"source: $($j.system.source | ConvertTo-Json -Compress)"
$uses = $j.system.uses
"uses: $($uses | ConvertTo-Json -Compress)"
$act = $j.system.activities
if ($act) {
  "== activities =="
  $act.PSObject.Properties | ForEach-Object {
    $a = $_.Value
    $effIds = ($a.effects | ForEach-Object { $_._id }) -join ','
    "  id=$($_.Name) type=$($a.type) name='$($a.name)' effectIds=[$effIds] onSave=$($a.damage.onSave)"
    if ($a.save) { "    save: $($a.save | ConvertTo-Json -Compress)" }
    if ($a.damage) { "    damage: $($a.damage | ConvertTo-Json -Compress -Depth 5)" }
    if ($a.target) { "    target: $($a.target | ConvertTo-Json -Compress -Depth 4)" }
    if ($a.range) { "    range: $($a.range | ConvertTo-Json -Compress)" }
    "    overTimeProperties: $($a.overTimeProperties | ConvertTo-Json -Compress)"
    "    midiProperties: $($a.midiProperties | ConvertTo-Json -Compress)"
  }
}
if ($j.effects) {
  "== effects ($($j.effects.Count)) =="
  foreach ($ef in $j.effects) {
    "  [effect] id=$($ef._id) name='$($ef.name)' transfer=$($ef.transfer) disabled=$($ef.disabled) durations=$($ef.duration | ConvertTo-Json -Compress)"
    if ($ef.statuses) { "    statuses: $($ef.statuses -join ',')" }
    foreach ($c in $ef.changes) {
      "    change: key=[$($c.key)] mode=[$($c.mode)] value=[$($c.value)] priority=$($c.priority)"
    }
    "    flags: $($ef.flags | ConvertTo-Json -Compress -Depth 6)"
  }
}
$im = $j.flags.'dnd5e'.ItemMacro
if ($im) { "== flags.dnd5e.ItemMacro =="; $im }
$mq = $j.flags.'midi-qol'
if ($mq) { "== flags.midi-qol (item) =="; $mq | ConvertTo-Json -Depth 4 }
"SYSTEM.description.value (first 700):"
$desc = $j.system.description.value -replace '<[^>]+>',' ' -replace '\s+',' '
if ($desc.Length -gt 700) { $desc.Substring(0,700) + '...' } else { $desc }
"====================================================================="
