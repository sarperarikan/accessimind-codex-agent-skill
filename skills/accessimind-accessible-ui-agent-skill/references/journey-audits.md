# Journey audits

For sign-in, search, filtering, checkout, booking, onboarding, account, and form submission, audit the complete user task.

## Scope and sample

Record the entry points, end condition, platforms, test fixtures and scope gaps. For site-wide work, combine the sitemap or route inventory with product navigation. Cover common views, distinct templates, essential processes, high-risk states and, when useful, a recorded random sample. [WCAG-EM](https://www.w3.org/TR/WCAG-EM/)

## Execute

Use the bundled journey runner for deterministic state-by-state AccessLint evidence. Run the example from the repository root or resolve the script path from the installed skill folder.

```powershell
node .\skills\accessimind-accessible-ui-agent-skill\scripts\journey-audit.mjs --journey .\a11y-journey.json --output .\accessibility-journey-report.json
```

The JSON includes `baseUrl`, named journeys, and ordered `url`, `click`, `fill`, `press`, `waitFor`, or `waitMs` steps. Use stable `data-testid` selectors. Do not execute irreversible actions (purchase, send, delete, production record creation) without explicit approval.

Exercise loading, empty, invalid-input, error and recovery states when relevant to the user goal. Include overlays and alternate entrances that affect the flow. Independently verify the expected URL or visible state after each scripted transition. Capture actual keyboard, pointer or assistive-technology evidence for each relevant claim. If an essential step is blocked, log it and continue with any independent reachable states.

## Interpret

- Treat each AccessLint result as automated, reproducible evidence for that exact state.
- Check for `scanError` in the state record. A reached state with a scan error still needs automated or manual coverage. Verify the expected page or component rendered before interpreting a scan.
- Retain affected routes and states when deduplicating a shared defect. Verify the same behavior or shared implementation before combining occurrences.
- Run AccessiMind’s keyboard, visible-focus, reflow/zoom, contrast, state/announcement, and real NVDA requirements at every release-critical state, not only at the first route.
- Use `accesslint` MCP `explain_rule` when rule-level remediation metadata is useful.
- Record failed transitions, timed-out states, unavailable authenticated routes and missing NVDA or visual evidence as blocked or unverified coverage. When producing a release decision, apply the corresponding production gate separately.

## Report

Organize findings by journey, step and state. Include the action, URL reached, selector or interaction evidence, WCAG criterion, applicable Ministry edition and question, severity and remediation owner. Record discovered and tested views, completed and blocked journeys, and the modalities used. Replay stable steps after a fix and report fixed, recurring, new, blocked and unverified outcomes. [Rule and evidence workflow](wcag-rule-workflow.md)
