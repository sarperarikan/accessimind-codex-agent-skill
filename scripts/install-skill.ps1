$source = Join-Path $PSScriptRoot '..\skills\accessimind-accessible-ui-agent-skill'
$targetRoot = Join-Path $HOME '.codex\skills'
$target = Join-Path $targetRoot 'accessimind-accessible-ui-agent-skill'
if (-not (Test-Path $source)) {
  throw "Skill source not found: $source"
}
New-Item -ItemType Directory -Force -Path $targetRoot | Out-Null
if (Test-Path $target) {
  Remove-Item -Recurse -Force $target
}
Copy-Item -Path $source -Destination $targetRoot -Recurse -Force
Write-Host "Installed skill to $target"
