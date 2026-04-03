$ErrorActionPreference = "Stop"

$npxCmdPath = "C:\Program Files\nodejs\npx.cmd"
if (-not (Test-Path $npxCmdPath)) {
  $npx = Get-Command npx.cmd -ErrorAction SilentlyContinue
  if ($npx) {
    $npxCmdPath = $npx.Source
  }
}

if (-not (Test-Path $npxCmdPath)) {
  Write-Error "npx is required but was not found on PATH."
}

$baseArgs = @("--yes", "--package", "@playwright/cli", "playwright-cli")

$hasSessionFlag = $false
foreach ($arg in $args) {
  if ($arg -eq "--session" -or $arg -like "--session=*") {
    $hasSessionFlag = $true
    break
  }
}

if (-not $hasSessionFlag -and $env:PLAYWRIGHT_CLI_SESSION) {
  $baseArgs += @("--session", $env:PLAYWRIGHT_CLI_SESSION)
}

$baseArgs += $args

& $npxCmdPath @baseArgs
exit $LASTEXITCODE
