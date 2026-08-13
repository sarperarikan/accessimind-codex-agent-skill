# Journey audits

For sign-in, search, checkout, booking, onboarding, account, and form-submission flows, make the journey—not the initial URL—the audit unit.

## Execute

Use the bundled journey runner for deterministic state-by-state AccessLint evidence:

```powershell
node .\skills\accessimind\scripts\journey-audit.mjs --journey .\a11y-journey.json --output .\accessibility-journey-report.json
```

The JSON includes `baseUrl`, named journeys, and ordered `url`, `click`, `fill`, `press`, `waitFor`, or `waitMs` steps. Use stable `data-testid` selectors. Do not execute irreversible actions (purchase, send, delete, production record creation) without explicit approval.

## Interpret

- Treat each AccessLint result as automated, reproducible evidence for that exact state.
- Retain every state occurrence as evidence; only deduplicate repeated selector/rule pairs in the human summary.
- Run AccessiMind’s keyboard, visible-focus, reflow/zoom, contrast, state/announcement, and real NVDA requirements at every release-critical state, not only at the first route.
- Use `accesslint` MCP `explain_rule` when rule-level remediation metadata is useful.
- A failed transition, timed-out state, unavailable authenticated route, or missing NVDA/pixel evidence is undetermined or `FAIL` under AccessiMind’s production gate—never a pass.

## Report

Organize findings as `journey → step → state`. Include the action, URL reached, selector/interaction evidence, WCAG mapping, severity, evidence basis, and the appropriate remediation owner (shared component, page, design token, or test fixture). State the untested paths and human/assistive-technology handoffs explicitly.
