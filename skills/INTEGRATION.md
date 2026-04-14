# AccessiMind Integrated Skill Methodology

This bundle is designed to run as a coordinated workflow, not as isolated skills.

## Included Skills

- `accessimind-accessible-ui-agent-skill`
- `playwright`
- `senior-developer-20y`
- `nvda-portable-a11y-audit`
- `full-persona-a11y-audit`
- `business-analyst-a11y`

## Execution Order

1. `accessimind-accessible-ui-agent-skill`
Defines scope, WCAG 2.2 A/AA target, implementation rules, and severity calibration.

2. `playwright`
Collects deterministic runtime evidence for keyboard navigation, focus behavior, and DOM state transitions.

3. `nvda-portable-a11y-audit`
Runs real screen-reader evidence collection using the repository-local portable `NVDA/` copy and captures screenshot artifacts.

4. `full-persona-a11y-audit`
Combines blind, low-vision, and motor-limited checks into one deterministic run and produces per-persona reports.

5. `senior-developer-20y`
Applies architecture and delivery-risk review, regression strategy, and production release hardening.

6. `business-analyst-a11y`
Adds As-Is analysis, To-Be target state, and role-based action notes (Developer/BA/PO) for each finding.

## Sign-off Decision Model

AccessiMind emits final gate decision:
- `PASS`
- `PASS_WITH_RISK`
- `FAIL`

The decision requires explicit coverage boundaries, evidence traceability, and unresolved-risk disclosure.

## Absolute Audit Constraints

- Generated report artifacts must be UTF-8 safe (BOM on Windows outputs) and must not contain mojibake.
- Cookie dialog flow is mandatory per page:
1. detect and evaluate dialog accessibility
2. accept dialog
3. return to top of page
4. start evidence collection
- Blind-side NVDA evidence must align with Browse Mode categories and Elements List logic.
- Reports must be detailed (not short-form) and include per-page findings, head-to-tail element inventory, and BA action mapping.
