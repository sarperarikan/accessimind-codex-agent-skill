# Changelog

## 1.0.0.13 - 2026-04-03

### Improved
- Switched the main production audit path from Playwright-first collection to a Chrome CDP-native collector via `scripts/deterministic_cdp_probe.cjs`.
- Made CDP attachment mandatory for the main runner path and reduced Playwright dependency in active production audit runners.
- Promoted vision evidence to a required runtime gate alongside NVDA speech evidence and CDP artifacts.
- Updated the single HTML report pipeline to summarize axe, CDP accessibility tree, and vision candidate counts per page.

## 1.0.0.12 - 2026-04-03

### Added
- Added `axe-core` execution inside the deterministic CDP-backed probe so runtime artifacts now include rule-engine violations alongside DOM, focus, screenshot, and NVDA evidence.
- Added CDP accessibility-tree capture to the deterministic probe so reports can summarize AX node counts and role distribution evidence.
- Added `scripts/langchain_a11y_commentary.py` to generate Turkish executive commentary and page-level review notes from audit summaries, using LangChain with OpenAI when configured and a deterministic heuristic fallback otherwise.

### Improved
- Updated both full-persona and NVDA runners to install `axe-core` in their probe environment automatically.
- Updated the developer-ready HTML generator to include LLM commentary output plus `axe` and CDP evidence columns in the page summary table.

## 1.0.0.11 - 2026-04-03

### Improved
- Added structure-aware locator capture to the deterministic collector so report outputs can include exact DOM-oriented locators instead of coarse selector hints.
- Added issue-level crop generation for developer-ready HTML reporting when a finding maps to a visible bounded element.
- Added a developer-ready actionable HTML report generator that clusters repeated issues, removes non-a11y localization sections, and shows exact locator plus crop evidence per sample finding.

## 1.0.0.10 - 2026-04-03

### Improved
- Reworked full-persona HTML report generation to be UTF-8-safe with explicit round-trip validation and mojibake fail-fast checks.
- Switched report wording to behavior-first narratives so findings explain which element was reached, what happened during interaction, why the behavior fails WCAG 2.2, and what the expected outcome should be.
- Updated BA `As-Is` / `To-Be` output to derive from actual DOM, focus-trail, and NVDA spoken evidence instead of generic default phrasing.
- Documented Chrome-first attached-audit usage as the required live-site flow for deterministic production-grade reporting.

## 1.0.0.9 - 2026-04-03

### Added
- Added LangChain-based access-surface classification via `scripts/langchain_access_surface_analyzer.py` to detect `access_denied`, challenge, login-wall, and bot-mitigation renders from deterministic browser artifacts.
- Added safe session-assisted acquisition inputs to audit runners: `-StorageStatePath` and `-CdpUrl`.

### Improved
- Updated the Playwright collector to emit access-barrier signals and acquisition mode metadata.
- Updated blind and full-persona runners to fail fast on rendered access barriers instead of reporting those pages as valid target content.
- Added support for reusing an already open user browser window for NVDA spoken-trace capture when the audit is attached to a legitimate existing browser session.

## 1.0.0.8 - 2026-04-03

### Added
- Added `scripts/nvda_speech_probe.py` to capture real NVDA Speech Viewer output, step-level spoken phrases, and browser interaction traces during blind-side audits.
- Added spoken-trace integration to the portable NVDA runner and full-persona HTML output so final artifacts now include what NVDA announced during deterministic interaction steps.

### Improved
- Hardened NVDA startup handling by normalizing Welcome and Usage Data Collection dialogs before spoken-trace capture begins.
- Enforced spoken output as a required blind-side evidence signal instead of treating screen-reader confirmation as process-only metadata.

## 1.0.0.7 - 2026-04-03

### Improved
- Replaced permissive fallback-oriented audit behavior with a deterministic rendered-runtime evidence gate for live-site reviews.
- Updated full-persona and NVDA runners to fail fast when DOM inventory, scroll checkpoints, screenshots, or keyboard/assistive-tech traces are not actually captured.
- Removed placeholder artifact synthesis and partial/blocked coverage wording from the active skill contract in favor of a single `verified` runtime status.

## 1.0.0.6 - 2026-04-03

