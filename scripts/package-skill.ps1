$repoRoot = Split-Path $PSScriptRoot -Parent
$dist = Join-Path $repoRoot 'dist'
$source = Join-Path $repoRoot 'skills\accessimind-accessible-ui-agent-skill'
$zipPath = Join-Path $dist 'accessimind-accessible-ui-agent-skill.zip'
if (-not (Test-Path $source)) {
  throw "Skill source not found: $source"
}
New-Item -ItemType Directory -Force -Path $dist | Out-Null
if (Test-Path $zipPath) {
  Remove-Item $zipPath -Force
}
Compress-Archive -Path $source -DestinationPath $zipPath -Force
Write-Host "Created package: $zipPath"
