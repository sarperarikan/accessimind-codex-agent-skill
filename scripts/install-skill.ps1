$skillsRoot = Join-Path $PSScriptRoot '..\skills'
$targetRoot = Join-Path $HOME '.codex\skills'

$bundleSkillNames = @(
  'accessimind-accessible-ui-agent-skill',
  'playwright',
  'senior-developer-20y',
  'nvda-portable-a11y-audit'
)

if (-not (Test-Path $skillsRoot)) {
  throw "Skills source root not found: $skillsRoot"
}

New-Item -ItemType Directory -Force -Path $targetRoot | Out-Null

foreach ($skillName in $bundleSkillNames) {
  $source = Join-Path $skillsRoot $skillName
  $target = Join-Path $targetRoot $skillName

  if (-not (Test-Path $source)) {
    throw "Skill source not found: $source"
  }

  if (Test-Path $target) {
    Remove-Item -Recurse -Force $target
  }

  Copy-Item -Path $source -Destination $targetRoot -Recurse -Force
  Write-Host "Installed skill to $target"
}

Write-Host "Installed AccessiMind integrated bundle: $($bundleSkillNames -join ', ')"
