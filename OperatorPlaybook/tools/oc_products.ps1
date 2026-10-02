# Create game passes + developer products via Open Cloud from a products table (any project).
# Key read from the USER env var ROBLOX_API_KEY only; never printed or logged. Free: creates items, never buys.
# Ids are merged into <Root>\DOCS\PRODUCT-IDS.json after each item (keys that already have an id are skipped,
# so re-running is safe). Failures are also appended to <Root>\DOCS\PRODUCT-FAILS.log.
#
# Table rows in <Root>\DOCS\PRODUCTS.md (markdown), one per item:
#   | N | Key | Name | Price | Description | `icon/path.png` | pass |
# The last column (pass / product) is the Kind. Rows without it fall back to the old rule (N <= PassCount = pass)
# and print a warning, so add the column.
param(
  [Parameter(Mandatory=$true)][string]$Root,
  [Parameter(Mandatory=$true)][string]$Universe,
  [string]$Table = "DOCS\PRODUCTS.md",
  [string]$Only = "",
  [int]$Limit = 999,
  [int]$PassCount = 9,
  [switch]$WhatIf
)
$ErrorActionPreference = "Stop"
$md = Get-Content (Join-Path $Root $Table)
$jsonPath = Join-Path $Root "DOCS\PRODUCT-IDS.json"
$failLog = Join-Path $Root "DOCS\PRODUCT-FAILS.log"
$ids = [ordered]@{}
if (Test-Path $jsonPath) { (Get-Content $jsonPath -Raw | ConvertFrom-Json).PSObject.Properties | % { $ids[$_.Name] = $_.Value } }

$rows = @()
foreach ($l in $md) {
  if ($l -match '^\|\s*(\d+)\s*\|\s*(\w+)\s*\|\s*([^|]+?)\s*\|\s*(\d+)\s*\|\s*([^|]+?)\s*\|\s*`([^`]+)`\s*\|(?:\s*(pass|product)\s*\|)?') {
    $n = [int]$matches[1]
    $kind = $matches[7]
    if (-not $kind) {
      $kind = $(if ($n -le $PassCount) {'pass'} else {'product'})
      "WARNING row $n ($($matches[2])) has no Kind column; guessed '$kind'"
    }
    $rows += [pscustomobject]@{ N=$n; Key=$matches[2]; Name=$matches[3]; Price=[int]$matches[4]; Desc=$matches[5]; Icon=$matches[6]; Kind=$kind }
  }
}
"rows parsed: $($rows.Count) (passes: $(@($rows | ? Kind -eq 'pass').Count), products: $(@($rows | ? Kind -eq 'product').Count))"
if ($WhatIf) { $rows | Format-Table N, Kind, Key, Name, Price -AutoSize | Out-String; return }

$hdr = $null
$done = 0
try {
  $key = [Environment]::GetEnvironmentVariable('ROBLOX_API_KEY','User')
  if (-not $key) { throw "ROBLOX_API_KEY not set (user env var)" }
  $hdr = [IO.Path]::GetTempFileName()
  [IO.File]::WriteAllText($hdr, "x-api-key: $key")
  $key = $null
  foreach ($r in $rows) {
    if ($Only -and $r.Key -ne $Only) { continue }
    if ($done -ge $Limit) { break }
    if ($ids.Contains($r.Key) -and "$($ids[$r.Key])" -match '^[1-9]\d*$') { "skip $($r.Key) (have $($ids[$r.Key]))"; continue }
    $icon = Join-Path $Root ($r.Icon -replace '/','\')
    if (-not (Test-Path $icon)) { "MISSING ICON $icon"; Add-Content $failLog "$(Get-Date -Format s) $($r.Key) missing icon $icon"; continue }
    if ($r.Kind -eq 'pass') {
      $url = "https://apis.roblox.com/game-passes/v1/universes/$Universe/game-passes"
    } else {
      $url = "https://apis.roblox.com/developer-products/v2/universes/$Universe/developer-products"
    }
    $form = @('-F', "name=$($r.Name)", '-F', "description=$($r.Desc)", '-F', 'isForSale=true', '-F', "price=$($r.Price)", '-F', "imageFile=@$icon;type=image/png")
    $out = & curl.exe -s -w "`nHTTP=%{http_code}" -X POST $url -H "@$hdr" @form
    $txt = ($out -join "`n")
    $id = $null
    if ($txt -match '"(?:gamePassId|productId|id)"\s*:\s*(\d+)') { $id = $matches[1] }
    if ($id) {
      $ids[$r.Key] = [int64]$id
      "OK $($r.Kind) $($r.Key) '$($r.Name)' R$ $($r.Price) -> $id"
      ($ids | ConvertTo-Json) | Set-Content $jsonPath -Encoding UTF8
    } else {
      "FAIL $($r.Key): $txt"
      Add-Content $failLog "$(Get-Date -Format s) $($r.Key) $($r.Kind): $txt"
    }
    $done++
    Start-Sleep -Milliseconds 700
  }
} finally {
  if ($hdr) { Remove-Item $hdr -Force -EA SilentlyContinue }
}
