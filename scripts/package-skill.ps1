$repoRoot = Split-Path $PSScriptRoot -Parent
$dist = Join-Path $repoRoot 'dist'
$skillsRoot = Join-Path $repoRoot 'skills'
$bundleSkillNames = @(
  'accessimind-accessible-ui-agent-skill',
  'playwright',
  'senior-developer-20y'
)
$bundlePaths = @()
$integrationGuide = Join-Path $skillsRoot 'INTEGRATION.md'
$zipPath = Join-Path $dist 'accessimind-integrated-skill-bundle.zip'

foreach ($skillName in $bundleSkillNames) {
  $source = Join-Path $skillsRoot $skillName
  if (-not (Test-Path $source)) {
    throw "Skill source not found: $source"
  }
  $bundlePaths += $source
}

if (-not (Test-Path $integrationGuide)) {
  throw "Integration guide not found: $integrationGuide"
}
$bundlePaths += $integrationGuide

New-Item -ItemType Directory -Force -Path $dist | Out-Null
if (Test-Path $zipPath) {
  Remove-Item $zipPath -Force
}
Compress-Archive -Path $bundlePaths -DestinationPath $zipPath -Force
Write-Host "Created package: $zipPath"
