# AccessiMind Codex Agent Skill

**AccessiMind** is a single Codex skill for building and auditing accessible web UI. It combines implementation guidance with reproducible WCAG 2.2 evidence for real product journeys—without requiring separate Playwright, NVDA, or persona skills.

Current version: `1.1.1`

## What it covers

- Production-oriented HTML, CSS, and React accessibility work
- Semantic structure, accessible names, ARIA states, forms, dialogs, live regions, and localization-aware UI
- Keyboard order, focus visibility, reflow, text spacing, contrast, forced colors, reduced motion, and target size
- NVDA-assisted evidence collection when NVDA and Guidepup are installed locally
- Journey audits for sign-in, search, filtering, cart, checkout, booking, onboarding, and multi-step forms
- Pointer–keyboard parity: highlights visible targets that accept a pointer click but lack a keyboard-operable semantic target
- Evidence-backed release gates: `PASS`, `PASS_WITH_RISK`, or `FAIL`

Automated checks accelerate the audit; they do not replace real assistive-technology users or human usability review.

## Install

From the repository root:

```powershell
.\scripts\install-skill.ps1
```

The installer copies one folder to your Codex skills directory:

```text
$HOME\.codex\skills\accessimind-accessible-ui-agent-skill\
```

The repository intentionally does not bundle a portable NVDA runtime. For NVDA evidence, install NVDA on the Windows audit machine and set up Guidepup in the audited project.

## Use in Codex

Examples:

```text
Use $accessimind-accessible-ui-agent-skill to audit this checkout flow for WCAG 2.2.
Use $accessimind-accessible-ui-agent-skill to find controls reachable by mouse but not keyboard.
Use $accessimind-accessible-ui-agent-skill to review this React modal and propose verified fixes.
```

## Evidence harnesses

The bundled scripts live in `skills/accessimind-accessible-ui-agent-skill/scripts/`.

| Script | Purpose |
| --- | --- |
| `nvda_web_audit.mjs` | Captures NVDA-assisted browser evidence when the local runtime is available. |
| `low_vision_web_audit.mjs` | Measures reflow, text spacing, forced colors, contrast, focus, clipping, and density. |
| `motor_web_audit.mjs` | Collects keyboard traces, pointer actionability, target size/spacing, drag alternatives, and pointer–keyboard parity. |
| `journey-audit.mjs` | Executes declared UI journeys and runs AccessLint at every reached state. |

Validate the scripts after installation:

```powershell
python .\scripts\quick_validate.py .\skills\accessimind-accessible-ui-agent-skill
node --check .\skills\accessimind-accessible-ui-agent-skill\scripts\nvda_web_audit.mjs
node --check .\skills\accessimind-accessible-ui-agent-skill\scripts\low_vision_web_audit.mjs
node --check .\skills\accessimind-accessible-ui-agent-skill\scripts\motor_web_audit.mjs
node --check .\skills\accessimind-accessible-ui-agent-skill\scripts\journey-audit.mjs
```

## Journey audits

Define safe, non-destructive UI states in `a11y-journey.json`:

```json
{
  "baseUrl": "http://localhost:3000",
  "journeys": [
    {
      "name": "Guest checkout",
      "steps": [
        { "name": "Browse", "url": "/products" },
        { "name": "Add item", "click": "[data-testid='add-to-cart']" },
        { "name": "Open cart", "click": "a[href='/cart']" }
      ]
    }
  ]
}
```

Run it with:

```powershell
node .\skills\accessimind-accessible-ui-agent-skill\scripts\journey-audit.mjs `
  --journey .\a11y-journey.json `
  --output .\accessibility-journey-report.json
```

Supported step actions are `url`, `click`, `fill`, `press`, `waitFor`, and `waitMs`. Do not include purchases, sends, deletes, or production-record creation without explicit approval.

## Pointer–keyboard parity

Run the motor audit with a Tab budget appropriate to the page:

```powershell
node .\skills\accessimind-accessible-ui-agent-skill\scripts\motor_web_audit.mjs `
  --url https://example.com `
  --focus-steps 160 `
  --out .\motor-web-audit.json
```

`pointer-reachable-without-keyboard-target` is a confirmed candidate when a visible target accepts a pointer trial but has no keyboard-operable semantic owner. `pointer-keyboard-parity-undetermined` means the recorded Tab trace is not long enough to prove a failure.

## Project structure

```text
skills/accessimind-accessible-ui-agent-skill/
├── SKILL.md                 # Codex workflow and production gates
├── agents/openai.yaml       # Codex UI metadata
├── references/              # WCAG, journey, and parity guidance
└── scripts/                 # NVDA, low-vision, motor, and journey evidence tools
```

For command details and report interpretation, see [USAGE.md](USAGE.md). Changes are tracked in [CHANGELOG.md](CHANGELOG.md).
