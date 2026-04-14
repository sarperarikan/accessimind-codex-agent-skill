# Usage Guide

Current version: `1.0.0.11`

## Overview

AccessiMind Accessible UI Agent Skill is intended for Codex users who want UI work that is:
- accessibility-first
- production-ready
- multilingual by architecture
- respectful of the existing project stack
- suitable for both static and dynamic interfaces

This guide explains how to install, invoke, and use the skill effectively.

## Install the Integrated Skill Bundle

### Option 1: Install with the bundled script

From the repository root:

```powershell
.\scripts\install-skill.ps1
```

### Option 2: Install manually

Copy this folder:

```text
skills/accessimind-accessible-ui-agent-skill
```

Into your Codex skills directory:

```text
$HOME\.codex\skills\
```

After installation, the expected paths are:

```text
$HOME\.codex\skills\accessimind-accessible-ui-agent-skill\SKILL.md
$HOME\.codex\skills\playwright\SKILL.md
$HOME\.codex\skills\senior-developer-20y\SKILL.md
$HOME\.codex\skills\nvda-portable-a11y-audit\SKILL.md
$HOME\.codex\skills\full-persona-a11y-audit\SKILL.md
$HOME\.codex\skills\business-analyst-a11y\SKILL.md
```

## Package the Bundle for Sharing

To create a distributable zip archive:

```powershell
.\scripts\package-skill.ps1
```

The package will be created here:

```text
dist/accessimind-integrated-skill-bundle.zip
```

## Validate the Skill

If Python is available:

```powershell
python .\scripts\quick_validate.py .\skills\accessimind-accessible-ui-agent-skill
```

This validation checks the skill frontmatter and naming rules.

## When to Use This Skill

Use this skill when you want Codex to:
- build or refactor UI in an existing project
- preserve the current stack instead of introducing a new one
- improve accessibility without treating it as an afterthought
- handle dynamic UI states such as dialogs, toasts, overlays, tabs, async loads, and live updates
- design multilingual UI architecture instead of scattering strings inline
- evaluate or implement accessibility for React, HTML/CSS, Android, Flutter, or iOS surfaces

## Integrated Methodology

This repository is now intentionally multi-skill.

Use this execution order:
1. `accessimind-accessible-ui-agent-skill` for WCAG 2.2 interpretation, implementation rules, and severity.
2. `playwright` for deterministic browser runtime evidence with enforced artifact gates (keyboard, focus, DOM transitions).
3. `nvda-portable-a11y-audit` for mandatory live screen-reader evidence and verified screenshot artifacts using portable NVDA.
4. `full-persona-a11y-audit` for one-command blind/low-vision/motor persona coverage.
5. `business-analyst-a11y` for As-Is analysis and Dev/BA/PO action mapping.
6. `senior-developer-20y` for architecture rigor, regression control, and production release hardening.

This ensures the workflow is not checklist-only and can support production-grade delivery decisions.

## Prompt Recipes

Generic prompt starters are available here:

```text
skills/accessimind-accessible-ui-agent-skill/references/prompt-recipes.md
```

Use them when you want a fast starting point for:
- single-page audits
- multi-page audits
- component reviews
- remediation plans

## Local Regression Fixtures

Generic local fixtures are available here:

```text
skills/accessimind-accessible-ui-agent-skill/references/fixtures/
```

Use them when you want repeatable, domain-agnostic checks without relying on live sites.

## Deterministic Runtime Collector

The live audit runners use this helper:

```text
scripts/deterministic_playwright_probe.cjs
```

It opens each target URL in a single Playwright process and collects DOM, scroll, screenshot, focus, and structured element evidence without relying on cross-process CLI session state.

Blind-side spoken output is collected with:

```text
scripts/nvda_speech_probe.py
```

## NVDA Portable Runner

From repository root:

```powershell
.\skills\nvda-portable-a11y-audit\scripts\invoke-nvda-playwright-audit.ps1 -Urls "https://example.com","https://example.com/support","https://example.com/company"
```

This runner uses the repository-local `NVDA/` directory as the default screen-reader runtime and records:
- `spokenPhraseLog`
- `lastSpokenPhrase`
- step-level `events` with action-to-speech mapping

Chrome is mandatory for live-site audits. Use a real Chrome session and attach by CDP when the target site is session-sensitive or bot-protected:

