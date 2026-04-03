param(
  [Parameter(Mandatory = $true)]
  [string[]]$Urls,

  [string]$OutputDir = "",

  [string]$RepoRoot = "",

  [string]$PlaywrightWrapper = ""
)

$ErrorActionPreference = "Stop"

function Get-RepoRoot {
  if ($RepoRoot -and (Test-Path $RepoRoot)) {
    return (Resolve-Path $RepoRoot).Path
  }
  $scriptRoot = $PSScriptRoot
  return (Resolve-Path (Join-Path $scriptRoot "..\\..\\..")).Path
}

function Safe-Name([string]$url) {
  $name = $url -replace "^https?://", ""
  $name = $name -replace "[^a-zA-Z0-9\\-]+", "-"
  return $name.Trim("-").ToLower()
}

$root = Get-RepoRoot
$nvdaRoot = Join-Path $root "NVDA"
$nvdaExe = Join-Path $nvdaRoot "nvda_noUIAccess.exe"
if (-not (Test-Path $nvdaExe)) {
  $nvdaExe = Join-Path $nvdaRoot "nvda.exe"
}
if (-not (Test-Path $nvdaExe)) {
  throw "NVDA executable not found under $nvdaRoot"
}

if (-not $PlaywrightWrapper) {
  $codeHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { "$HOME\\.codex" }
  $PlaywrightWrapper = Join-Path $codeHome "skills\\playwright\\scripts\\playwright_cli.ps1"
}
if (-not (Test-Path $PlaywrightWrapper)) {
  throw "Playwright wrapper not found: $PlaywrightWrapper"
}

if (-not $OutputDir) {
  $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
  $OutputDir = Join-Path $root "reports\\nvda-audit-$stamp"
}
New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null

$nvdaProc = $null
$results = @()
$startedAt = (Get-Date).ToString("o")

try {
  $nvdaProc = Start-Process -FilePath $nvdaExe -ArgumentList "--minimal" -PassThru
  Start-Sleep -Seconds 5

  foreach ($url in $Urls) {
    $slug = Safe-Name $url
    $screenshotPath = Join-Path $OutputDir "$slug.png"

    & $PlaywrightWrapper goto $url | Out-Null
    & $PlaywrightWrapper screenshot --filename $screenshotPath | Out-Null

    $countsRaw = & $PlaywrightWrapper eval "(() => { const bad=[...document.querySelectorAll('a[href]')].filter(a=>{const h=(a.getAttribute('href')||'').trim().toLowerCase(); return h==='#'||h===''||h.startsWith('javascript:');}); const unnamed=[...document.querySelectorAll('button,[role=button]')].filter(b=>!(b.getAttribute('aria-label')||b.getAttribute('title')||b.textContent||'').trim()); const imgsNoAlt=[...document.querySelectorAll('img:not([alt])')].length; const hs=[...document.querySelectorAll('h1,h2,h3,h4,h5,h6')].map(h=>+h.tagName[1]); let jumps=0; for(let i=1;i<hs.length;i++){ if(hs[i]-hs[i-1]>1) jumps++; } return {url:location.href,title:document.title,counts:{badHref:bad.length,unnamedButtons:unnamed.length,imgsNoAlt,headingJumps:jumps}}; })()"

    $focusTrail = @()
    for ($i = 1; $i -le 6; $i++) {
      & $PlaywrightWrapper press Tab | Out-Null
      $focusRaw = & $PlaywrightWrapper eval "(() => { const e=document.activeElement; const s=e?getComputedStyle(e):null; const visible=!!s && s.outlineStyle!=='none' && s.outlineWidth!=='0px'; return {step:$i,tag:e?e.tagName:null,id:e?e.id:null,role:e?e.getAttribute('role'):null,name:(e?.getAttribute('aria-label')||e?.textContent||'').trim().slice(0,80),outlineStyle:s?s.outlineStyle:null,outlineWidth:s?s.outlineWidth:null,outlineVisible:visible}; })()"
      $focusTrail += $focusRaw
    }

    $results += [pscustomobject]@{
      url = $url
      screenshot = $screenshotPath
      dom = $countsRaw
      focusTrailRaw = $focusTrail
    }
  }
}
finally {
  if ($nvdaProc -and -not $nvdaProc.HasExited) {
    Stop-Process -Id $nvdaProc.Id -Force
  }
}

$endedAt = (Get-Date).ToString("o")
$summary = [pscustomobject]@{
  startedAt = $startedAt
  endedAt = $endedAt
  nvdaExecutable = $nvdaExe
  nvdaStarted = [bool]$nvdaProc
  outputDir = $OutputDir
  pages = $results
}

$jsonPath = Join-Path $OutputDir "summary.json"
$mdPath = Join-Path $OutputDir "summary.md"

$summary | ConvertTo-Json -Depth 8 | Set-Content -Path $jsonPath

$md = @()
$md += "# NVDA Portable Accessibility Audit"
$md += ""
$md += "- Started: $startedAt"
$md += "- Ended: $endedAt"
$md += "- NVDA executable: $nvdaExe"
$md += "- NVDA started: $([bool]$nvdaProc)"
$md += ""
$md += "## Pages"
foreach ($p in $results) {
  $md += ""
  $md += "### $($p.url)"
  $md += "- Screenshot: $($p.screenshot)"
  $md += "- DOM summary: captured via Playwright eval output"
  $md += "- Focus trail: captured (6 tab steps)"
}
$md -join "`r`n" | Set-Content -Path $mdPath

Write-Host "Audit completed."
Write-Host "JSON: $jsonPath"
Write-Host "Markdown: $mdPath"
