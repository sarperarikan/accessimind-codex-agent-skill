# AccessiMind Integrated Skill Methodology

This bundle is designed to run as a coordinated workflow, not as isolated skills.

## Included Skills

- `accessimind-accessible-ui-agent-skill`
- `playwright`
- `senior-developer-20y`
- `nvda-portable-a11y-audit`
- `full-persona-a11y-audit`

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

## Sign-off Decision Model

AccessiMind emits final gate decision:
- `PASS`
- `PASS_WITH_RISK`
- `FAIL`

The decision requires explicit coverage boundaries, evidence traceability, and unresolved-risk disclosure.
