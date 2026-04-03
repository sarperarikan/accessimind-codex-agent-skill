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

## Report shape rule

For each finding include:
- severity
- WCAG reference
- selector or evidence id
- fix direction
- owner and ETA placeholders for handoff
