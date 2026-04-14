param(
  [Parameter(Mandatory = $true)]
  [string]$Url,
  [int]$MaxPages = 3,
  [string]$ProjectName = "",
  [string]$OutputDir = "",
  [int]$ChromePort = 9222,
  [switch]$StartChrome,
  [switch]$RootOnly,
  [string]$NVDAWorkerJson = ""
)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

function Safe-ProjectName([string]$InputUrl) {
  return ((([uri]$InputUrl).Host -replace '^www\.', '') -replace '[^a-zA-Z0-9\-]+', '-').Trim('-').ToLower()
}

function Ensure-NodeScript([string]$Path) {
  if (-not (Test-Path $Path)) {
    throw "Required script not found: $Path"
  }
}

$discoverScript = Join-Path $root "scripts\accessmind_discover.cjs"
$mergeScript = Join-Path $root "scripts\merge_persona_reports.cjs"
$humanAuditScript = Join-Path $root "scripts\run_human_a11y_report.ps1"

Ensure-NodeScript -Path $discoverScript
Ensure-NodeScript -Path $mergeScript
Ensure-NodeScript -Path $humanAuditScript

if (-not $ProjectName) {
  $ProjectName = Safe-ProjectName -InputUrl $Url
}

if (-not $OutputDir) {
  $datePart = Get-Date -Format "yyyy-MM-dd"
  $OutputDir = Join-Path $root ("reports\{0}-openclaw-{1}" -f $ProjectName, $datePart)
}

New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null

$discoveryJson = Join-Path $OutputDir "discovery.json"
$mergedMd = Join-Path $OutputDir "openclaw-summary.md"
$mergedJson = Join-Path $OutputDir "openclaw-summary.json"
$urls = @($Url)

if (-not $RootOnly) {
  $rawDiscovery = & node $discoverScript --url $Url --max-pages $MaxPages --output $discoveryJson
  if ($LASTEXITCODE -ne 0) {
    throw "Same-domain discovery failed for $Url"
  }
  $discovery = Get-Content -Path $discoveryJson -Raw | ConvertFrom-Json
  $urls = @($discovery.pages | Select-Object -ExpandProperty url -Unique)
  if ($urls.Count -eq 0) {
    $urls = @($Url)
  }
}

$auditParams = @{
  Urls = $urls
  ProjectName = $ProjectName
  OutputDir = $OutputDir
  ChromePort = $ChromePort
}
if ($StartChrome) {
  $auditParams.StartChrome = $true
}

& $humanAuditScript @auditParams | Out-Null

$summaryJson = Join-Path $OutputDir "summary.json"
if (-not (Test-Path $summaryJson)) {
  throw "Expected summary.json was not produced: $summaryJson"
}

$mergeArgs = @(
  $mergeScript,
  "--summary", $summaryJson,
  "--output-md", $mergedMd,
  "--output-json", $mergedJson
)
if (Test-Path $discoveryJson) {
  $mergeArgs += @("--discovery", $discoveryJson)
}
if ($NVDAWorkerJson -and (Test-Path $NVDAWorkerJson)) {
  $mergeArgs += @("--nvda-worker", (Resolve-Path $NVDAWorkerJson).Path)
}

& node @mergeArgs | Out-Null

Write-Host "OpenClaw audit completed."
Write-Host "Audit output: $OutputDir"
Write-Host "Merged summary: $mergedMd"
