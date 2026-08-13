$repoRoot = Split-Path $PSScriptRoot -Parent
$dist = Join-Path $repoRoot 'dist'
$skillsRoot = Join-Path $repoRoot 'skills'
$bundleSkillNames = @('accessimind-accessible-ui-agent-skill')
$bundlePaths = @()
$zipPath = Join-Path $dist 'accessimind-skill.zip'

foreach ($skillName in $bundleSkillNames) {
  $source = Join-Path $skillsRoot $skillName
  if (-not (Test-Path $source)) {
    throw "Skill source not found: $source"
  }
  $bundlePaths += $source
}

New-Item -ItemType Directory -Force -Path $dist | Out-Null
if (Test-Path $zipPath) {
  Remove-Item $zipPath -Force
}
Compress-Archive -Path $bundlePaths -DestinationPath $zipPath -Force
Write-Host "Created package: $zipPath"
