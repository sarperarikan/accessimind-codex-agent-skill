# AccessiMind Accessible UI Agent Skill

Current version: `1.0.0.13`

AccessiMind Accessible UI Agent Skill is a shareable Codex skill for building and reviewing production-ready UI with an accessibility-first workflow.

This repository now ships an integrated skill bundle:
- `accessimind-accessible-ui-agent-skill`
- `playwright`
- `senior-developer-20y`
- `nvda-portable-a11y-audit`
- `full-persona-a11y-audit`
- `business-analyst-a11y`

It is designed for teams that want a single skill capable of:
- applying WCAG 2.2-oriented implementation rules
- handling both static and dynamic interface behavior
- preserving existing stack choices instead of forcing migrations
- guiding multilingual and enterprise-grade UI architecture
- integrating automated `axe-core` checks where appropriate
- covering web, React, Android, Flutter, and iOS accessibility concerns
- enforcing production-grade delivery gates through deterministic runtime evidence and senior engineering risk review
- remaining reusable across unrelated domains instead of being tailored to a single site
- defaulting OpenClaw-style audits to real Chrome, rendered DOM, interactive traversal, and merged persona reporting

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
  Portable NVDA + Playwright audit skill for mandatory live SR evidence under a deterministic evidence gate.
- `skills/full-persona-a11y-audit/`
  Combined blind/low-vision/motor persona audit skill with one-command orchestration.
- `skills/business-analyst-a11y/`
  As-Is business analysis sub-skill that converts findings into Dev/BA/PO action plans.
- `skills/INTEGRATION.md`
  Methodology and execution order for integrated skill usage.
- `skills/accessimind-accessible-ui-agent-skill/SKILL.md`
  The core skill instructions and workflow.
- `skills/accessimind-accessible-ui-agent-skill/references/official-sources.md`
  Official standards and platform guidance used by the skill.
- `starter-prompts.md`
  Turkish starter prompts that users can copy, replace URLs in, and use directly for accessibility audits.
- `skills/accessimind-accessible-ui-agent-skill/references/prompt-recipes.md`
  Reusable generic prompt starters for common audit tasks.
- `skills/accessimind-accessible-ui-agent-skill/references/fixtures/`
  Generic local HTML fixtures for repeatable regression checks.
- `skills/accessimind-accessible-ui-agent-skill/agents/openai.yaml`
  UI-facing metadata for the skill.
- `scripts/install-skill.ps1`
  Installs the skill into the current user's Codex skills directory.
- `scripts/package-skill.ps1`
  Creates a zip package for sharing.
- `scripts/deterministic_cdp_probe.cjs`
  Chrome CDP-native evidence collector used by deterministic audit runners.
- `scripts/nvda_speech_probe.py`
  Speech Viewer collector used to capture spoken phrases and step-level NVDA interaction traces.
- `scripts/langchain_access_surface_analyzer.py`
  LangChain-based classifier for access barriers and safe acquisition recommendations.
- `scripts/langchain_a11y_commentary.py`
  LangChain-based Turkish commentary generator for executive and page-level accessibility report notes.
- `scripts/start_chrome_a11y_debug.ps1`
  Chrome-first remote-debug launcher for attached live audits.
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
$HOME\.codex\skills\business-analyst-a11y\SKILL.md
```

## Validate

If Python is available in your environment:

```powershell
python .\scripts\quick_validate.py .\skills\accessimind-accessible-ui-agent-skill

## OpenClaw Audit Flow

The repository now includes a single-entry audit wrapper for OpenClaw-style usage:

```powershell
.\scripts\run_openclaw_accessmind_audit.ps1 -Url "https://example.com" -MaxPages 3 -StartChrome
```

What it does:
- discovers same-domain pages unless `-RootOnly` is set
- runs the existing human-readable persona audit on the discovered URLs
- writes `discovery.json`
- merges final results into `openclaw-summary.md` and `openclaw-summary.json`

Package scripts:

```powershell
npm run a11y:discover -- --url https://example.com --max-pages 3
npm run a11y:audit:openclaw -- -Url "https://example.com" -MaxPages 3 -StartChrome
```

If you have a Windows-side real NVDA worker output, attach it during merge:

```powershell
.\scripts\run_openclaw_accessmind_audit.ps1 -Url "https://example.com" -MaxPages 3 -StartChrome -NVDAWorkerJson ".\reports\windows-nvda-worker.json"
```
```

## Run Accessibility Audit

You can now trigger the human-readable accessibility audit through `npm`.

PowerShell example:

```powershell
$env:A11Y_URLS = "https://example.com,https://example.com/support"
npm run a11y:audit:chrome
```

Optional environment variables:
- `A11Y_PROJECT_NAME`
- `A11Y_OUTPUT_DIR`
- `A11Y_CHROME_PORT`
- `A11Y_MOTOR_TAB_STEPS`

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
For copy-paste Turkish starter prompts, see `starter-prompts.md`.
For reusable prompt starters and local fixtures, see `skills/accessimind-accessible-ui-agent-skill/references/`.

## Integrated Workflow

The bundle methodology is:
1. `accessimind-accessible-ui-agent-skill` defines WCAG 2.2 scope, implementation path, and severity.
2. Chrome CDP-native collector captures deterministic runtime evidence for keyboard, focus, DOM behavior, accessibility tree, and artifact gating.
3. The deterministic collector also captures `axe-core` rule violations and screenshot-based vision evidence.
4. `nvda-portable-a11y-audit` runs screen-reader evidence using portable NVDA, captures spoken phrases, and is mandatory for the production audit path.
5. `full-persona-a11y-audit` generates blind/vision/motor evidence in a single report pipeline.
6. `langchain_a11y_commentary.py` converts the resulting summary into Turkish risk commentary and action framing for the final HTML report.
5. `business-analyst-a11y` enriches each finding with As-Is/To-Be and role-based action notes.
6. `senior-developer-20y` hardens architecture, test depth, regression safety, and release readiness.
7. Final decision is emitted through AccessiMind production gates.

## Release Notes

- Current release: `1.0.0.9`
- Changelog: `CHANGELOG.md`
