# AccessiMind Accessible UI Agent Skill

Current version: `1.0.0.4`

AccessiMind Accessible UI Agent Skill is a shareable Codex skill for building and reviewing production-ready UI with an accessibility-first workflow.

AccessiMind Accessible UI Agent Skill, accessibility-first yaklaşımla production-ready UI geliştirmek ve erişilebilirlik denetimi yapmak için paylaşılabilir bir Codex skill paketidir.

This repository now ships an integrated skill bundle:
- `accessimind-accessible-ui-agent-skill`
- `playwright`
- `senior-developer-20y`
- `nvda-portable-a11y-audit`
- `full-persona-a11y-audit`

It is designed for teams that want a single skill capable of:
- applying WCAG 2.2-oriented implementation rules
- handling both static and dynamic interface behavior
- preserving existing stack choices instead of forcing migrations
- guiding multilingual and enterprise-grade UI architecture
- integrating automated `axe-core` checks where appropriate
- covering web, React, Android, Flutter, and iOS accessibility concerns
- enforcing production-grade delivery gates through integrated runtime evidence and senior engineering risk review
- producing professional accessibility audit reports with table of contents, evidence sections, Jira-ready summaries, and stakeholder-oriented remediation guidance
- collecting real or runtime-backed evidence for screen-reader, low-vision, and motor accessibility checks

Bu paket, tek bir workflow içinde WCAG 2.2 yorumlama, Playwright runtime kanıtı, NVDA destekli ekran okuyucu çıktısı, az gören kullanıcı ölçümleri, motor beceri ölçümleri, profesyonel HTML raporlama ve release gate kararlarını birleştirmek isteyen ekipler için tasarlanmıştır.

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
- `skills/nvda-portable-a11y-audit/`
  Portable NVDA + Playwright audit skill for mandatory live SR evidence and screenshot-based analysis.
- `skills/full-persona-a11y-audit/`
  Combined blind/low-vision/motor persona audit skill with one-command orchestration.
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
$HOME\.codex\skills\nvda-portable-a11y-audit\SKILL.md
$HOME\.codex\skills\full-persona-a11y-audit\SKILL.md
```

## Validate

If Python is available in your environment:

```powershell
python .\scripts\quick_validate.py .\skills\accessimind-accessible-ui-agent-skill
```

The core web-audit harnesses can also be syntax-checked:

```powershell
node --check .\skills\accessimind-accessible-ui-agent-skill\scripts\nvda_web_audit.mjs
node --check .\skills\accessimind-accessible-ui-agent-skill\scripts\low_vision_web_audit.mjs
node --check .\skills\accessimind-accessible-ui-agent-skill\scripts\motor_web_audit.mjs
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
- `Use $accessimind-accessible-ui-agent-skill to audit this carousel with NVDA, low-vision, and motor evidence`
- `Bu sayfayı $accessimind-accessible-ui-agent-skill ile WCAG 2.2, NVDA, az gören ve motor beceri açısından denetle`
- `Swiper bileşeni için profesyonel HTML erişilebilirlik raporu oluştur`

## Documentation

For a detailed bilingual usage guide, see `USAGE.md`.

Detaylı İngilizce ve Türkçe kullanım kılavuzu için `USAGE.md` dosyasına bakın.

## Integrated Workflow

The bundle methodology is:
1. `accessimind-accessible-ui-agent-skill` defines WCAG 2.2 scope, implementation path, and severity.
2. `playwright` captures deterministic runtime evidence for keyboard, focus, and DOM behavior.
3. `nvda-portable-a11y-audit` runs screen-reader evidence using portable NVDA and captures screenshots.
4. `full-persona-a11y-audit` generates blind/low-vision/motor reports in a single run.
5. `senior-developer-20y` hardens architecture, test depth, regression safety, and release readiness.
6. Final decision is emitted through AccessiMind production gates.

## Evidence Harnesses

The main skill includes three browser-oriented evidence harnesses:
- `nvda_web_audit.mjs`: real NVDA + Guidepup speech capture with web-only foreground filtering.
- `low_vision_web_audit.mjs`: viewport, reflow, text-spacing, forced-colors, contrast, focus, clipping, and target-density measurement.
- `motor_web_audit.mjs`: target size, spacing, keyboard trace, pointer actionability, drag/precision candidate, and mobile-touch measurement.

These harnesses are intended to support audit reports. They do not replace human QA, but they prevent unsupported summary-only findings.

## Release Notes

- Current release: `1.0.0.4`
- Changelog: `CHANGELOG.md`
