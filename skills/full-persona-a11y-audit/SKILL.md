---
name: full-persona-a11y-audit
description: Use when audits must cover blind screen-reader flow, low-vision zoom/contrast/reflow checks, and motor keyboard traversal checks in one deterministic run.
---

# Full Persona A11y Audit

Use this skill for production-grade persona coverage in one command.

## Personas

- Blind / screen-reader-first
- Low-vision
- Motor-limited / keyboard-only

## What it runs

1. Blind track:
- Uses `nvda-portable-a11y-audit` pipeline for live NVDA-backed evidence.

2. Low-vision track:
- Zoom at 200% and 400%.
- Reflow checks.
- Screenshot capture for each zoom level.
- Focus visibility sampling.

3. Motor track:
- Long keyboard traversal session (`Tab`, optional reverse traversal).
- Focus loop and trap detection.
- Keyboard completion risk summary.

## Default runner

```powershell
.\skills\full-persona-a11y-audit\scripts\invoke-full-persona-audit.ps1 -Urls "https://example.com"
```

## Required outputs

- `blind.md`
- `low-vision.md`
- `motor.md`
- `summary.md`
- `summary.json`
- `index.html` (UTF-8, accessible table of contents, detailed navigation)

## Report shape rule

For each finding include:
- severity
- WCAG reference
- selector or evidence id
- fix direction
- owner and ETA placeholders for handoff

## Folder and naming contract

- Output path must be: `reports/<project-name>-<YYYY-MM-DD>/`
- Each scanned page must have its own folder under `pages/`.
- Main report file must be `index.html`.

## Absolute quality gates (mandatory)

- Character encoding must be valid UTF-8 (prefer UTF-8 with BOM for Windows compatibility).
- No mojibake or broken characters are allowed in report output.
- Report must not be short-form; include detailed per-page and per-element analysis.
- Every scanned page must be traversed from top to bottom and fully reported.

## Cookie dialog workflow (mandatory)

For each page:
1. Detect and evaluate cookie dialog first.
2. Record findings for cookie dialog itself.
3. Accept cookie dialog.
4. Return to top of page.
5. Start evidence collection from top.

## Element coverage contract

- Report must include head-to-tail element inventory for each page.
- For each element, include:
  - blind perception
  - low-vision perception
  - motor perception
  - navigation context and improvement direction

### Deep coverage extension

- Do not stop at first-screen content when the page continues below the fold.
- Scroll and collect additional checkpoints so promo rails, sticky helpers, footer utilities, and late-rendered modules are represented in the report.
- Include a coverage summary that tells how many total elements and how many interactive elements were traversed per page.

## Coverage-first report tone

- Present rerun needs as `additional coverage recommended`, not as a dedicated limitations section.
- Keep the visible report focused on findings, evidence breadth, and remediation direction.

## Business analysis integration

Use `business-analyst-a11y` to enrich each finding with:
- As-Is
- To-Be
- Developer action
- BA action
- PO action
