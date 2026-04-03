# Usage Guide

Current version: `1.0.0.3`

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
2. `playwright` for deterministic browser runtime evidence (keyboard, focus, DOM transitions).
3. `senior-developer-20y` for architecture rigor, regression control, and production release hardening.

This ensures the workflow is not checklist-only and can support production-grade delivery decisions.

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
