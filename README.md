# AccessiMind Accessible UI Agent Skill

Shareable Codex skill package for production-ready UI work with:
- WCAG 2.2-first implementation
- dynamic accessibility support
- axe-core verification workflow
- multilingual architecture
- React, HTML/CSS, Android, Flutter, and iOS guidance
- W3C Techniques routing matrix

## Repo layout

- `skills/accessimind-accessible-ui-agent-skill/`
  Contains the installable Codex skill.
- `scripts/install-skill.ps1`
  Installs the skill into the current user's Codex skills directory.
- `scripts/package-skill.ps1`
  Produces a zip archive for sharing.
- `scripts/quick_validate.py`
  Validates the skill frontmatter.

## Install

PowerShell:

```powershell
.\scripts\install-skill.ps1
```

Manual install:

1. Copy `skills/accessimind-accessible-ui-agent-skill`
2. Paste it into `$HOME\.codex\skills\`

Expected result:

```text
$HOME\.codex\skills\accessimind-accessible-ui-agent-skill\SKILL.md
```

## Validate

```powershell
python .\scripts\quick_validate.py .\skills\accessimind-accessible-ui-agent-skill
```

## Package as zip

```powershell
.\scripts\package-skill.ps1
```

The zip file will be written under `dist/`.

## Suggested trigger phrases

- `Use $accessimind-accessible-ui-agent-skill for this dashboard`
- `Refactor this React screen with $accessimind-accessible-ui-agent-skill`
- `Apply $accessimind-accessible-ui-agent-skill to make this flow WCAG 2.2 ready`
- `Use $accessimind-accessible-ui-agent-skill for Android/Flutter/iOS accessibility review`
