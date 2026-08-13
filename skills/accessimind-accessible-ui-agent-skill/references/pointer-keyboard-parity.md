# Pointer–keyboard parity

Use this check for menus, custom cards, icons, accordions, carousels, hover disclosures, and any custom click target.

Run the integrated motor audit:

```powershell
node .\skills\accessimind\scripts\motor_web_audit.mjs --url <url> --focus-steps 160 --out .\motor-web-audit.json
```

Inspect `pointer-reachable-without-keyboard-target` first. It is high-confidence evidence only when a visible target passes Playwright's pointer trial click but has neither a focusable native/semantic owner nor a non-negative `tabindex`.

Treat `pointer-keyboard-parity-undetermined` as a coverage signal, not a defect: expand the Tab trace or open the relevant UI state before making a claim.

For each confirmed issue, record the target selector, pointer action, Tab/Enter/Space reproduction, observed focus/activation behavior, and WCAG 2.1.1 plus 4.1.2 mapping. Never infer keyboard equivalence from `onclick`, visual styling, or programmatic `focus()` alone.
