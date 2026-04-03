---
name: "playwright"
description: "Use when the task requires automating a real browser from the terminal (navigation, form filling, snapshots, screenshots, data extraction, UI-flow debugging) via `playwright-cli` or the bundled wrapper script."
---


# Playwright CLI Skill

Drive a real browser from the terminal using `playwright-cli`. Prefer the bundled wrapper script so the CLI works even when it is not globally installed.
Treat this skill as CLI-first automation. Do not pivot to `@playwright/test` unless the user explicitly asks for test files.

## Prerequisite check (required)

Before proposing commands, check whether `npx` is available (the wrapper depends on it):

```bash
command -v npx >/dev/null 2>&1
```

If it is not available, pause and ask the user to install Node.js/npm (which provides `npx`). Provide these steps verbatim:

```bash
# Verify Node/npm are installed
node --version
npm --version

# If missing, install Node.js/npm, then:
npm install -g @playwright/cli@latest
playwright-cli --help
```

Once `npx` is present, proceed with the wrapper script. A global install of `playwright-cli` is optional.

## Skill path (set once)

```bash
export CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
export PWCLI="$CODEX_HOME/skills/playwright/scripts/playwright_cli.sh"
```

On Windows PowerShell, use the PowerShell wrapper:

```powershell
$env:CODEX_HOME = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { "$HOME\\.codex" }
$env:PWCLI = "$env:CODEX_HOME\\skills\\playwright\\scripts\\playwright_cli.ps1"
```

User-scoped skills install under `$CODEX_HOME/skills` (default: `~/.codex/skills`).

## Quick start

Use the wrapper script:

```bash
"$PWCLI" open https://playwright.dev --headed
"$PWCLI" snapshot
"$PWCLI" click e15
"$PWCLI" type "Playwright"
"$PWCLI" press Enter
"$PWCLI" screenshot
```

If the user prefers a global install, this is also valid:

```bash
npm install -g @playwright/cli@latest
playwright-cli --help
```

PowerShell example:

```powershell
& $env:PWCLI open https://playwright.dev
& $env:PWCLI snapshot
```

## Core workflow

1. Open the page.
2. Snapshot to get stable element refs.
3. Interact using refs from the latest snapshot.
4. Re-snapshot after navigation or significant DOM changes.
5. Capture artifacts (screenshot, pdf, traces) when useful.

Minimal loop:

```bash
"$PWCLI" open https://example.com
"$PWCLI" snapshot
"$PWCLI" click e3
"$PWCLI" snapshot
```

## When to snapshot again

Snapshot again after:

- navigation
- clicking elements that change the UI substantially
- opening/closing modals or menus
- tab switches

Refs can go stale. When a command fails due to a missing ref, snapshot again.

## Recommended patterns

### Form fill and submit

```bash
"$PWCLI" open https://example.com/form
"$PWCLI" snapshot
"$PWCLI" fill e1 "user@example.com"
"$PWCLI" fill e2 "password123"
"$PWCLI" click e3
"$PWCLI" snapshot
```

### Debug a UI flow with traces

```bash
"$PWCLI" open https://example.com --headed
"$PWCLI" tracing-start
# ...interactions...
"$PWCLI" tracing-stop
```

### Multi-tab work

```bash
"$PWCLI" tab-new https://example.com
"$PWCLI" tab-list
"$PWCLI" tab-select 0
"$PWCLI" snapshot
```

## Wrapper script

The wrapper script uses `npx --package @playwright/cli playwright-cli` so the CLI can run without a global install:

```bash
"$PWCLI" --help
```

Prefer the wrapper unless the repository already standardizes on a global install.

### Windows fallback note

If browser MCP is unavailable or the in-app browser session crashes, use the PowerShell wrapper as the secondary browser path before falling back to plain HTTP fetches:

```powershell
& $env:PWCLI open https://example.com
& $env:PWCLI snapshot
```

## References

Open only what you need:

- CLI command reference: `references/cli.md`
- Practical workflows and troubleshooting: `references/workflows.md`

## Guardrails

- Always snapshot before referencing element ids like `e12`.
- Re-snapshot when refs seem stale.
- Prefer explicit commands over `eval` and `run-code` unless needed.
- When you do not have a fresh snapshot, use placeholder refs like `eX` and say why; do not bypass refs with `run-code`.
- Use `--headed` when a visual check will help.
- When capturing artifacts in this repo, use `output/playwright/` and avoid introducing new top-level artifact folders.
- Default to CLI commands and workflows, not Playwright test specs.

## WCAG 2.2 keyboard and DOM evidence mode

Use this mode when the user asks for accessibility audit evidence from real browser interaction.

### Deterministic capture sequence

1. Open target page in headed mode.
2. Capture initial snapshot.
3. Execute a fixed keyboard sequence (`Tab`, optional `Shift+Tab`, `Enter`, `Space`, `Esc`).
4. Re-snapshot after each state change.
5. Record focus target identity per step.
6. Capture final screenshot and summary snapshot.

### Per-step log contract

For each keyboard step, capture:
- step id and timestamp
- active URL and title
- focused element ref
- inferred role/name (from snapshot/DOM)
- visibility of focus indicator
- action result (`navigated`, `opened`, `closed`, `no-op`, `blocked`)

### Accessibility finding hinting

During capture, flag potential issues when observed:
- focus trap or focus loss
- non-focusable interactive element
- hidden or clipped focus outline
- keyboard-inoperable custom control
- semantic mismatch (`div`/`span` acting as button without keyboard parity)

These hints are not final severity decisions; they feed the main audit skill's severity model.

### Output handoff format

When this mode is used for an audit handoff, provide:
- artifact paths
- keyboard step log
- candidate issue list with element refs
- capture limitations (auth walls, blocked modals, anti-bot interstitials)

## AccessiMind integration mode

This skill is integrated with `accessimind-accessible-ui-agent-skill` as the runtime evidence collector.

### Integration contract

When the parent task is an accessibility audit:
- treat this skill as evidence collection only
- do not assign final WCAG severity here
- emit outputs so `accessimind` can map findings to WCAG 2.2 and release gates

### Required handoff fields for AccessiMind

- `run_id`
- `surface` (`url`, `component`, or `page label`)
- `step_log` (ordered keyboard steps)
- `focus_trace` (element refs plus role/name hints)
- `candidate_issues` (short, evidence-linked)
- `artifacts` (snapshot/screenshot/log paths)
- `limitations`

### Severity ownership rule

Potential issue labels in this skill are hints only.
Final severity (`critical/high/medium/low/info`) is owned by `accessimind`.
