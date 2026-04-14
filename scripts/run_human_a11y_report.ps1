param(
  [Parameter(Mandatory = $true)]
  [string[]]$Urls,
  [string]$ProjectName = "",
  [string]$OutputDir = "",
  [int]$ChromePort = 9222,
  [int]$MotorTabSteps = 80,
  [switch]$StartChrome
)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

function Wait-ForHttpEndpoint([string]$Url, [int]$TimeoutSec = 25, [int]$IntervalMs = 1000) {
  $deadline = (Get-Date).AddSeconds($TimeoutSec)
  while ((Get-Date) -lt $deadline) {
    try {
      Invoke-WebRequest -UseBasicParsing $Url -TimeoutSec 5 | Out-Null
      return $true
    } catch {
      Start-Sleep -Milliseconds $IntervalMs
    }
  }
  return $false
}

if (-not $ProjectName) {
  $ProjectName = ((([uri]$Urls[0]).Host -replace '^www\.', '') -replace '[^a-zA-Z0-9\-]+', '-').Trim('-').ToLower()
}

if (-not $OutputDir) {
  $datePart = Get-Date -Format "yyyy-MM-dd"
  $OutputDir = Join-Path $root ("reports\{0}-human-{1}" -f $ProjectName, $datePart)
}

if ($StartChrome) {
  & (Join-Path $root "scripts\start_chrome_a11y_debug.ps1") -Port $ChromePort -ProfileDir (Join-Path $root "tmp\chrome-a11y-debug") -Urls @($Urls[0]) | Out-Null
}

$cdpUrl = "http://127.0.0.1:$ChromePort"
if (-not (Wait-ForHttpEndpoint -Url "$cdpUrl/json/version" -TimeoutSec 25 -IntervalMs 1000)) {
  throw "Chrome CDP endpoint is not available at $cdpUrl. Start Chrome debug mode first or pass -StartChrome."
}

$fullPersonaParams = @{
  Urls = @($Urls)
  ProjectName = $ProjectName
  OutputDir = $OutputDir
  RepoRoot = $root
  MotorTabSteps = $MotorTabSteps
  CdpUrl = $cdpUrl
}
& (Join-Path $root "skills\full-persona-a11y-audit\scripts\invoke-full-persona-audit.ps1") @fullPersonaParams | Out-Null

& py -3 (Join-Path $root "scripts\generate_actionable_a11y_report.py") `
  --summary (Join-Path $OutputDir "summary.json") `
  --output (Join-Path $OutputDir "developer-ready-report.html") `
  --title "$ProjectName Erişilebilirlik Bulguları Raporu" | Out-Null

Write-Host "İnsan diliyle erişilebilirlik raporu oluşturuldu."
Write-Host "Output: $(Join-Path $OutputDir 'developer-ready-report.html')"
