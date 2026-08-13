# Changelog

## 1.1.1 - 2026-08-13

### Changed

- Simplified the repository to the single `accessimind-accessible-ui-agent-skill` distribution.
- Removed the bundled portable NVDA runtime. The NVDA evidence harness now uses an NVDA installation available on the auditor's Windows environment.
- Removed obsolete release notes and multi-skill-era documentation.
- Kept the README and usage guide aligned with the current journey, low-vision, motor, and NVDA evidence harnesses.

## 1.1.0 - 2026-08-13

### Added

- State-by-state journey auditing with `journey-audit.mjs` and AccessLint scan evidence.
- Pointer-to-keyboard parity checks that distinguish confirmed mouse-only targets from insufficient Tab-trace coverage.

### Changed

- Consolidated all supported workflow guidance and evidence harnesses under `skills/accessimind-accessible-ui-agent-skill`.
