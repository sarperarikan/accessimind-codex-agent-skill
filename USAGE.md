# AccessiMind usage

AccessiMind is distributed as one Codex skill: `$accessimind-accessible-ui-agent-skill`.

## Install

```powershell
.\scripts\install-skill.ps1
```

Restart or refresh Codex after installation, then invoke the skill in a request.

## Evidence harnesses

Run these commands from the project being audited so Node can resolve that project's dependencies.

```powershell
node C:\Users\sarper\.codex\skills\accessimind-accessible-ui-agent-skill\scripts\motor_web_audit.mjs --url https://example.com --focus-steps 160 --out .\motor-web-audit.json
node C:\Users\sarper\.codex\skills\accessimind-accessible-ui-agent-skill\scripts\low_vision_web_audit.mjs --url https://example.com --out .\low-vision-web-audit.json
node C:\Users\sarper\.codex\skills\accessimind-accessible-ui-agent-skill\scripts\nvda_web_audit.mjs --url https://example.com --out .\nvda-web-audit.json
```

`nvda_web_audit.mjs` requires Windows, an installed NVDA runtime, and Guidepup. It does not ship or install NVDA.

## Journey audits

Create a safe, non-destructive journey definition:

```json
{
  "baseUrl": "http://localhost:3000",
  "journeys": [{
    "name": "Guest checkout",
    "steps": [
      { "name": "Browse", "url": "/products" },
      { "name": "Add item", "click": "[data-testid='add-to-cart']" },
      { "name": "Open cart", "click": "a[href='/cart']" }
    ]
  }]
}
```

```powershell
node C:\Users\sarper\.codex\skills\accessimind-accessible-ui-agent-skill\scripts\journey-audit.mjs --journey .\a11y-journey.json --output .\accessibility-journey-report.json
```

The journey runner scans each reached state with AccessLint. Supported actions are `url`, `click`, `fill`, `press`, `waitFor`, and `waitMs`. Do not use it for purchases, messages, deletes, or production-record creation without explicit approval.

## Pointer--keyboard parity

`motor_web_audit.mjs` reports `pointer-reachable-without-keyboard-target` only when a visible pointer-actionable target lacks a keyboard-operable semantic owner. `pointer-keyboard-parity-undetermined` means the Tab trace must be extended before treating the target as a defect.
