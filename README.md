# AccessiMind Codex Agent Skill

Version: `1.1.0`

AccessiMind is a single, production-oriented Codex skill for accessible UI implementation and WCAG 2.2 evidence collection. It combines automated, keyboard, screen-reader, low-vision, motor, and journey-state checks without requiring separate companion skills.

## Included capabilities

- Semantic, multilingual UI implementation and WCAG 2.2 review
- Keyboard, focus, reflow, contrast, forced-colors, and reduced-motion evidence
- NVDA-assisted evidence collection when the local runtime is available
- State-by-state journey audits for sign-in, search, checkout, booking, onboarding, and forms
- Detection of targets that accept pointer interaction but lack a keyboard-operable target
- Release gates: `PASS`, `PASS_WITH_RISK`, or `FAIL`

## Install

```powershell
.\scripts\install-skill.ps1
```

This installs only `accessimind-accessible-ui-agent-skill` under `$HOME\.codex\skills`.

## Validate

```powershell
python .\scripts\quick_validate.py .\skills\accessimind-accessible-ui-agent-skill
node --check .\skills\accessimind-accessible-ui-agent-skill\scripts\nvda_web_audit.mjs
node --check .\skills\accessimind-accessible-ui-agent-skill\scripts\low_vision_web_audit.mjs
node --check .\skills\accessimind-accessible-ui-agent-skill\scripts\motor_web_audit.mjs
node --check .\skills\accessimind-accessible-ui-agent-skill\scripts\journey-audit.mjs
```

## Journey audit

Create `a11y-journey.json` with a `baseUrl`, named journeys, and ordered `url`, `click`, `fill`, `press`, `waitFor`, or `waitMs` steps. Do not include irreversible production actions without explicit approval.

```powershell
node .\skills\accessimind-accessible-ui-agent-skill\scripts\journey-audit.mjs `
  --journey .\a11y-journey.json `
  --output .\accessibility-journey-report.json
```

Invoke it in Codex with `$accessimind-accessible-ui-agent-skill ile checkout yolculuğunu denetle`.

See [USAGE.md](USAGE.md) for the audit commands and report interpretation.
