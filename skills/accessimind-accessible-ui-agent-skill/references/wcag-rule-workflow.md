# WCAG rule catalog and evidence workflow

Use [wcag-2-2-catalog.tsv](wcag-2-2-catalog.tsv) to select criteria by level. It indexes the 86 active WCAG 2.2 success criteria with official anchors. Totals are cumulative for conformance: 31 at A, 55 at AA, and 86 at AAA. Evaluate WCAG scope against full pages and complete processes. For native software, consult [WCAG2ICT](https://www.w3.org/TR/wcag2ict-22/) and platform semantics. Record platform applicability and the resulting technical test separately. WCAG 2.2 removed 4.1.1 Parsing. Retain it only for an older version when that version is in scope. [WCAG 2.2](https://www.w3.org/TR/WCAG22/)

## Evidence per rule and state

1. Establish the expected outcome from the WCAG criterion, including its exceptions. Use sufficient techniques, APG, and platform guidance to design a test. Equivalent implementations may satisfy WCAG.
2. Declare the scope and state before running a rule. Record surface, URL or screen, build or timestamp, process and step, browser/device, viewport, language, inputs and modality as applicable.
3. Run the appropriate test. An automated rule can establish a reproducible failure when its actual conditions and exceptions are verified. An empty automated result or missing rule is a coverage gap for any untested behavior. For visual checks measure the rendered UI; for speech claims capture the real reader; for gestures and focus drive the real interaction. Distinguish DOM, accessibility tree, events and audible output.
4. Record the expected result, observed result, evidence path, criteria and versioned checklist IDs when applicable. Use `pass` for verified in-scope requirements, `fail` for reproduced mismatches, `not_applicable` for a demonstrated absence or exception, `unverified` for insufficient evidence and `blocked` for an environment or access dependency.
5. Aggregate by criterion and tested scope. Preserve all affected states in repeated findings. Keep failed checks and coverage gaps visible. State counts for each status, distinct views and processes, tools and configurations, and evidence needed for remaining gaps.

## Optional automated evidence

Run the project's accessibility harness, AccessLint, or axe-core directly on each available rendered state. Record the engine/version, enabled rule IDs or WCAG tags, targets, violations and unresolved results. Keep machine output available for replay or CI where the project already has that workflow. Confirm that the expected page rendered before interpreting a scan. Do not count a redirect to an unrelated page, an access-denied document, or an empty shell as successful coverage.

## Lookup

From the skill directory run `node scripts/wcag-rules.mjs 2.1.1` to show the canonical criterion and both Turkish editions' mapped questions. Run `node scripts/wcag-rules.mjs 122 95` or `node scripts/wcag-rules.mjs 126 106` to resolve a question in a known edition. Run `node scripts/wcag-rules.mjs --validate` after catalog changes. The script only reads bundled rule data and needs no account, network or third-party package.
