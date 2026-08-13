# Changelog

## 1.1.0 - 2026-08-13

### Added
- Added state-by-state journey auditing with `journey-audit.mjs` and AccessLint scan evidence.
- Added pointer-to-keyboard parity checks that distinguish confirmed mouse-only targets from an insufficient Tab-trace coverage result.
- Added journey and pointer-keyboard parity references to the core AccessiMind skill.

### Changed
- Consolidated all supported workflow guidance and evidence harnesses under the single `accessimind-accessible-ui-agent-skill` directory.
- Simplified installer and package scripts to distribute one Codex skill.

### Removed
- Removed deprecated standalone Playwright, NVDA portable, persona, and senior-developer skill wrappers.
- Removed stale smoke-report artifacts and the legacy multi-skill integration guide.

## 1.0.0.4 - 2026-06-17

### Added
- Added real web-focused NVDA audit harness: `skills/accessimind-accessible-ui-agent-skill/scripts/nvda_web_audit.mjs`.
- Added low-vision measurement harness: `skills/accessimind-accessible-ui-agent-skill/scripts/low_vision_web_audit.mjs`.
- Added motor accessibility measurement harness: `skills/accessimind-accessible-ui-agent-skill/scripts/motor_web_audit.mjs`.
- Added strict no-summary-finding directives for screen-reader, low-vision, and motor evidence.
- Added professional HTML audit report requirements for stakeholder-ready deliverables, including table of contents, Jira summary, Jira description, evidence, remediation, and verification sections.
- Added deeper NVDA coverage requirements: DOM inventory, forward/reverse traversal, Tab traversal, accepted speech, filtered noise, coverage comparison, and atomic screen-reader issue tables.
- Added low-vision evidence infrastructure for zoom/reflow, text spacing, contrast, forced colors, focus visibility, clipping, and target cluster density.
- Added motor evidence infrastructure for target size, target spacing, keyboard parity, drag alternatives, hover-only disclosure, accidental activation, timing, mobile reach, and switch/sequential access.
- Added bilingual README guidance and expanded bilingual usage documentation.

### Improved
- AccessiMind audit behavior now requires measured artifact-backed findings instead of generic summaries for assistive technology, low-vision, and motor access.
- Live web reports now distinguish confirmed evidence, inferred DOM findings, filtered unrelated speech, and explicit limitations.

## 1.0.0.3 - 2026-04-03

### Added
- Integrated skill bundle delivery with `accessimind-accessible-ui-agent-skill`, `playwright`, `nvda-portable-a11y-audit`, `full-persona-a11y-audit`, and `senior-developer-20y`.
- New `nvda-portable-a11y-audit` skill for portable NVDA-based screen-reader evidence and screenshot-driven visual analysis.
- New `full-persona-a11y-audit` skill and runner for blind/low-vision/motor reports in one command.
- AccessiMind skill workflow integration for Playwright runtime evidence and senior engineering production hardening.
- Senior skill integration rules for production handoff and release-risk framing.
- Bundle packaging output: `dist/accessimind-integrated-skill-bundle.zip`.

### Improved
- Installer now deploys all integrated skills into `$HOME\\.codex\\skills`.
- AccessiMind skill now includes explicit production-grade WCAG 2.2 delivery lifecycle and full-compliance claim constraints.

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
- Live-site fallback strategy now supports secondary browser automation via local Playwright CLI wrappers.
- Browser restriction guidance now includes Windows-friendly user-writable wrapper paths and domain-specific access profiles.
- Documentation now better reflects multi-platform review, reporting, and accessibility-verification workflows.