```powershell
.\scripts\start_chrome_a11y_debug.ps1 -Port 9222 -Urls "https://example.com"
.\skills\full-persona-a11y-audit\scripts\invoke-full-persona-audit.ps1 -Urls "https://example.com","https://example.com/support" -CdpUrl "http://127.0.0.1:9222"
```

Generated HTML reports now enforce:
- UTF-8 round-trip validation with fail-fast mojibake detection
- behavior-oriented finding cards that explain what element was reached, what happened, why it violates WCAG 2.2, and what should happen instead
- BA `As-Is` / `To-Be` notes derived from real DOM, focus, and NVDA speech evidence instead of placeholder wording
- exact locator output based on structural DOM context
- issue-level crop images for actionable visual handoff when a target element has a valid visible bounding box

Single-command orchestration for the full human-readable HTML output:

```powershell
.\scripts\run_human_a11y_report.ps1 -Urls "https://example.com","https://example.com/support" -ProjectName "example" -StartChrome
```

OpenClaw-style single-entry orchestration with same-domain discovery and merged summary:

```powershell
.\scripts\run_openclaw_accessmind_audit.ps1 -Url "https://example.com" -MaxPages 3 -StartChrome
```

This wrapper:
- discovers in-scope same-domain pages first
- runs the existing full persona audit flow on the resulting URL set
- preserves the original report outputs
- adds `discovery.json`, `openclaw-summary.md`, and `openclaw-summary.json`

If you already have real Windows NVDA worker evidence, merge it into the final summary:

```powershell
.\scripts\run_openclaw_accessmind_audit.ps1 -Url "https://example.com" -MaxPages 3 -StartChrome -NVDAWorkerJson ".\reports\windows-nvda-worker.json"
```

Discovery only:

```powershell
node .\scripts\accessmind_discover.cjs --url https://example.com --max-pages 3 --output .\reports\example-discovery.json
```

Safe session-assisted inputs:

```powershell
.\skills\nvda-portable-a11y-audit\scripts\invoke-nvda-playwright-audit.ps1 -Urls "https://example.com" -StorageStatePath ".\session\state.json"
.\skills\nvda-portable-a11y-audit\scripts\invoke-nvda-playwright-audit.ps1 -Urls "https://example.com" -CdpUrl "http://127.0.0.1:9222"
```

To collect NVDA evidence while you manually navigate the page, enable manual session capture:

```powershell
.\skills\nvda-portable-a11y-audit\scripts\invoke-nvda-playwright-audit.ps1 -Urls "https://example.com" -CdpUrl "http://127.0.0.1:9222" -ManualSessionCapture -ManualSessionSeconds 120
```

This preserves the normal automated blind scan and also writes a per-page `speech-session.json` log plus a manual-session section in `summary.md`.

These inputs are intended for authorized user sessions only. The runner does not bypass access controls; it detects rendered barriers and instructs you to rerun with a legitimate session when required.

## Windows NVDA Worker Merge

Use the local guide here:

```text
NVDA-WINDOWS-WORKER.md
```

The merge layer expects a simple JSON payload with `syncedAt`, `sessionCount`, and per-session URL/speech evidence. The audit can still run without this file, but blind persona conclusions remain heuristic unless real screen-reader evidence is attached.

## Full Persona Runner

From repository root:

```powershell
.\skills\full-persona-a11y-audit\scripts\invoke-full-persona-audit.ps1 -Urls "https://example.com","https://example.com/support","https://example.com/company"
```

This produces:
- `blind.md`
- `low-vision.md`
- `motor.md`
- `summary.md`
- `summary.json`
- `index.html` (UTF-8 and accessible with table of contents)

Mandatory flow and integrity rules:
- Cookie dialog must be evaluated first, then accepted, then scanning restarts from top-of-page.
- Reports must be UTF-8 safe (BOM for generated artifacts) and contain no mojibake.
- Reports must be detailed; short-form output is not accepted.

## What the Skill Optimizes For

The skill pushes Codex toward:
- semantic structure first
- native controls before custom ARIA-heavy abstractions
- WCAG 2.2-aware implementation
- stack-aware UI changes
- design consistency
- dynamic accessibility behavior
- explicit verification and residual-risk reporting

## How the Skill Chooses the Technology Path

The skill inspects the local project first. It looks at files such as:
- `package.json`
- `tsconfig.json`
- lockfiles
- app entry files
- component directories
- template directories
- browser extension files
- Android modules
- Flutter modules
- iOS modules

