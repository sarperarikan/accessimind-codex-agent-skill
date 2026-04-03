param(
  [Parameter(Mandatory = $true)]
  [string[]]$Urls,

  [string]$OutputDir = "",

  [int]$MotorTabSteps = 300,

  [string]$RepoRoot = ""
)

$ErrorActionPreference = "Stop"

function Get-RepoRoot {
  if ($RepoRoot -and (Test-Path $RepoRoot)) {
    return (Resolve-Path $RepoRoot).Path
  }
  return (Resolve-Path (Join-Path $PSScriptRoot "..\\..\\..")).Path
}

function Safe-Name([string]$url) {
  $name = $url -replace "^https?://", ""
  $name = $name -replace "[^a-zA-Z0-9\\-]+", "-"
  return $name.Trim("-").ToLower()
}

$root = Get-RepoRoot
$codeHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { "$HOME\\.codex" }
$pw = Join-Path $codeHome "skills\\playwright\\scripts\\playwright_cli.ps1"
if (-not (Test-Path $pw)) {
  throw "Playwright wrapper not found: $pw"
}

$nvdaRunner = Join-Path $root "skills\\nvda-portable-a11y-audit\\scripts\\invoke-nvda-playwright-audit.ps1"
if (-not (Test-Path $nvdaRunner)) {
  throw "NVDA runner not found: $nvdaRunner"
}

if (-not $OutputDir) {
  $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
  $OutputDir = Join-Path $root "reports\\full-persona-audit-$stamp"
}
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

$blindDir = Join-Path $OutputDir "blind"
$lowVisionDir = Join-Path $OutputDir "low-vision"
$motorDir = Join-Path $OutputDir "motor"
New-Item -ItemType Directory -Path $blindDir -Force | Out-Null
New-Item -ItemType Directory -Path $lowVisionDir -Force | Out-Null
New-Item -ItemType Directory -Path $motorDir -Force | Out-Null

# Blind track via portable NVDA runner
& powershell -ExecutionPolicy Bypass -File $nvdaRunner -Urls $Urls -OutputDir $blindDir | Out-Null

$lowVisionResults = @()
$motorResults = @()

foreach ($url in $Urls) {
  $slug = Safe-Name $url
  & $pw goto $url | Out-Null

  $zoomChecks = @()
  foreach ($z in @(2, 4)) {
    & $pw eval "(() => { document.documentElement.style.zoom='$z'; return { zoom: '$z', width: window.innerWidth, scrollWidth: document.documentElement.scrollWidth, reflowRisk: document.documentElement.scrollWidth > window.innerWidth }; })()" | Out-Null
    $img = Join-Path $lowVisionDir "$slug-zoom-$z.png"
    & $pw screenshot --filename $img | Out-Null

    $reflowRaw = & $pw eval "(() => ({ zoom: '$z', url: location.href, title: document.title, width: window.innerWidth, scrollWidth: document.documentElement.scrollWidth, reflowRisk: document.documentElement.scrollWidth > window.innerWidth }))()"
    $focusRaw = & $pw eval "(() => { const e=document.activeElement; const s=e?getComputedStyle(e):null; return { zoom: '$z', tag:e?e.tagName:null, id:e?e.id:null, name:(e?.getAttribute('aria-label')||e?.textContent||'').trim().slice(0,80), outlineStyle:s?s.outlineStyle:null, outlineWidth:s?s.outlineWidth:null }; })()"
    $zoomChecks += [pscustomobject]@{
      zoom = $z
      screenshot = $img
      reflowRaw = $reflowRaw
      focusRaw = $focusRaw
    }
  }

  & $pw eval "(() => { document.documentElement.style.zoom='1'; return true; })()" | Out-Null

  $targetSizeRaw = & $pw eval "(() => { const items=[...document.querySelectorAll('a,button,input,select,textarea,[role=button],[tabindex]')]; const small=items.filter(el=>{const r=el.getBoundingClientRect(); return r.width>0 && r.height>0 && (r.width<44 || r.height<44);}); return {url:location.href,total:items.length,smallTargets:small.length,samples:small.slice(0,8).map(el=>({tag:el.tagName,id:el.id,cls:el.className,w:Math.round(el.getBoundingClientRect().width),h:Math.round(el.getBoundingClientRect().height)}))}; })()"
  $lowVisionResults += [pscustomobject]@{
    url = $url
    zoomChecks = $zoomChecks
    targetSizeRaw = $targetSizeRaw
  }

  # Motor track
  $seen = @{}
  $loopHits = 0
  for ($i = 1; $i -le $MotorTabSteps; $i++) {
    & $pw press Tab | Out-Null
    $focusKeyRaw = & $pw eval "(() => { const e=document.activeElement; return {step:$i,key:[e?e.tagName:'',e?e.id:'',e?e.className:'',e?e.getAttribute('role'):''].join('|'),name:(e?.getAttribute('aria-label')||e?.textContent||'').trim().slice(0,50)} })()"
    if ($seen.ContainsKey($focusKeyRaw)) {
      $loopHits++
    } else {
      $seen[$focusKeyRaw] = $true
    }
  }
  $motorResults += [pscustomobject]@{
    url = $url
    tabSteps = $MotorTabSteps
    uniqueFocusKeys = $seen.Count
    loopHits = $loopHits
    loopRisk = ($loopHits -gt ($MotorTabSteps * 0.2))
  }
}

