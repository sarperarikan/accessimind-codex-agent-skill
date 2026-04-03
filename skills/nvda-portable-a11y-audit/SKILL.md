---
name: nvda-portable-a11y-audit
description: Use when accessibility audits must include real screen-reader validation on Windows using the repository's portable NVDA copy, plus screenshot-based visual evidence and DOM/focus traces.
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

## Required workflow

1. Verify NVDA portable executable exists in `NVDA/`.
2. Verify Playwright wrapper exists and is runnable.
3. Start NVDA from repository-local portable copy.
4. Navigate requested URLs with Playwright.
5. Capture screenshots and DOM/focus evidence for each URL.
6. Stop NVDA cleanly.
7. Produce JSON and Markdown summary artifacts.

## Default runner

Use:

```powershell
.\skills\nvda-portable-a11y-audit\scripts\invoke-nvda-playwright-audit.ps1 -Urls "https://example.com"
```

## Output contract

The script must produce:
- `summary.json`
- `summary.md`
- page screenshots in the report folder

## Guardrails

- Never claim NVDA evidence unless NVDA process was started successfully.
- If NVDA cannot start, mark the run as blocked.
- Keep URLs explicit and in-scope.

## Recommended next step

After NVDA evidence is captured, run `full-persona-a11y-audit` for low-vision and motor tracks in the same audit cycle.
