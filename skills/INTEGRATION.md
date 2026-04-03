# AccessiMind Integrated Skill Methodology

This bundle is designed to run as a coordinated workflow, not as isolated skills.

## Included Skills

- `accessimind-accessible-ui-agent-skill`
- `playwright`
- `senior-developer-20y`

## Execution Order

1. `accessimind-accessible-ui-agent-skill`
Defines scope, WCAG 2.2 A/AA target, implementation rules, and severity calibration.

2. `playwright`
Collects deterministic runtime evidence for keyboard navigation, focus behavior, and DOM state transitions.

3. `senior-developer-20y`
Applies architecture and delivery-risk review, regression strategy, and production release hardening.

## Sign-off Decision Model

AccessiMind emits final gate decision:
- `PASS`
- `PASS_WITH_RISK`
- `FAIL`

The decision requires explicit coverage boundaries, evidence traceability, and unresolved-risk disclosure.
