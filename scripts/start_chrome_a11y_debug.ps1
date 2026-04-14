param(
  [int]$Port = 9222,
  [string]$ProfileDir = "",
  [string[]]$Urls = @()
)

$ErrorActionPreference = "Stop"

function Get-ChromePath {
  $candidates = @(
    "C:\Program Files\Google\Chrome\Application\chrome.exe",
    "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
  )
  foreach ($candidate in $candidates) {
    if (Test-Path $candidate) { return $candidate }
  }
  throw "Google Chrome executable not found."
}

if (-not $ProfileDir) {
  $ProfileDir = Join-Path $env:TEMP "chrome-a11y-debug"
}
New-Item -ItemType Directory -Force -Path $ProfileDir | Out-Null
$resolvedProfileDir = (Resolve-Path $ProfileDir).Path

$chromePath = Get-ChromePath
$args = @(
  "--remote-debugging-port=$Port",
  "--remote-debugging-address=127.0.0.1",
  "--user-data-dir=$resolvedProfileDir",
  "--no-first-run",
  "--no-default-browser-check"
)

if ($Urls -and $Urls.Count -gt 0) {
  $args += $Urls
} else {
  $args += "about:blank"
}

$proc = Start-Process -FilePath $chromePath -ArgumentList $args -PassThru

Write-Host "Chrome started."
Write-Host "PID: $($proc.Id)"
Write-Host "CDP URL: http://127.0.0.1:$Port"
Write-Host "Profile: $resolvedProfileDir"