### Improved
- Added runtime resilience for audit runners, including retry and session-reset behavior for unstable browser automation.
- Added stateful component coverage, coverage-status reporting, localization summaries, and repeated-pattern synthesis support.
- Added generic prompt recipes and local HTML fixtures for repeatable regression-style checks without relying on a customer site.

## 1.0.0.5 - 2026-04-03

### Improved
- Added deep-traversal reporting guidance so AccessiMind audits scroll through more of each page and preserve broader head-to-tail element coverage.
- Updated reporting guidance to prefer coverage-first wording over dedicated limitations sections in user-facing audit output.
- Increased full-persona runner keyboard traversal depth and added multi-checkpoint scroll coverage summaries, interactive-element counts, and richer inventory output.
- Extended NVDA portable runner summaries with deeper coverage metrics, interactive counts, and scroll-checkpoint reporting.
- Added runtime resilience, stateful component coverage, localization summaries, prompt recipes, and generic local fixtures for repeatable regression checks.

## 1.0.0.4 - 2026-04-03

### Improved
- Promoted the repository bundle behavior into the core `accessimind-accessible-ui-agent-skill` so the main skill now explicitly orchestrates Playwright, portable NVDA, full-persona audit, BA handoff, and senior-engineering review.
- Tightened the main skill's data contracts for runtime evidence, NVDA outputs, persona report structure, BA remediation fields, and senior production handoff requirements.
- Updated skill metadata and docs to describe the integrated bundle as the active default behavior instead of a loosely coupled add-on workflow.

## 1.0.0.3 - 2026-04-03

### Added
- Integrated skill bundle delivery with `accessimind-accessible-ui-agent-skill`, `playwright`, `nvda-portable-a11y-audit`, `full-persona-a11y-audit`, `business-analyst-a11y`, and `senior-developer-20y`.
- New `nvda-portable-a11y-audit` skill for portable NVDA-based screen-reader evidence and screenshot-driven visual analysis.
- New `full-persona-a11y-audit` skill and runner for blind/low-vision/motor reports in one command.
- New `business-analyst-a11y` sub-skill for As-Is analysis and role-based action planning.
- Full persona runner now produces project-and-date report folders and UTF-8 accessible `index.html` with table of contents and per-page element inventory.
- AccessiMind skill workflow integration for Playwright runtime evidence and senior engineering production hardening.
- Senior skill integration rules for production handoff and release-risk framing.
- Bundle packaging output: `dist/accessimind-integrated-skill-bundle.zip`.

### Improved
- Installer now deploys all integrated skills into `$HOME\\.codex\\skills`.
- AccessiMind skill now includes explicit production-grade WCAG 2.2 delivery lifecycle and full-compliance claim constraints.
- NVDA runner now enforces mandatory cookie workflow (evaluate -> accept -> restart at top), full-page DOM scan capture, and UTF-8 BOM report writing with mojibake fail-fast checks.
- Full persona runner now normalizes default project naming to a host-first label (for example `example`) and enforces encoding integrity checks on all generated report artifacts.

## 1.0.0.2 - 2026-04-02

### Added
- Agentic accessibility review mode for inspection, audit, and critique requests.
- Detailed HTML accessibility audit report generation mode.
- Live-site accessibility evaluation mode with rendered-DOM-first review behavior.
- Domain-scoped multi-page audit mode with seed URL, depth, and page-count support.
- Site-specific access strategy selection for WAF, locale-sensitive delivery, referer-sensitive routing, and session-sensitive behavior.
- Default HTML report output convention under the workspace `reports` directory with date-based filenames.
- Jira-ready task generation mode with structured objectives, scope, acceptance criteria, QA notes, and definition of done.
- Rich ARIA usage guidance, region/landmark rules, and e-commerce `aria-live` directives.
- Shared issue deduplication, severity calibration, remediation planning, executive summary, evidence manifest, and authenticated-boundary handling.
- Deterministic persona-simulation guidance for blind, low-vision, keyboard-only, and motor-limited review paths.

### Improved
- Live-site browser strategy now supports secondary rendered browser automation via local Playwright CLI wrappers.
- Browser restriction guidance now includes Windows-friendly user-writable wrapper paths and domain-specific access profiles.
- Documentation now better reflects multi-platform review, reporting, and accessibility-verification workflows.