Based on what it finds, it prefers the least invasive path:
- stay in React if the project is already React
- stay in static HTML/CSS/JS if the project is not React-based
- preserve generated HTML flows if the UI is server-generated
- respect extension runtime constraints
- reuse existing accessibility tooling when present

## Accessibility Scope

The skill is not limited to static markup. It also covers dynamic and stateful behavior, including:
- loading states
- validation states
- success and error states
- dialogs and drawers
- tabs and accordions
- popovers and menus
- live region announcements
- infinite scroll and feeds
- sorting, filtering, and table updates
- motion and reduced-motion behavior
- focus preservation during DOM changes

## Multilingual and Localization Support

The skill treats localization as part of architecture.

It expects Codex to:
- centralize strings
- support locale, language, and direction
- set `lang` and `dir` correctly
- avoid fragile string concatenation
- handle text expansion
- account for RTL languages
- account for CJK layouts
- keep runtime status and validation text localized

## Accessibility Verification Strategy

The skill uses multiple layers of verification:

### 1. Structural implementation review

Codex is expected to check:
- semantics
- labels
- focus behavior
- keyboard access
- contrast-sensitive decisions
- naming and state exposure

### 2. `axe-core` verification

Where feasible, the skill expects Codex to:
- use existing browser-based audit flows
- run scans on rendered states, not only source markup
- check dynamic states, not only first render
- treat `violations` as defects or explicitly documented exceptions
- treat `incomplete` results as manual review items

### 3. Manual review reporting

The skill expects Codex to report:
- what was verified
- which dynamic states were tested
- whether `axe-core` was run or wired
- what still requires manual review

## Platform-Specific Coverage

### Web / HTML / CSS

The skill prefers:
- semantic HTML
- progressive enhancement
- CSS custom properties for tokens
- accessible focus indicators
- durable responsive behavior

### React

The skill expects:
- semantic JSX
- `React.Fragment` when wrappers would harm semantics
- correct `htmlFor` usage
- accessible rerender and focus behavior
- avoidance of pointer-only interaction patterns

### Android

The skill expects:
- platform widgets where possible
- meaningful labels and descriptions
- accessible alternatives for custom gestures
- non-color status cues
- dynamic state verification in Views or Compose

### Flutter

The skill expects:
- semantics-aware widget usage
- 48x48 logical pixel targets
- screen reader testing awareness
- large text scale support
- undo-friendly critical actions where feasible

### iOS

The skill expects:
- built-in accessible controls first
- correct labels, values, traits, and hints
- VoiceOver-aware focus flow
- Accessibility Inspector consideration
- appropriate platform accessibility notifications

## How to Prompt Codex with This Skill

Effective prompt examples:

```text
Use $accessimind-accessible-ui-agent-skill to refactor this dashboard for WCAG 2.2 and multilingual support.
```

```text
Use $accessimind-accessible-ui-agent-skill to improve this React modal flow and verify dynamic accessibility behavior.
```

```text
Use $accessimind-accessible-ui-agent-skill to review this Android screen for accessibility regressions.
```

```text
Use $accessimind-accessible-ui-agent-skill to make this Flutter form production-ready and accessible.
```

```text
Use $accessimind-accessible-ui-agent-skill to audit this iOS SwiftUI flow for VoiceOver and state-change behavior.
```

## Recommended Working Pattern

For best results, ask Codex to:
1. inspect the current stack first
2. explain the chosen implementation path briefly
3. make the actual UI changes
4. call out WCAG-sensitive decisions
5. run or wire `axe-core` if feasible
6. summarize verified and unverified areas

## Included Reference Families

The skill routes work through these guidance families:
- WCAG 2.2
- W3C WCAG Techniques
- WAI-ARIA Authoring Practices
- `axe-core`
- React accessibility guidance
- Android accessibility guidance
- Flutter accessibility guidance
- Apple accessibility guidance

## Limitations

This skill improves implementation quality and verification discipline, but it does not replace:
- legal review
- full assistive-technology QA
- user testing with disabled users
- platform-specific certification or compliance processes

## Files You Will Usually Care About

- `skills/accessimind-accessible-ui-agent-skill/SKILL.md`
- `skills/accessimind-accessible-ui-agent-skill/references/official-sources.md`
- `skills/accessimind-accessible-ui-agent-skill/agents/openai.yaml`

## License and Reuse

Review the repository license and your organization's policy before redistributing the skill in packaged form.
