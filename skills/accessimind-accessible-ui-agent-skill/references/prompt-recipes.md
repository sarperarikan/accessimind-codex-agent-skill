# Prompt Recipes

Use these as reusable starting points when invoking the generic AccessiMind bundle.

## Single page HTML report

```text
Use $accessimind-accessible-ui-agent-skill.
Audit https://example.com as a live accessibility review.
Generate a standalone HTML report under reports/.
Use coverage-first wording and include executive summary, severity summary, repeated-pattern summary, and remediation priorities.
```

## Multi-page domain audit

```text
Use $accessimind-accessible-ui-agent-skill.
Audit https://example.com and up to 5 same-domain pages.
Prefer representative templates over duplicates.
Generate one consolidated HTML report and identify shared shell issues vs route-specific issues.
```

## Component-focused review

```text
Use $accessimind-accessible-ui-agent-skill.
Review this modal, drawer, or form component for WCAG 2.2 risks.
Findings first. Include keyboard model, screen-reader naming/state, dynamic announcements, and concise fix direction.
```

## Remediation plan

```text
Use $accessimind-accessible-ui-agent-skill.
Turn the audit findings into a remediation plan with quick wins, repeated-pattern fixes, acceptance criteria, and Dev/BA/PO action mapping.
```
