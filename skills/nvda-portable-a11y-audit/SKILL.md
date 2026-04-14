---
name: nvda-portable-a11y-audit
description: Use when accessibility audits must include real screen-reader validation on Windows using the repository portable NVDA copy, plus screenshot-based visual evidence and DOM/focus traces.
---

# NVDA Portable A11y Audit

Use this skill when the task requires mandatory screen-reader evidence on Windows.

This skill is designed to work with the portable NVDA folder in this repository:
- `NVDA/`

## Objective

Produce deterministic audit evidence with:
- live NVDA runtime session
- keyboard focus trail
- per-page screenshots
- DOM issue summary
- NVDA Browse Mode navigation model outputs

## Required workflow

1. Verify NVDA portable executable exists in `NVDA/`.
2. Verify Playwright wrapper exists and is runnable.
3. Start NVDA from repository-local portable copy.
4. Navigate requested URLs with Playwright.
5. Evaluate cookie dialog first, then accept it.
6. Return to top of page.
7. Capture screenshots and blind-side evidence for each URL.
8. Stop NVDA cleanly.
9. Produce JSON and Markdown summary artifacts.

## NVDA user guide alignment (required)

Use the repository NVDA user guide as the navigation model source:
- `NVDA/documentation/en/userGuide.html`

Blind-side scan must align to:
- Browse Mode
- Single letter navigation categories:
  - `h` / `1..9` (headings)
  - `k` (links)
  - `f` / `e` (form fields)
  - `b` (buttons)
  - `d` (landmarks)
  - `g` (graphics)
- Elements List model (`NVDA+F7`) for links, headings, form fields, buttons, landmarks

## Default runner

```powershell
.\skills\nvda-portable-a11y-audit\scripts\invoke-nvda-playwright-audit.ps1 -Urls "https://example.com"
```

## Output contract

The script must produce:
- `summary.json`
- `summary.md`
- page screenshots in the report folder
- per-page blind model data (`blind-page.json`)
- optional per-page manual NVDA session logs (`speech-session.json`) when session capture is enabled

It should also preserve deeper browse-mode coverage by reporting:
- total scanned elements
- total interactive elements
- total headings, links, buttons, form fields, landmarks, and graphics
- evidence from beyond the initial viewport when the page contains more content
- spoken changes collected while the user manually navigates the page during an active NVDA session window

## Absolute quality gates (mandatory)

- Character encoding must be valid UTF-8 (prefer UTF-8 with BOM for Windows compatibility).
- No mojibake or broken characters are allowed in report output.
- Reports must be detailed and not short-form.
- Page content must be fully scanned from top to bottom.

## Guardrails

- Never claim NVDA evidence unless NVDA process was started successfully.
- If NVDA cannot start, mark the run as blocked.
- Keep URLs explicit and in-scope.

## Coverage-first wording

- Keep final user-facing output centered on observed evidence and next-pass coverage targets.
- Avoid a dedicated limitations section unless explicitly requested by the user.

## Recommended next step

After NVDA evidence is captured, run `full-persona-a11y-audit` for low-vision and motor tracks in the same audit cycle.
