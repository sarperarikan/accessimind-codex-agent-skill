param(
  [switch]$StartChrome
)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

function Get-EnvValue([string]$Name, [string]$Default = "") {
  $value = [Environment]::GetEnvironmentVariable($Name)
  if ([string]::IsNullOrWhiteSpace($value)) {
    return $Default
  }
  return $value.Trim()
}

$urlsRaw = Get-EnvValue -Name "A11Y_URLS"
if (-not $urlsRaw) {
  throw "A11Y_URLS environment variable is required. Example: `$env:A11Y_URLS='https://example.com,https://example.com/support'; npm run a11y:audit"
}

$urls = @(
  $urlsRaw.Split(",") |
    ForEach-Object { $_.Trim() } |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
)

if ($urls.Count -eq 0) {
  throw "A11Y_URLS did not contain any usable URL."
}

$params = @{
  Urls = $urls
}

$projectName = Get-EnvValue -Name "A11Y_PROJECT_NAME"
if ($projectName) {
  $params.ProjectName = $projectName
}

$outputDir = Get-EnvValue -Name "A11Y_OUTPUT_DIR"
if ($outputDir) {
  $params.OutputDir = $outputDir
}

$chromePort = Get-EnvValue -Name "A11Y_CHROME_PORT" -Default "9222"
if ($chromePort) {
  $params.ChromePort = [int]$chromePort
}

$motorTabSteps = Get-EnvValue -Name "A11Y_MOTOR_TAB_STEPS"
if ($motorTabSteps) {
  $params.MotorTabSteps = [int]$motorTabSteps
}

if ($StartChrome) {
  $params.StartChrome = $true
}

& (Join-Path $root "scripts\run_human_a11y_report.ps1") @params
