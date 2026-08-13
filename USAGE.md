# AccessiMind usage

## Core skill

Use `$accessimind-accessible-ui-agent-skill` for accessible UI work or evidence-backed review. The skill owns implementation guidance, runtime evidence interpretation, remediation planning, and release gates.

## Evidence harnesses

```powershell
node .\skills\accessimind-accessible-ui-agent-skill\scripts\motor_web_audit.mjs --url https://example.com --focus-steps 160 --out .\motor-web-audit.json
node .\skills\accessimind-accessible-ui-agent-skill\scripts\low_vision_web_audit.mjs --url https://example.com --out .\low-vision-web-audit.json
node .\skills\accessimind-accessible-ui-agent-skill\scripts\nvda_web_audit.mjs --url https://example.com --out .\nvda-web-audit.json
```

`motor_web_audit.mjs` reports confirmed `pointer-reachable-without-keyboard-target` findings only when a visible target passes a pointer trial but lacks a keyboard-operable semantic owner. `pointer-keyboard-parity-undetermined` means the Tab trace was insufficient and must be extended before claiming a defect.

## Journey audits

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
node .\skills\accessimind-accessible-ui-agent-skill\scripts\journey-audit.mjs --journey .\a11y-journey.json --output .\accessibility-journey-report.json
```

The runner scans every reached state with AccessLint. AccessiMind then adds keyboard, focus, visual, and screen-reader evidence; an incomplete transition or unavailable mandatory evidence remains undetermined or fails the production gate.