$summary = [pscustomobject]@{
  createdAt = (Get-Date).ToString("o")
  outputDir = $OutputDir
  blind = [pscustomobject]@{
    path = $blindDir
    summaryJson = (Join-Path $blindDir "summary.json")
    summaryMd = (Join-Path $blindDir "summary.md")
  }
  lowVision = $lowVisionResults
  motor = $motorResults
}

$summaryPath = Join-Path $OutputDir "summary.json"
$summary | ConvertTo-Json -Depth 8 | Set-Content -Path $summaryPath

$blindMdPath = Join-Path $OutputDir "blind.md"
$lowMdPath = Join-Path $OutputDir "low-vision.md"
$motorMdPath = Join-Path $OutputDir "motor.md"
$summaryMdPath = Join-Path $OutputDir "summary.md"

@(
  "# Blind Track"
  ""
  "- NVDA output folder: $blindDir"
  "- JSON: $(Join-Path $blindDir 'summary.json')"
  "- Markdown: $(Join-Path $blindDir 'summary.md')"
) -join "`r`n" | Set-Content -Path $blindMdPath

$lv = @()
$lv += "# Low-Vision Track"
foreach ($r in $lowVisionResults) {
  $lv += ""
  $lv += "## $($r.url)"
  $lv += "- Zoom checks: 200%, 400%"
  $lv += "- Target-size evidence: captured"
}
$lv -join "`r`n" | Set-Content -Path $lowMdPath

$mt = @()
$mt += "# Motor Track"
foreach ($m in $motorResults) {
  $mt += ""
  $mt += "## $($m.url)"
  $mt += "- Tab steps: $($m.tabSteps)"
  $mt += "- Unique focus keys: $($m.uniqueFocusKeys)"
  $mt += "- Loop hits: $($m.loopHits)"
  $mt += "- Loop risk: $($m.loopRisk)"
}
$mt -join "`r`n" | Set-Content -Path $motorMdPath

@(
  "# Full Persona Audit Summary"
  ""
  "- Output folder: $OutputDir"
  "- Blind report: $blindMdPath"
  "- Low-vision report: $lowMdPath"
  "- Motor report: $motorMdPath"
  "- JSON summary: $summaryPath"
) -join "`r`n" | Set-Content -Path $summaryMdPath

Write-Host "Full persona audit completed."
Write-Host "Summary: $summaryPath"
