# AccessiMind Accessible UI Agent Skill

Current version: `1.1.0`

AccessiMind Accessible UI Agent Skill is a shareable Codex skill for building and reviewing production-ready UI with an accessibility-first workflow.

This repository now ships an integrated skill bundle:
- `accessimind-accessible-ui-agent-skill`
- `playwright`
- `senior-developer-20y`

It is designed for teams that want a single skill capable of:
- applying WCAG 2.2-oriented implementation rules
- handling both static and dynamic interface behavior
- preserving existing stack choices instead of forcing migrations
- guiding multilingual and enterprise-grade UI architecture
- integrating automated `axe-core` checks where appropriate
- covering web, React, Android, Flutter, and iOS accessibility concerns
- enforcing production-grade delivery gates through integrated runtime evidence and senior engineering risk review

## What This Skill Does

This skill helps Codex:
- detect the current project stack before making UI decisions
- prefer semantic HTML and platform-native controls first
- improve consistency through tokens, spacing, type, states, and component rules
- address dynamic accessibility concerns such as dialogs, live regions, async updates, rerenders, feeds, and overlays
- route implementation work through W3C WCAG Techniques, WAI-ARIA APG patterns, and platform accessibility guidance
- verify UI changes with `axe-core` when feasible and explicitly call out remaining manual review items

## Platform Coverage

The skill currently includes guidance for:
- HTML / CSS
- React
- Android
- Flutter
- iOS

## Repository Layout

- `skills/accessimind-accessible-ui-agent-skill/`
  The installable Codex skill folder.
- `skills/playwright/`
  Integrated runtime browser automation and keyboard/DOM evidence skill.
- `skills/senior-developer-20y/`
  Integrated production engineering and risk-hardening skill.
- `skills/INTEGRATION.md`
  Methodology and execution order for integrated skill usage.
- `skills/accessimind-accessible-ui-agent-skill/SKILL.md`
  The core skill instructions and workflow.
- `skills/accessimind-accessible-ui-agent-skill/references/official-sources.md`
  Official standards and platform guidance used by the skill.
- `skills/accessimind-accessible-ui-agent-skill/agents/openai.yaml`
  UI-facing metadata for the skill.
- `scripts/install-skill.ps1`
  Installs the skill into the current user's Codex skills directory.
- `scripts/package-skill.ps1`
  Creates a zip package for sharing.
- `scripts/quick_validate.py`
  Validates the skill frontmatter and basic structure.
- `USAGE.md`
  Detailed English usage instructions.

## Install

### PowerShell

```powershell
.\scripts\install-skill.ps1
```

### Manual Install

1. Copy `skills/accessimind-accessible-ui-agent-skill`
2. Paste it into `$HOME\.codex\skills\`

Expected result:

```text
$HOME\.codex\skills\accessimind-accessible-ui-agent-skill\SKILL.md
$HOME\.codex\skills\playwright\SKILL.md
$HOME\.codex\skills\senior-developer-20y\SKILL.md
```

## Validate

If Python is available in your environment:

```powershell
python .\scripts\quick_validate.py .\skills\accessimind-accessible-ui-agent-skill
```

## Package

```powershell
.\scripts\package-skill.ps1
```

The zip artifact will be written to `dist/accessimind-integrated-skill-bundle.zip`.

## How To Invoke the Skill

Suggested trigger phrases:
- `Use $accessimind-accessible-ui-agent-skill for this dashboard`
- `Refactor this React screen with $accessimind-accessible-ui-agent-skill`
- `Apply $accessimind-accessible-ui-agent-skill to make this flow WCAG 2.2 ready`
- `Use $accessimind-accessible-ui-agent-skill for Android/Flutter/iOS accessibility review`

## Documentation

For a more detailed English usage guide, see `USAGE.md`.

## Integrated Workflow

The bundle methodology is:
1. `accessimind-accessible-ui-agent-skill` defines WCAG 2.2 scope, implementation path, and severity.
2. `playwright` captures deterministic runtime evidence for keyboard, focus, and DOM behavior.
3. `senior-developer-20y` hardens architecture, test depth, regression safety, and release readiness.
4. Final decision is emitted through AccessiMind production gates.

## Release Notes

- Current release: `1.1.0`
- Changelog: `CHANGELOG.md`
