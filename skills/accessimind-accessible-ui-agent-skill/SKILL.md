---
name: accessimind-accessible-ui-agent-skill
description: Use when the user wants production-ready modern UI work for existing projects or new screens in React, HTML, or CSS, with stack-aware implementation, enterprise-grade multilingual architecture, consistent design systems, WCAG 2.2-compliant output, axe-core-backed accessibility verification, and strong support for dynamic and stateful interfaces.
---

# AccessiMind Accessible UI Agent Skill

Use this skill when building or refactoring UI in web projects that must be modern, consistent, multilingual, accessibility-first, and production-ready.

Keep this skill practical. Prefer shipping code over writing design essays.

This skill must also support delivery planning output when the user asks for implementation breakdowns, rollout plans, handoff documentation, or Jira-ready task definitions for the UI and accessibility work.

## Outcomes

Produce UI that is:
- modern but not trendy for its own sake
- usable with keyboard, screen reader, zoom, forced colors, and reduced motion
- usable across blind, low-vision, motor-limited, speech-input, cognitive-load, deaf and hard-of-hearing, and vestibular-sensitive user needs where those needs affect the target UI
- structurally correct in semantic HTML first
- consistent through tokens, states, spacing, and component rules
- multilingual by architecture, not by string scattering
- aligned with the current project's existing stack and patterns
- verified with automated accessibility checks plus explicit manual review notes
- resilient for both static layouts and dynamic, stateful application behavior
- production-ready for implementation, QA, regression review, and repeatable release workflows

This skill must also support agentic accessibility review work when the user asks to inspect, audit, evaluate, review, or critique an existing UI, component, DOM fragment, page structure, prototype, or interaction flow from an accessibility perspective.

## Accessibility review trigger rules

This skill should activate not only for implementation requests, but also for review-oriented requests such as:
- `şu yapıyı erişilebilirlik açısından incele`
- `bu componenti accessibility review yap`
- `bu HTML erişilebilir mi`
- `bu ekranı WCAG açısından değerlendir`
- `audit this UI for accessibility`
- `review this markup for a11y`
- `is this component accessible`
- `check this modal / form / carousel / table for accessibility`

Treat these and similar requests as an accessibility analysis or audit request, even if the user does not explicitly say "use the skill".

## Agentic accessibility review mode

When the request is review-oriented, switch from implementation mode to review mode.

### Review-mode objective

Identify:
- real accessibility defects
- likely WCAG 2.2 risks
- broken semantics
- keyboard and focus issues
- screen-reader naming/state/relationship issues
- motion, contrast, target size, zoom, reflow, and dynamic-state issues
- localization and runtime-announcement issues where relevant

Do not default to rewriting the code first. Inspect, reason, and report findings clearly before proposing or applying fixes unless the user explicitly asks for direct remediation.

### Review workflow

1. Determine the surface: HTML, screenshot, DOM snippet, component file, live URL, product flow, modal, form, carousel, footer, etc.
2. Determine what can be directly observed versus inferred.
3. Check native semantics first.
4. Check naming, role, state, value, and relationships.
5. Check keyboard access and focus behavior.
6. Check dynamic announcements and live updates if the UI is stateful.
7. Check structural landmarks, headings, lists, tables, and grouping.
8. Check relevant WCAG 2.2 A/AA criteria for the surface.
9. Report findings ordered by severity.
10. Call out unknowns or unverified areas explicitly.

### Review output rule

When using this skill for a review, findings are the primary output.

Prefer:
- severity-ordered findings
- exact element, selector, snippet, or file references when available
- explanation of why the issue matters
- likely impacted users
- relevant WCAG 2.2 criterion references where helpful
- concise fix direction

Avoid:
- vague praise with no findings
- generic checklist recitation without tying it to the actual UI
- claiming compliance when only a partial review was possible

### Review result shape

When possible, structure findings like:
- finding title
- severity
- affected area
- issue description
- user impact
- WCAG reference
- recommended fix

If no concrete defects are found, say so explicitly and still list:
- residual risks
- unverified areas
- testing gaps

## Severity calibration mode

This skill must calibrate severity deliberately instead of treating every automated violation as equally important.

### Severity calibration rules

- `critical` should be reserved for issues that block core task completion, break accessibility tree structure for key controls, or create severe keyboard or screen-reader failure in important flows
- `high` should be used for major accessibility failures that significantly harm access but may not fully block the whole journey
- `medium` should be used for real defects that degrade usability, semantics, or consistency without fully breaking the flow
- `low` should be used for minor quality issues, weak semantics, or less harmful discoverability problems
- `info` should be used for observations, residual risks, or design quality notes that do not stand as strong defects

### Automated tool calibration rule

When using axe or similar tools:
- do not copy tool severity blindly
- interpret the issue in product context
- consider whether the issue is in a critical path, shared shell, repeated component, or marginal area
- separate tool-reported impact from final audit severity if necessary

## Shared issue deduplication mode

For multi-page audits, this skill must deduplicate repeated issues across shared templates and global shells.

### Deduplication rules

- if the same footer, header, mini-cart, modal, compare bar, or social-links issue appears on multiple pages, report it once as a shared component issue
- keep page examples as evidence, but do not repeat the full finding block for every page unless the implementation genuinely differs
- prefer central remediation advice when the defect clearly belongs to a shared template or design-system component

### Shared issue labels

When useful, label findings as:
- shared shell issue
- shared component issue
- repeated pattern issue
- route-specific issue

## Fix plan mode

When the user asks what to do next after an audit, this skill should be able to produce a remediation plan instead of only findings.

### Fix plan structure

Organize fixes into groups such as:
- quick wins
- shared template fixes
- component-level fixes
- design-system or token fixes
- page-specific fixes
- verification and regression work

### Fix plan rules

- prioritize fixes that remove the largest repeated accessibility cost first
- move shared-template and token fixes ahead of scattered local patches when that is technically realistic
- distinguish implementation work from QA validation work
- clearly identify which fixes are likely to collapse many repeated findings at once

## Design-system remediation mode

This skill must be capable of deciding whether a finding belongs to:
- a single page
- a reusable component
- a token or design-system primitive
- a product-wide platform shell

### Design-system routing examples

- contrast issues repeated across many surfaces may be token-level
- icon-only button naming issues repeated across pages may be component-level
- incorrect landmark usage repeated in shared footer/header areas may be shell-level
- one isolated unlabeled input may be page-level

## Manual test script generation mode

This skill must be able to generate deterministic manual test scripts after an audit.

### Required manual test tracks

When useful, generate flat test steps for:
- keyboard-only
- screen reader smoke test
- zoom and reflow
- reduced motion
- mobile touch target review
- visible focus review

### Manual script rules

- write steps in the project language unless asked otherwise
- keep them reproducible and deterministic
- reference the exact surface or page
- state expected results, not just actions

## Executive summary mode

This skill must be able to produce a non-technical or semi-technical executive summary alongside the technical audit.

### Executive summary rules

- focus on business risk, user impact, and remediation priority
- avoid dumping raw ARIA or DOM jargon without interpretation
- summarize repeated defects as systemic issues when appropriate
- keep this separate from the technical findings section

## Evidence manifest mode

When running a live or multi-page audit, this skill should be able to keep a compact evidence manifest.

### Evidence manifest fields

Include when available:
- evaluated URL
- timestamp
- browser channel
- locale
- language headers
- referer strategy
- session strategy
- render status
- screenshot status
- tool outputs used: axe, DOM snapshot, keyboard check, source fetch, etc.

### Evidence manifest rule

The report should show enough evidence metadata that another reviewer can understand how the audit was performed.

## Authenticated boundary mode

This skill must explicitly handle login-gated or account-gated surfaces.

### Auth boundary rules

- do not imply authenticated coverage if the flow was not actually accessed
- mark these areas as `unverified behind auth` or equivalent
- distinguish between public accessibility findings and authenticated unknowns
- if the user provides an authenticated state later, resume from that boundary rather than rewriting prior findings

## Component audit template mode

This skill should maintain a reusable audit lens for common UI patterns.

### Template-ready surfaces

At minimum, support focused review templates for:
- dialog
- drawer
- mega menu
- product card
- compare flow
- mini-cart
- search autocomplete
- filters and sort panels
- carousel or swiper
- footer
- form and validation
- data table or grid

### Template behavior

When the user names one of these components, narrow the audit lens to the most relevant:
- semantics
- naming
- keyboard model
- focus behavior
- dynamic announcements
- state changes
- relevant WCAG criteria

## Deterministic persona simulation mode

This skill must be able to simulate accessibility review flows from the perspective of different user needs in a deterministic, tool-driven way.

Important:
- do not claim to literally become or fully represent a blind, low-vision, or physically disabled person
- do not present heuristic simulation as lived experience
- instead, use repeatable interaction constraints that approximate likely barriers for that persona category

### Persona simulation objective

Use deterministic constraints to surface likely failures for:
- blind screen reader users
- low-vision users
- keyboard-only users
- motor-limited or limited-reach users

### Blind screen reader simulation rules

Simulate by prioritizing:
- heading and landmark traversal
- accessible names
- link and button purpose
- status message exposure
- dialog entry and exit semantics
- form label and error association

When possible, the report should include a section such as:
- what a screen-reader-first navigation path can reach
- where meaning is missing or ambiguous
- where the accessibility tree likely diverges from the visible UI

### Low-vision simulation rules

Simulate by checking:
- zoom and reflow viability
- contrast exposure
- focus visibility
- clipping and overlap risk
- dense target clusters
- whether link or button names remain understandable when visually scanning at high zoom

### Motor-limited simulation rules

Simulate by checking:
- keyboard-only completion paths
- target size and spacing
- drag-only or precision-only interactions
- small close buttons and crowded icon rows
- whether pointer precision is unnecessarily required

### Deterministic persona evidence rule

When these simulations are included in an audit report:
- label them clearly as heuristic persona simulation
- tie them to concrete observed UI evidence
- avoid vague statements like `a blind user would hate this`
- instead write specific statements like `under a screen-reader-first navigation model, these four links expose only platform names and not destination purpose`

### Persona simulation report section

When requested or when the audit is audit-heavy, the HTML report should be able to include:
- heuristic blind-navigation findings
- heuristic low-vision findings
- heuristic motor-limited findings
- the deterministic checks used for each section

## Acceptance criteria generator mode

This skill must be able to convert findings into implementation-ready accessibility acceptance criteria.

### Acceptance criteria generation rules

- derive criteria from the actual defect, not a generic checklist
- keep each criterion testable
- separate shared-shell criteria from page-specific criteria
- include dynamic states when the issue involves overlays, filtering, cart actions, compare actions, or runtime status updates

## HTML accessibility analysis report mode

This skill must also be capable of generating a detailed HTML accessibility analysis report when the user asks for a report artifact instead of, or in addition to, a plain-text review.

Trigger this mode for requests such as:
- `erişilebilirlik değerlendirme raporu oluştur`
- `HTML accessibility report hazırla`
- `detaylı audit raporunu HTML ver`
- `bu incelemeyi HTML rapor olarak üret`
- `generate an HTML accessibility audit report`
- `export this accessibility review as HTML`

Treat these and similar requests as a report-generation request within review mode.

### HTML report objective

Generate a self-contained HTML report that:
- summarizes the reviewed surface clearly
- separates confirmed defects from inferred risks
- groups findings by severity
- references relevant WCAG 2.2 criteria
- explains user impact and fix direction
- is readable by both engineers and non-engineering stakeholders
- can be archived, shared internally, or attached to Jira, QA, or audit workflows

### HTML report generation rules

- Match the language of the report to the user request or project language unless the user asks for another locale.
- If the reviewed UI is multilingual, the report may still be single-language by default, but state which locale the review was performed against.
- Use semantic HTML in the report itself. The report must model good accessibility practice, not just describe it.
- Prefer a single standalone `.html` file unless the user explicitly asks for split assets.
- Use plain CSS in a `<style>` block unless the target repo already has a report styling system.
- Do not rely on JavaScript for core readability or navigation inside the report unless the user explicitly requests interactive reporting.

### Domain-scoped multi-page audit mode

This skill must also support domain-scoped accessibility audits where the user wants a report across multiple related pages under the same domain, starting from a seed URL and constrained by crawl depth and page count.

Trigger this mode for requests such as:
- `aynı domain içinde derinlik vererek audit yap`
- `şu URL'den başlayıp 2 derinlik 10 sayfa tara`
- `alt sayfaları da dahil ederek erişilebilirlik denetimi yap`
- `crawl this domain for accessibility starting from this URL`
- `audit 15 pages under this path with depth 3`

### Multi-page audit inputs

When the user requests this mode, the skill should understand or infer these inputs:
- seed URL
- domain scope
- maximum depth
- maximum page count
- optional path restriction
- optional locale or market
- optional priority surfaces such as footer, header, forms, product pages, listing pages, checkout, or account flows

If the user does not provide all of them, make a reasonable assumption and state it in the report.

### Multi-page audit boundaries

The crawl and review must stay within the intended scope:
- do not follow links to external domains unless the user explicitly asks for that
- prefer same-origin links by default
- if the user says "same domain", treat subpages under that domain as eligible and exclude third-party destinations
- if the user gives a path scope, do not wander outside it unless needed for a required shared surface such as a global footer or header

### Multi-page crawl strategy

For domain-scoped audits:
1. Start from the seed URL.
2. Collect eligible same-domain links from the rendered page or fallback DOM/source.
3. Deduplicate normalized URLs.
4. Respect the requested maximum depth.
5. Respect the requested maximum page count.
6. Prefer representative and high-value pages when the candidate set is larger than the allowed page count.

### Page selection heuristics

When the crawl frontier is larger than the allowed page count, prioritize:
- template-diverse pages over near-duplicates
- top navigation destinations
- key transactional or high-traffic pages
- pages with unique interaction models
- pages likely to expose shared accessibility regressions such as common footers, headers, drawers, filters, and modals

Avoid wasting page budget on:
- obvious pagination duplicates
- pure campaign clones with identical structure
- faceted URLs that only differ by minor query parameters unless the user explicitly wants filter-state review

### Required report metadata for multi-page audits

When creating an HTML report for a multi-page audit, include:
- seed URL
- domain scope
- crawl depth
- requested page limit
- actual pages reviewed
- page selection method
- path restrictions if any
- pages skipped and why when relevant

### Required report sections for multi-page audits

Add these sections on top of the standard HTML report structure when the audit spans multiple pages:
- audit scope definition
- crawl configuration
- reviewed page inventory
- cross-page findings
- page-specific findings
- shared component findings
- coverage gaps and skipped pages

### Multi-page finding model

In multi-page reports, findings should be classified as one of:
- shared template issue
- page-specific issue
- component-pattern issue
- inferred sitewide risk

This distinction matters because some defects belong to a shared global shell while others are isolated to one route.

### Cross-page synthesis rule

Do not output only a raw page-by-page dump.

The report must synthesize:
- repeated issues across multiple pages
- severity trends
- which defects are likely template-level
- which pages are representative examples
- where remediation should happen centrally versus locally

### URL, depth, and page-count template support

The skill should understand and be able to work from a template shape such as:

```text
URL: https://example.com/start
Domain: example.com
Depth: 2
Page count: 10
Path scope: /products
Locale: tr-TR
```

Equivalent natural-language requests should also be understood.

### Multi-page audit output rule

If the user asks for a domain-scoped accessibility report:
- produce one consolidated HTML report by default
- include a reviewed page inventory table
- show which findings are shared versus route-specific
- include crawl limits and confidence notes
- state clearly if some pages were unreachable, blocked by WAF, login, rate limits, or environment restrictions

### Required HTML report sections

A detailed HTML accessibility analysis report should include at minimum:
- report title
- metadata block
- scope summary
- methodology
- executive summary
- severity summary
- confirmed findings
- inferred risks or unverified areas
- WCAG 2.2 mapping summary
- recommended remediation direction
- QA / verification next steps

### Required metadata fields

Include these fields in the report header or metadata area:
- report title
- reviewed surface or component name
- source input type: live page, HTML snippet, screenshot, component file, DOM extract, etc.
- review date
- report language
- reviewer or agent label if helpful
- review confidence or review limitations when relevant

### Finding card structure for HTML reports

Each finding block in the HTML report should include:
- finding id
- finding title
- severity
- affected area
- issue description
- observed evidence
- user impact
- relevant WCAG 2.2 reference
- recommended fix direction
- implementation note or verification note when useful

### Severity summary rules

When building HTML reports:
- include total finding counts by severity
- separate confirmed defects from inferred risks
- do not inflate severity when verification is incomplete
- mark informational notes separately from actionable defects

### WCAG mapping rules for HTML reports

When relevant, include:
- criterion number
- short criterion name
- whether the issue is a confirmed defect, likely risk, or verification gap

Do not pad the report with irrelevant WCAG rows. Only map criteria that actually apply to the reviewed surface.

### Report language rules

The report content, section titles, finding explanations, and remediation notes should follow the user's language or the project's primary language.

For multilingual products, the skill should also be capable of producing report labels and finding content in:
- Turkish
- English

If needed, note locale-specific findings such as:
- incorrect `lang`
- untranslated live region messages
- mixed-language control names
- broken directionality or locale-sensitive wording

### Accessibility requirements for the report itself

The generated HTML report must itself be accessible:
- use a valid page title
- declare the correct document `lang`
- use heading hierarchy correctly
- use lists and tables only where semantically appropriate
- ensure sufficient contrast for severity chips, badges, and summaries
- avoid color-only severity encoding
- keep keyboard navigation straightforward
- ensure links have clear purpose
- use real tables for tabular summaries, not generic `div` grids pretending to be tables

### Preferred report structure

Prefer a structure similar to:
- `header` for title and metadata
- `main` for the report body
- `section` blocks for summary, findings, WCAG mapping, and next steps
- `article` per finding when findings are substantial
- `nav` for optional table of contents when the report is long

### Visual rules for the report

The report should look professional and audit-ready, but not decorative for its own sake.

Prefer:
- clear typography
- restrained color usage
- high-contrast severity tokens
- readable spacing
- compact but scannable sections
- printable layout where practical

Avoid:
- dashboard noise
- animation-heavy report UIs
- inaccessible color-only charts
- collapsible-only content that hides critical findings behind JS

### Report output behavior

When the user asks for an HTML report:
- generate the report as a real `.html` artifact when file creation is appropriate
- otherwise provide the HTML content directly if the user explicitly asked for inline output
- mention what was directly observed versus inferred
- state any evidence limitations clearly in the report itself

### Default HTML report file location rule

When this skill generates an HTML accessibility audit report as a file, the default output location should be:
- the current workspace
- inside a `reports` directory

If `reports` does not exist, create it.

Unless the user explicitly requests another path or filename convention, the HTML report filename should include:
- a short surface or audit label
- the date

Preferred filename shape:

```text
reports/<audit-label>-YYYY-MM-DD.html
```

Examples:
- `reports/swiper-accessibility-review-2026-04-02.html`
- `reports/arcelik-social-links-live-audit-2026-04-02.html`
- `reports/domain-audit-2026-04-02.html`

### Naming rules for default report files

- use lowercase kebab-case
- keep names readable and predictable
- include the date in ISO format `YYYY-MM-DD`
- avoid spaces
- avoid vague names such as `report.html` or `audit.html`
- if multiple reports are created for the same date and label, add a short differentiator only when needed

### Default output behavior

When no explicit output path is provided:
- create the file under the workspace `reports` folder
- mention the created file path in the response
- prefer a real file over inline HTML when the user asks for a report artifact

### Report modes

Support these report densities:
- summary report: concise executive + findings
- standard report: full findings with WCAG references
- audit-heavy report: detailed findings, rationale, remediation notes, and verification gaps

If the user does not specify, default to `standard report`.

### Example report request understanding

Interpret requests like these as valid:
- `şu inceleme için HTML accessibility raporu oluştur`
- `bu component audit sonucunu html dosyası yap`
- `detaylı erişilebilirlik analiz raporu üret`
- `create a detailed HTML accessibility assessment report for this screen`

In these cases, remain in review mode, but change the output format from simple findings to a structured HTML analysis artifact.

### Inference rule during reviews

If the review is based on incomplete inputs such as screenshots, partial HTML, or a fragment without behavior:
- clearly separate observed issues from inferred risks
- do not present inferred risks as confirmed defects
- say what would need verification in a live implementation

## Live site accessibility evaluation mode

This skill must also support direct accessibility evaluation of live websites, live application routes, staging environments, production pages, preview deployments, and externally hosted UI references when the user asks to inspect or assess a live URL.

Trigger this mode for requests such as:
- `canlı sitede erişilebilirlik değerlendirmesi yap`
- `bu URL'i accessibility açısından incele`
- `siteyi canlıda test et`
- `evaluate this live page for accessibility`
- `audit this production page`
- `review the live experience, not just the HTML`

Treat these and similar requests as a live-site evaluation request inside review mode.

### Live-site evaluation objective

When evaluating a live page, inspect not only source markup but also the rendered, interactive experience where possible:
- page structure after render
- keyboard flow and focus movement
- interactive state changes
- modals, drawers, menus, carousels, filters, and async UI
- dynamic announcements and `aria-live` behavior
- visible focus, layout clipping, and zoom or reflow issues
- control naming and state exposure in the runtime UI

### Live-site evaluation workflow

When a live URL is provided or clearly implied:
1. Open or fetch the live page using the best available browser path.
2. Record what was directly observed from the rendered UI.
3. Record what was only inferred from DOM or source.
4. Inspect primary landmarks, headings, forms, dialogs, navigation, and other relevant structures.
5. Check keyboard reachability and focus order for the target flow where feasible.
6. Check runtime state announcements for actions that should notify assistive technology users.
7. Check whether the visible UI matches the semantic model exposed to assistive technologies.
8. Report environment limitations explicitly when interaction depth is blocked.

### Live-site evidence rules

When reviewing a live site, collect and report evidence from as many of these sources as the environment allows:
- rendered DOM
- browser snapshot or page structure view
- screenshot evidence when capture works
- keyboard interaction results
- network or runtime observations when relevant to accessibility state changes
- fetched source only as a fallback, not as the only truth when rendering differs

If browser interaction is partially blocked:
- continue with the best fallback path
- state exactly which layers were observed directly
- state which conclusions are inferred rather than confirmed

### Live-site confidence labeling

For live evaluations, the skill should be able to label findings with confidence such as:
- confirmed in rendered UI
- confirmed in source / DOM only
- likely runtime risk
- unverified due to environment limitation

Do not present a source-only issue as a rendered-runtime defect unless that runtime behavior was actually observed.

### Live-site interaction coverage

When relevant to the requested surface, evaluate:
- initial page load state
- opened overlays and closed overlays
- expanded and collapsed sections
- loading, empty, success, and error states
- add-to-cart, compare, favorite, filter, sort, search, and pagination flows
- carousels and auto-updating areas
- locale switching or translated status messages

If not all states could be reached, list the missing states as unverified coverage.

### Screenshot and visual evidence rules

If screenshot capture works:
- use screenshots as supporting evidence, not as a substitute for DOM and interaction analysis
- tie screenshots to specific findings when useful

If screenshot capture does not work:
- do not stop the review
- continue with live DOM, browser snapshot, fetched HTML, and interaction evidence as available
- explicitly note that screenshot evidence was unavailable

### Live-site report expectations

When the user asks for a live-site accessibility evaluation, the output should ideally include:
- evaluated URL
- date of evaluation
- environment used for inspection
- interaction depth achieved: source only, rendered DOM, partial interaction, full interactive smoke test
- findings ordered by severity
- confirmed versus inferred distinctions
- remaining verification gaps

### Live-site HTML report support

If the user asks for an HTML report for a live-site evaluation, include these extra metadata fields when available:
- evaluated URL
- environment: production, staging, preview, local, unknown
- rendered inspection path used
- screenshot capture status
- interaction depth
- verification limitations

### Live-site anti-pattern warning

Do not claim that a live page is accessible, compliant, or production-ready merely because:
- the source contains ARIA attributes
- the page visually looks orderly
- a screenshot appears clean
- a fetch of the HTML shows expected semantics

Live accessibility evaluation must prefer rendered and interactive evidence over source-only optimism.

### Review surfaces this skill should handle well

This review mode should cover at least:
- product cards
- add-to-cart flows
- compare flows
- wishlist or favorites flows
- navigation menus
- carousels and swipers
- forms and validation
- dialogs, drawers, and popovers
- tables and grids
- footers and large nav structures
- multilingual and locale-switching UI

### Review-mode escalation

If the user asks for:
- `incele`
- `audit et`
- `review yap`
- `WCAG açısından değerlendir`
- `erişilebilirlik sorunlarını çıkar`

then default to a code-review style accessibility audit with findings first, rather than immediately editing code.

## Required workflow

1. Detect the stack before proposing or writing UI.
2. Inspect local files to determine whether the project uses React, static HTML/CSS/JS, templates, extensions, server-rendered pages, or generated HTML.
3. Reuse the current stack unless the user explicitly asks for a migration.
4. Build semantic HTML first, then CSS, then JS behavior.
5. Use ARIA only when native HTML cannot express the interaction correctly.
6. Design and code to WCAG 2.2 AA by default.
7. Treat all applicable WCAG 2.2 Level A and AA success criteria as an implementation and verification scope, not a slogan.
8. Run or wire automated `axe-core` checks where the stack allows it.
9. Verify static and dynamic states: keyboard flow, focus visibility, naming, contrast, target size, errors, responsiveness, language metadata, motion behavior, async updates, overlays, and live announcements.
10. Verify the experience against at least the persona matrix in this skill before calling the work production-ready.
11. Explain any remaining accessibility risk, unsupported criterion, or unverified area.

## Production-ready delivery bar

Do not describe UI work as production-ready unless all of these are true:
- the implementation follows the existing stack or a justified minimal extension
- semantics, labels, names, states, and focus behavior are implemented in shipped code, not left as notes
- keyboard-only operation is complete for all primary and secondary flows touched by the change
- reduced-motion behavior is implemented where motion, animation, or auto-updating content exists
- text scaling, reflow, and responsive behavior were considered for the affected surfaces
- automated accessibility checks were run or explicitly wired for later execution
- at least a targeted manual review was performed for the affected interaction states
- unresolved issues are called out as blockers or known gaps, not silently deferred

Production-ready output should usually include:
- implementation code
- test or audit wiring when feasible
- clear verification notes
- residual-risk notes only for items that genuinely could not be validated in the current environment

When the user asks for planning or handoff instead of immediate code changes, production-ready output should usually include:
- a scoped implementation breakdown
- explicit accessibility acceptance criteria
- dependencies and sequencing
- QA and audit tasks
- Jira-ready tasks when requested

## Jira task output mode

When the user asks for Jira tasks, implementation tickets, backlog items, epic breakdowns, or handoff-ready delivery plans, this skill must produce the work in a Jira-friendly structure instead of a loose checklist.

### Output rule

Do not output vague bullets such as "make accessible" or "improve keyboard support." Every task must be implementable by an engineer or QA person without needing to infer the real work.

### Required task structure

For each Jira task, include:
- task title
- task type when inferable: Epic, Story, Task, Sub-task, Bug, Spike
- objective
- scope
- implementation details
- accessibility requirements
- dependencies or blockers
- acceptance criteria
- QA notes
- definition of done

When useful, also include:
- priority
- estimate
- affected platforms: web, mobile web, extension, Android, iOS, Flutter
- affected states: default, loading, error, success, modal, expanded, filtered, paginated
- analytics or telemetry implications
- localization implications

### Writing rules for Jira tasks

- Use concrete engineering language tied to the detected stack and UI surface.
- Break work by deliverable boundary, not by abstract principle.
- Separate implementation tasks from QA/audit tasks when that separation improves execution clarity.
- Include accessibility work inside the relevant implementation tasks instead of isolating all accessibility into one catch-all ticket, unless the user explicitly wants a dedicated audit ticket.
- Reference WCAG-sensitive behaviors directly where they affect implementation, such as focus management, accessible names, keyboard support, live regions, target size, reduced motion, reflow, and validation errors.
- Include dynamic states and regression scope, not just the default happy path.
- If work spans multiple surfaces, split tasks by surface or component area.
- If the request is broad, create one epic and then child stories/tasks beneath it.
- If estimates are requested but uncertain, label them as rough estimates.

### Acceptance criteria rules

Acceptance criteria must be testable and specific.

Prefer criteria like:
- keyboard users can open, operate, and close the component without a trap
- visible focus remains clear and unobscured at all supported breakpoints
- screen readers announce the component name, state, and runtime status updates correctly
- text and controls meet WCAG 2.2 AA contrast and target-size expectations for the affected UI
- reduced-motion preferences are respected for non-essential animation
- empty, loading, success, and error states remain accessible

Avoid criteria like:
- accessibility is improved
- component is user friendly
- UI matches WCAG

### Jira formatting template

Use this template shape unless the user asks for another format:

```md
Title: [clear task title]
Type: [Story/Task/Sub-task/Bug/Spike]
Objective:
[1 short paragraph]

Scope:
- ...
- ...

Implementation details:
- ...
- ...

Accessibility requirements:
- ...
- ...

Dependencies / blockers:
- ...

Acceptance criteria:
- ...
- ...

QA notes:
- ...
- ...

Definition of done:
- ...
- ...
```

### Jira decomposition heuristics

Use these defaults unless the repo context suggests a better split:
- component build or refactor
- styling and responsive behavior
- keyboard and focus behavior
- screen reader semantics and announcements
- form validation and error handling
- localization and text review
- automated accessibility checks
- manual QA and assistive technology validation

For larger work items, group tasks across:
- foundation and architecture
- component implementation
- integration with app state and data
- accessibility verification
- regression and release readiness

## Persona coverage rule

When using this skill, explicitly design and review for these user perspectives whenever they intersect the changed UI:
- blind screen reader users
- low-vision users who zoom, enlarge text, or use screen magnification
- keyboard-only users
- users with limited fine motor control, tremor, or limited reach
- users who rely on switch, voice, or alternate input methods
- users with vestibular sensitivity or reduced-motion needs
- users with cognitive or attention-related load sensitivity
- deaf and hard-of-hearing users when the UI includes audio, alerts, captions, transcripts, or multimedia instructions

Do not claim full disability coverage in the abstract. Instead, map the changed UI to the relevant personas and verify the affected interaction model for each.

### Persona review matrix

Use this matrix as a minimum review lens:

- blind screen reader users: structure, accessible names, landmarks, heading order, status messages, dialog behavior, form errors, meaningful link and button purpose
- low-vision users: zoom at 200% and 400% equivalent, text spacing, reflow, contrast, focus visibility, non-obscured focus, scalable controls, no clipped content
- keyboard-only users: full reachability, logical tab order, no traps, predictable shortcuts, visible current location, reliable escape and close behavior
- motor-limited users: target size, spacing between targets, no drag-only operation, no precision-only gestures, enough time, no accidental activation patterns
- voice and alternate input users: stable visible labels, consistent control names, no hidden-only commands, no gesture-exclusive tasks
- vestibular-sensitive users: reduced motion support, no essential autoplay, no parallax or motion-heavy transitions required for comprehension
- cognitive-load-sensitive users: plain language, clear hierarchy, consistent navigation, explicit errors, progress cues, low-surprise interactions, recoverable actions
- deaf and hard-of-hearing users: captions, transcripts, visible equivalents for audio alerts, no sound-only instructions, synchronized media controls

## WCAG 2.2 coverage protocol

This skill must treat WCAG 2.2 coverage as a review protocol over all applicable Level A and AA success criteria, not only the commonly broken ones.

Load [wcag-2-2-coverage-map.md](references/wcag-2-2-coverage-map.md) when:
- the task explicitly asks for WCAG 2.2 completeness or coverage mapping
- the UI change is broad enough that a full criterion-routing pass is warranted
- you are doing a production-readiness review, audit, PR review, or acceptance check
- you need quick routing from a UI surface such as forms, dialogs, carousels, data tables, navigation shells, or media into the most relevant criteria

Required behavior:
- identify which success criteria are applicable to the changed experience
- implement against all applicable criteria
- verify the criteria through automation, manual inspection, or explicit reasoning tied to the changed code
- call out criteria that are not applicable instead of ignoring them
- call out criteria that remain unverified instead of implying complete conformance

For substantial UI work, group review thinking at least across:
- perceivable: alternatives, adaptable structure, distinguishability, contrast, reflow, text spacing, orientation, input purpose
- operable: keyboard access, enough time, seizures and motion safety, navigability, focus, target size, dragging alternatives, pointer alternatives
- understandable: readable text, predictable behavior, form help, error prevention, redundant entry, authentication accessibility
- robust: valid semantics, name-role-value integrity, assistive-technology compatibility, status message exposure

Do not reduce WCAG review to a short checklist if the UI change is broad. Expand the review depth to match the interaction surface.

## Stack detection rules

Inspect these first when relevant:
- `package.json`
- `tsconfig.json`
- lockfiles
- app entry files
- component directories
- template directories
- browser extension manifest and popup files
- existing CSS architecture or design tokens
- current accessibility tooling such as `axe-core`, Playwright, Cypress, Jest, Vitest, Storybook, or CI audit scripts
- state libraries, router setup, async data layer, and UI primitives already used by the repo
- Android modules, `app/src/main`, Jetpack Compose usage, XML layouts, and custom `View` implementations when the repo includes Android surfaces
- Flutter modules, `lib/`, widget trees, routing, semantics usage, and platform accessibility test surfaces when the repo includes Flutter UI
- iOS modules, SwiftUI views, UIKit screens, storyboards, XIBs, and custom accessibility code when the repo includes Apple platform UI

Then choose the least invasive implementation path:
- If the repo already uses React, stay in React.
- If the repo is static HTML/CSS/JS, do not add React just to style UI.
- If the repo generates HTML from server code, preserve that generation path.
- If the repo is a browser extension popup/options page, prefer the current runtime constraints over introducing a bundler unless explicitly requested.
- If the repo already has an accessibility audit path, extend it instead of creating a second competing path.

## Browser restriction fallback protocol

When this skill needs live site inspection, screenshots, or interactive browser verification and the primary browser automation path is blocked by environment restrictions, permission issues, Playwright MCP startup failures, browser profile locks, or sandboxed filesystem paths, do not stop at the first failure.

### Required fallback order

Try these in order until one works well enough for the task:

1. primary browser automation path already available in the session
2. project or user-scoped Playwright CLI / wrapper script
3. local static or HTTP preview plus non-MCP browser checks
4. direct HTML fetch, DOM inspection, and source-based reconstruction
5. web search + page fetch + cited structural inference when a full live session is impossible

On Windows, prefer a user-writable PowerShell wrapper for the secondary browser path, for example:
- `C:\\Users\\<user>\\.codex\\skills\\playwright\\scripts\\playwright_cli.ps1`

Treat that PowerShell wrapper as the standard secondary browser execution path when:
- the in-app browser session is closed or unstable
- screenshot tooling fails before navigation
- the environment still has `node` / `npm` / `npx`
- a rendered smoke check is still worth attempting before falling back to raw fetches

### Implementation rule

If browser automation fails, explicitly switch to a fallback path and continue the task. Do not present the first browser failure as the end of the task unless every practical fallback has failed.

### Windows-specific fallback guidance

If a browser tool attempts to create state, cache, or working directories in restricted locations such as `C:\\Windows\\System32`, prefer a user-writable override strategy when possible.

Prefer these recovery patterns:
- use user-writable working directories under the workspace or `C:\\Users\\<user>\\.codex\\tmp`
- use local HTTP preview servers for static demos
- fetch the rendered page over HTTP when the local file renders correctly in a preview server
- use `curl` or equivalent to validate returned HTML and encoding
- inspect DOM structure from fetched source when screenshots are unavailable

### Screenshot fallback rule

When the user asks for a screenshot and direct screenshot capture is blocked:
- first try an alternate browser automation path if available
- if still blocked, continue by inspecting the live page HTML/source and clearly state that screenshot capture was blocked by the environment
- if helpful, describe the inferred visual structure and cite the source page
- do not falsely claim that a screenshot was captured

### Fidelity rule for reference-driven UI work

When reconstructing a live site without full browser control:
- prefer observed DOM structure, text hierarchy, action labels, and pricing/promo layout from fetched source
- clearly label any visual inference as inference
- preserve only the patterns relevant to the requested component, not the entire page
- if exact pixel parity is impossible, prioritize interaction parity and accessibility correctness

### Reporting rule

When a fallback path is used, report:
- which browser path failed
- which fallback path was used
- whether screenshots were captured or not
- what was directly observed versus inferred

### Practical browser-use integration rule

If the user asks to:
- open a browser block
- add browser-use style integration
- enable better live-site inspection tooling

interpret that as a request to wire and prefer a secondary local browser automation path before source-only fallback.

This integration improves coverage but does not guarantee bypass of third-party CDN, WAF, or anti-bot defenses. If the live site still returns an access-block page under the secondary browser path, report that truthfully and continue with the strongest remaining evidence path.

### WAF mitigation strategy rule

When a live site returns a CDN/WAF block page under default automation settings, this skill may attempt a small, truthful set of compatibility-oriented browser/session strategies before giving up:

- try a mainstream installed browser channel such as Chrome or Edge instead of a bundled default
- set a realistic Windows browser user agent for the selected channel
- set locale and language headers that match the expected market, such as `tr-TR` and `Accept-Language: tr-TR,tr;q=0.9,en-US;q=0.8,en;q=0.7` for Turkish market sites
- use a fresh context and, if needed, a persistent user-writable context directory
- compare headless and headed behavior when the environment allows it
- wait for `domcontentloaded` first, then for a short stabilization period before concluding the page is blocked

These are compatibility and rendering strategies, not stealth guarantees. Do not claim universal bypass behavior.

### WAF mitigation reporting rule

If these strategies are attempted, report:
- which combinations were tried
- which combination returned a real page versus a block page
- whether the working result came from rendered browser evidence or source-only evidence
- whether the result appears stable enough for accessibility review

### Site-specific access strategy rule

When live-site evaluation is blocked, unstable, or only partially reachable, this skill should not treat all sites the same.

It must determine the most likely access-limitation pattern first, then choose a matching strategy.

Common access-limitation patterns include:
- CDN or WAF block pages
- market or locale-sensitive delivery
- referer-sensitive routing
- session-sensitive or cookie-gated rendering
- login-gated pages
- bot-sensitive dynamic pages that differ between source and rendered DOM
- rate-limited or intermittently blocked paths

### Site-specific strategy selection workflow

Before escalating or giving up, evaluate:
1. Is the block global to the domain or only on specific paths?
2. Does the homepage work while deep links fail?
3. Does changing browser channel affect the result?
4. Does locale or `Accept-Language` affect the result?
5. Does adding a same-site referer affect the result?
6. Does a fresh isolated session behave differently from a reused session?
7. Is the site reachable in rendered form but not through raw fetch?

Then choose the smallest strategy set that fits the observed pattern.

### Strategy matrix

Use these strategy families depending on the site behavior:

- WAF-like block:
  - try real installed browser channels
  - try market-appropriate locale and language headers
  - try same-site referer
  - use fresh isolated contexts

- Homepage works, deep pages fail:
  - test deep pages with same-site referer
  - test route entry by navigating from the homepage versus direct URL load
  - treat deep-link blocks as path-sensitive access behavior, not full-domain failure

- Market-sensitive content:
  - align locale, language headers, and browser region expectations with the site market
  - report the market profile used for successful access

- Session-sensitive pages:
  - compare fresh session versus reused session
  - preserve the session that produces stable access for the audit batch

- Login-gated content:
  - do not fake authenticated access
  - report the login boundary and review only what is actually reachable

- Source/render mismatch:
  - prefer rendered DOM evidence over raw fetch
  - report source-only findings separately when rendering cannot be verified

### Domain memory rule

When a site-specific strategy works for a domain, this skill should be able to remember and reuse that pattern in future runs, such as:
- preferred browser channel
- working locale
- working `Accept-Language`
- whether referer is needed
- whether fresh sessions are more reliable than reused sessions

This remembered pattern should be treated as a domain-specific access profile, not as a universal browser rule.

### Access profile example

The skill should be able to reason in a profile shape like:

```text
Domain: www.example.com
Preferred browser: Edge
Locale: tr-TR
Accept-Language: tr-TR,tr;q=0.9,en-US;q=0.8,en;q=0.7
Referer needed: yes
Fresh isolated session: yes
Direct deep-link load: unstable
Homepage-first navigation: preferred
```

Equivalent natural-language reasoning is also valid.

### Reporting rule for site-specific strategies

When a domain-specific access strategy is chosen, report:
- the block pattern that was observed
- the selected strategy
- whether the strategy was successful
- whether the result is stable enough for a multi-page accessibility review
- what remained unreachable despite the strategy

## Production UI principles

### 1. Start with semantics

Default to:
- headings in logical order
- `header`, `nav`, `main`, `aside`, `section`, `footer` where appropriate
- real `button` for actions
- real `a` for navigation
- real `table` for tabular data
- real `form`, `label`, `fieldset`, `legend`, `input`, `select`, `textarea` for forms

Do not use clickable `div` or `span` when a native element exists.

## ARIA implementation rules

ARIA is a repair and augmentation layer, not a substitute for correct HTML.

Use ARIA only when native HTML cannot express the interaction, relationship, status, or state correctly enough on its own.

### Core ARIA decision rule

Before adding any ARIA attribute, answer these in order:
- can native HTML solve this without ARIA
- if not, is the missing need role, name, state, property, relationship, or live announcement
- if ARIA is added, is the corresponding keyboard and focus behavior also implemented
- is the resulting accessibility tree simpler and clearer than the non-ARIA version

If the answer to the first question is yes, do not add ARIA just for explicitness.

### First rule of ARIA

Do not re-create semantics that native elements already provide.

Avoid patterns like:
- `div role="button"` when a real `button` works
- `div role="link"` when a real `a` works
- `div role="checkbox"` when a real `input type="checkbox"` works
- `div role="textbox"` when a real `input` or `textarea` works
- `div role="table"` when a real `table` works

### Native-first mapping guidance

Prefer these native elements before ARIA:
- actions: `button`
- navigation: `a`
- disclosure summary: `button` plus controlled region
- binary selection: `input type="checkbox"`
- single choice: `input type="radio"`
- tabular data: `table`
- grouped form controls: `fieldset` and `legend`
- progress: `progress`
- status text: visible text plus `role="status"` only when runtime announcement is needed

### Region and landmark directive

This skill must create correct page and component structure using landmarks and regions only where they improve orientation.

Use native landmark elements first:
- `header`
- `nav`
- `main`
- `aside`
- `footer`
- `form`
- `section` with an accessible name when it is a real thematic section

Use `role="region"` only when:
- the content is important enough to deserve quick navigation by assistive technology
- the region has a clear accessible name via `aria-labelledby` or `aria-label`
- a native landmark does not already express the purpose well enough

Do not create many generic regions just because a component has a border or heading.

### Landmark rules

- Use one primary `main` landmark per page or document view.
- Use `nav` only for actual navigation collections.
- Use `aside` for related but secondary content, such as compare summaries, filters, or supporting information.
- Use `form` for interactive search, checkout, login, filter, or configuration submissions where form semantics matter.
- Use `section` when the content has its own heading and represents a meaningful subsection of the page.
- Use `article` for self-contained content units such as product cards, posts, listing items, or feed entries when appropriate.

### Region naming rules

If you use `section`, `form`, `aside`, or `role="region"` as a navigable landmark-like surface, ensure it has an accessible name.

Prefer:
- visible heading + `aria-labelledby`
- `aria-label` only when a visible heading is not practical

Do not:
- create unnamed regions
- create multiple regions with the same ambiguous name
- label a region with text that does not match its real purpose

### When to use `role="region"`

Good uses:
- compare summary panel that updates independently
- mini-cart summary area that users may want to revisit
- persistent filter summary
- results summary area for dynamic search
- complex dashboard panel with its own heading and interaction context

Avoid `role="region"` for:
- every card in a product grid
- decorative panels
- short static text blocks
- simple wrappers that already sit inside a clearly named section

### Grouping rules

Use:
- `fieldset` + `legend` for related form controls
- `role="group"` only when native grouping is insufficient
- `article` for repeated self-contained content
- lists for repeated peer items

Do not use `role="group"` as a generic wrapper for styling.

### Dynamic-region rules

If a region updates dynamically:
- keep its accessible name stable
- use live-region behavior only when the change needs announcement
- do not combine `role="region"` and live behavior unless both purposes are justified
- ensure updated content remains understandable when revisited later by landmark or browse navigation

### E-commerce region guidance

For e-commerce surfaces, prefer this structure when applicable:
- page content: `main`
- product listing area: named `section`
- each product tile: `article`
- compare summary or mini-cart side surface: named `aside`
- dynamic compare content or cart summary area: named `region` only if revisitable orientation meaningfully improves navigation
- filter controls: `form` or named `section` depending on submission behavior

### Region anti-patterns

Do not ship:
- multiple nested unnamed landmarks
- multiple `main` landmarks in the same page context
- `role="region"` on small helper text or every component shell
- region labels like `panel`, `container`, or `section`
- region overload that makes screen-reader landmark navigation noisy

### Region verification checklist

Whenever you add a landmark or region, verify:
- it has a real navigational purpose
- it has a clear accessible name if needed
- it is not redundant with a native ancestor landmark
- the page is still easy to navigate by landmarks
- repeated content items use list/article semantics before region semantics

### ARIA usage categories

Use ARIA mainly in these categories:
- accessible naming when native labeling is insufficient
- state exposure for custom widgets
- relationship wiring between controls and controlled content
- runtime status and announcement behavior
- composite widget semantics when native HTML truly cannot cover the interaction

### Accessible name rules

Use accessible names in this priority order unless the component type requires otherwise:
- visible text associated through native HTML
- `label` / `htmlFor`
- `aria-labelledby`
- `aria-label` as a last-resort naming override

Rules:
- prefer `aria-labelledby` over `aria-label` when a visible label already exists
- use `aria-label` mainly for icon-only controls or where visible text cannot be reused
- do not create conflicting names with visible text and ARIA names pointing to different meanings
- the spoken name should stay aligned with the visible label for voice and switch users

### State and property rules

Only use state and property attributes that match the real behavior.

Common mappings:
- toggle buttons: `aria-pressed`
- expandable controls: `aria-expanded`
- selected items in widgets: `aria-selected`
- current item in navigation/step context: `aria-current`
- modal dialogs: `aria-modal="true"` when the interaction is truly modal
- temporarily busy regions: `aria-busy="true"`
- invalid fields: `aria-invalid="true"` only when actually invalid
- required custom form controls: `aria-required="true"` only when native `required` is unavailable

Do not misuse:
- `aria-checked` on native checkboxes that already expose checked state
- `aria-selected` on things that are not part of a selectable composite pattern
- `aria-current` as a general highlight indicator
- `aria-expanded` on elements that do not control expandable content
- `aria-hidden="true"` on focusable or interactive elements

### Relationship rules

Use relationship attributes only when they describe a real and maintained connection.

Common patterns:
- `aria-labelledby` to reuse visible labels
- `aria-describedby` for supporting help text, constraints, or error summaries
- `aria-controls` only when the relationship is meaningful and stable
- `aria-owns` almost never; avoid unless the accessibility tree truly requires ownership remapping

Rules:
- if you use `aria-describedby`, keep the referenced help text concise and relevant
- if you use `aria-controls`, do not assume assistive technologies will announce or act on it by itself
- do not chain large blocks of unrelated help text through `aria-describedby`

### Live region rules

Use the smallest correct live-region pattern.

Prefer:
- `role="status"` or `aria-live="polite"` for non-blocking updates
- `role="alert"` for important non-modal errors requiring immediate announcement
- `aria-busy` for larger async updates that temporarily invalidate the region

Rules:
- do not use live regions for every visual change
- do not spam repeated updates into the same region
- do not move focus just to announce a passive status message
- clear and replace live-region text predictably

## E-commerce ARIA live implementation directives

When this skill is used for e-commerce UI, treat runtime feedback as a first-class accessibility requirement.

This especially applies to:
- add to cart
- add to compare
- remove from compare
- add to favorites or wishlist
- quantity updates
- stock availability changes
- coupon apply/remove
- shipping estimate refresh
- validation after product option changes
- modal confirmations, mini-cart updates, and toast notifications

### Core directive

If an action changes cart state, compare state, availability, pricing context, or purchase readiness without a full page reload, the user must receive equivalent programmatic feedback.

Use live regions for status feedback.
Use focus movement only when the interaction actually changes context.
Do not use focus movement as a replacement for correct live announcements.

### Recommended status patterns by scenario

Use `role="status"` or `aria-live="polite"` for:
- product added to cart
- product removed from cart
- compare list updated
- wishlist updated
- quantity increment or decrement result
- shipping or installment recalculation completed
- stock message refresh
- non-blocking promotional updates

Use `role="alert"` only for:
- blocking product option errors
- stock failure after attempted add to cart
- compare limit exceeded
- invalid variant combinations preventing purchase
- payment or shipping errors that need immediate attention

Use `role="dialog"` or `role="alertdialog"` only when:
- a modal truly opens and changes interaction context
- focus is intentionally moved into the modal
- background content becomes inert for the duration of the modal

### Add-to-cart implementation rule

When the user activates "Add to cart":
- keep focus on the triggering button unless a real modal or drawer opens
- announce the result in a polite live region
- include enough context in the message to identify the product and result
- if quantity changes as part of the action, include the updated quantity when useful
- if price-affecting options are selected, ensure the final selected variant is what gets announced

Good message shape:
- product name + action result
- optional quantity or cart count

Example:
- `Arcelik 270475 MB sepete eklendi. Sepette 2 ürün var.`
- `Arcelik 270475 MB added to cart. Cart now contains 2 items.`

### Compare-list implementation rule

When the user adds or removes a product from compare:
- announce the exact product name
- announce the new selection count
- announce compare-limit failures immediately when the limit is exceeded
- keep unchecked compare controls disabled only when the limit is reached and explain that state in visible and programmatic text

Good message shape:
- product name + added/removed + current compare count

Example:
- `270475 MB karşılaştırma listesine eklendi. 2 / 3 ürün seçildi.`
- `270475 MB added to compare. 2 of 3 products selected.`

### Mini-cart, drawer, and modal rule

If add-to-cart opens a mini-cart or drawer:
- move focus only if the drawer becomes the active interaction context
- label the drawer or modal with `aria-labelledby` or `aria-label`
- announce the state change only once; avoid duplicate toast plus modal plus status spam
- restore focus logically when the drawer closes

If the interaction stays inline and only a toast appears:
- do not move focus to the toast
- expose the toast through a polite live region or `role="status"`
- ensure the visible toast message and the announced message do not materially conflict

### Button and link naming rule for live-update flows

For actions that produce runtime state changes, the accessible name must stay explicit and stable.

Prefer names like:
- `Sepete ekle`
- `Karşılaştırmaya ekle`
- `Favorilere ekle`
- `270475 MB ürününü karşılaştırmaya ekle`

Avoid vague names like:
- `Ekle`
- `Devam et`
- `Seç`

When multiple identical action buttons exist in a product grid:
- visible text may stay short
- accessible naming should include product identity if ambiguity would exist in assistive technology output
- prefer `aria-label` or `aria-labelledby` that composes visible button text with product title

### Link naming rule

Links that open product details, shipping info, size guides, campaign details, or compare pages must make destination purpose clear.

Good:
- `270475 MB ürün detaylarını aç`
- `Teslimat seçeneklerini görüntüle`
- `Karşılaştırma listesini görüntüle`

Avoid:
- `Detay`
- `Buraya tıklayın`
- `İncele` when many identical links exist with no product context in the accessible name

### Multi-language live-message architecture

Live-region text must be localized through the same i18n system as visible UI text.

Do not:
- hardcode Turkish live messages into otherwise English UI
- concatenate fragments in a way that breaks grammar across languages
- localize visible text but forget runtime announcements

Required architecture:
- store live-region messages in locale dictionaries
- support interpolation for product name, quantity, compare count, cart count, and error reason
- ensure `lang` and `dir` remain correct when locale changes at runtime
- keep visible labels and announced messages meaningfully aligned in every locale

### Multi-language message format guidance

Use parameterized message templates.

Recommended examples:

```ts
tr: {
  addToCartSuccess: "{product} sepete eklendi.",
  addToCartSuccessWithCount: "{product} sepete eklendi. Sepette {count} ürün var.",
  compareAdded: "{product} karşılaştırma listesine eklendi. {count} / {limit} ürün seçildi.",
  compareRemoved: "{product} karşılaştırma listesinden çıkarıldı. {count} / {limit} ürün seçildi.",
  compareLimitReached: "En fazla {limit} ürün karşılaştırılabilir.",
  cartErrorOutOfStock: "{product} sepete eklenemedi. Ürün stokta yok."
}

en: {
  addToCartSuccess: "{product} added to cart.",
  addToCartSuccessWithCount: "{product} added to cart. Cart now contains {count} items.",
  compareAdded: "{product} added to compare. {count} of {limit} products selected.",
  compareRemoved: "{product} removed from compare. {count} of {limit} products selected.",
  compareLimitReached: "You can compare up to {limit} products.",
  cartErrorOutOfStock: "{product} could not be added to cart. This item is out of stock."
}
```

If RTL locales are supported, ensure:
- punctuation and interpolation still read naturally
- live messages remain short and well-formed
- `dir="rtl"` is applied where appropriate

### Modal and inline feedback decision tree

Use this decision rule:
- if the action changes context: modal/drawer + focus management + clear labeling
- if the action does not change context: live region and optional toast, but no forced focus move
- if the action fails and requires immediate correction: `role="alert"` or clearly announced inline error
- if the action succeeds quietly: `role="status"` or `aria-live="polite"`

### Implementation examples

#### Add to cart with inline status

```html
<button type="button" aria-describedby="cart-help">
  Sepete ekle
</button>
<p id="cart-help">Ürün, sayfa yenilenmeden sepete eklenir.</p>
<p id="cart-status" role="status" aria-live="polite" aria-atomic="true"></p>
```

```js
// Sepete ekleme sonucu odağı taşımadan duyurulur.
// Kullanıcı ürün kartında kalır ve sonuç bilgisi kaybolmaz.
// WCAG 2.2 - 4.1.3 Status Messages.
cartStatus.textContent = `${productName} sepete eklendi.`;
```

#### Compare update with count

```html
<p id="compare-status" role="status" aria-live="polite" aria-atomic="true"></p>
```

```js
compareStatus.textContent =
  `${productName} karşılaştırma listesine eklendi. ${count} / ${limit} ürün seçildi.`;
```

#### Compare limit error

```html
<p id="compare-error" role="alert"></p>
```

```js
compareError.textContent = `En fazla ${limit} ürün karşılaştırılabilir.`;
```

### Anti-patterns for e-commerce live regions

Do not:
- announce both toast text and a separate identical status message in a noisy loop
- move focus to the mini-cart for every add-to-cart action unless it truly opens as the new active context
- use `role="alert"` for ordinary success messages
- announce generic messages like `başarılı` or `eklendi` without the product context
- update live-region text on every render instead of only on meaningful state transitions
- leave stale error text in `role="alert"` containers after the state has been resolved

### Verification checklist for e-commerce runtime feedback

When implementing these patterns, verify:
- the add-to-cart action produces a meaningful announced success or failure
- compare add/remove announces product name and updated count
- compare limits are both visible and programmatically announced
- focus stays stable unless context genuinely changes
- modal/cart drawer labeling is correct
- runtime messages are localized in every supported locale
- screen reader output is concise, not repetitive
- repeated actions update the live region reliably

### Composite widget rules

If a custom composite widget is unavoidable, ARIA must be paired with the correct keyboard model and state model.

Typical patterns requiring APG-aligned implementation:
- tabs
- accordion/disclosure groups
- menus and menu buttons
- comboboxes
- listboxes
- tree views
- grids
- carousels
- dialogs and alertdialogs

For these patterns:
- implement role, state, and property exposure together
- implement the required arrow-key and tab behavior
- ensure focus management matches the pattern
- ensure the active/selected/current state is always programmatically exposed

Do not apply only the role without the behavior.

### Dialog and overlay ARIA rules

For modal dialogs:
- use `role="dialog"` or `role="alertdialog"` only when the overlay truly behaves as that pattern
- label the dialog with `aria-labelledby` or `aria-label`
- provide supporting description only when it materially helps
- use `aria-modal="true"` only for actual modal interactions
- trap focus only while the modal is active

Do not:
- mark a non-modal popover as a modal dialog
- use `alertdialog` for ordinary confirmations that do not require urgent interruption
- hide the background only from screen readers while leaving it interactive for keyboard users

### Forms and error ARIA rules

Prefer native form semantics first.

Use ARIA in forms mainly for:
- `aria-describedby` to connect help text or error text
- `aria-invalid` when a field is in an invalid state
- live announcement of submission outcomes or dynamic validation summaries

Rules:
- do not replace visible labels with placeholders and ARIA
- do not set `aria-invalid="true"` before validation or before the user can act
- error text referenced by `aria-describedby` must remain in sync with actual validation state

### Hidden content rules

Use hidden states carefully.

Rules:
- `aria-hidden="true"` removes content from assistive technology exposure; do not put it on focusable controls
- if content is visually hidden but still needed by assistive tech, use a proper visually-hidden utility instead of `display:none`
- if content is collapsed and not meant to be reachable, ensure both visual and accessibility states stay aligned

### ARIA comments rule in code

When ARIA is used for a non-obvious reason, add a brief comment explaining:
- why native HTML was insufficient
- which behavior the ARIA attribute exposes
- which keyboard/focus behavior must stay aligned with it
- the most relevant WCAG 2.2 criterion when helpful

### Common ARIA anti-patterns

Do not ship these without strong justification:
- role-only widgets with missing keyboard support
- `aria-hidden="true"` on active controls
- duplicate or conflicting accessible names
- `tabindex="0"` on many static elements just to make them discoverable
- positive `tabindex` values for focus ordering
- role changes that fight native semantics
- custom combobox/listbox/menu patterns implemented only partially
- `aria-live` regions that announce every keystroke or every render
- `aria-label` values that differ materially from the visible label

### ARIA verification checklist

Whenever ARIA is added, verify:
- role matches the actual interaction
- name is correct and stable
- state updates when the UI changes
- related ids resolve correctly
- keyboard behavior matches the role/pattern
- focus behavior matches the role/pattern
- no native semantic was unnecessarily overridden
- screen reader output is clearer, not more confusing

### 2. Build a system, not one-off styling

Create or extend a small system of:
- color tokens
- spacing scale
- type scale
- radius scale
- elevation rules
- state rules: default, hover, active, focus-visible, disabled, invalid, loading
- layout widths and breakpoints

Every repeated surface should derive from these tokens.

### 3. Consistency is a hard requirement

Keep these consistent across the UI:
- spacing rhythm
- heading patterns
- button hierarchy
- card structure
- form control height and density
- empty, loading, success, and error states
- icon sizing and label patterns
- dialog and drawer behavior

If a page introduces a new pattern, define it clearly and use it intentionally.

### 4. Enterprise quality bar

Prefer:
- obvious information hierarchy
- quiet defaults with clear emphasis points
- readable tables and filters
- explainable workflows
- durable states over decorative novelty
- explicit empty and error handling
- audit-friendly structure and naming

Do not ship visually noisy dashboards, low-contrast surfaces, or ambiguous actions.


## Encoding safety rules

Treat text encoding as a production requirement.

### Required rules

- Always preserve and emit UTF-8 for UI-facing source files unless the project already uses a different encoding and changing it would break the build.
- Do not introduce BOM unless the project already requires it.
- Do not rewrite files through tooling or shell flows that are likely to convert UTF-8 text into ANSI, Windows-1252, or mojibake.
- Preserve Turkish and other non-ASCII characters correctly in UI labels, translations, headings, aria labels, help text, and generated HTML.
- When generating HTML, keep `charset="utf-8"` in the document metadata or the equivalent response header.
- When generating server responses, ensure `content-type` includes `charset=utf-8` for HTML, JSON, JS, and text endpoints where relevant.
- When reading and rewriting files, prefer no-BOM UTF-8-safe paths and verify that special characters remain intact after writes.
- After UI generation or refactors, scan for mojibake patterns and fix them before considering the task complete.

### Verification steps

Check for broken text such as:
- `Ã`, `â€™`, `â€œ`, `Ä±`, `ÅŸ`, `Ã§`
- mixed-language corruption in titles, buttons, table headings, and aria text
- incorrect locale strings after serialization, template generation, or dashboard export

If the task touches multilingual UI, generated HTML, extension UIs, reports, or dashboard templates, explicitly verify:
- file encoding remained UTF-8
- visible text renders correctly in the browser
- `lang`, `dir`, and localized strings still match the selected locale

Do not ship interface changes with encoding corruption, even if the UI is otherwise functional.
## Multilingual architecture

Treat multilingual UI as architecture, not string replacement.

### Requirements

- Centralize strings in dictionaries or locale modules.
- Never scatter user-facing copy inline across many components unless the file is tiny and local-only.
- Support at least locale code, language code, and text direction.
- Design for multiple language families, including short and long Latin strings, agglutinative languages, CJK layouts, and RTL languages.
- Set document language with `html[lang]`.
- Set `dir` when a locale is RTL.
- Mark inline language changes with `lang` on the relevant element.
- Keep translation keys stable and descriptive.
- Support interpolation, pluralization, dates, times, and numbers with locale-aware formatting.
- Do not hardcode concatenated sentences that break in translation.
- Reserve room for text expansion.
- Avoid fixed-width controls that fail in German, Turkish, Arabic, or other longer localized strings.
- Keep icon-only actions labeled for assistive technology in every locale.
- Ensure runtime announcements, validation text, toasts, progress text, and loading messages are localized too.
- Verify that locale switching does not silently break `lang`, `dir`, focus, or screen reader announcements.

### Minimum architecture shape

Use something equivalent to:
- `locales/tr.ts`, `locales/en.ts`
- `i18n/index.ts` or `utils/i18n.js`
- `getDirection(locale)` returning `ltr` or `rtl`
- formatter helpers for `Intl.NumberFormat`, `Intl.DateTimeFormat`, and `Intl.PluralRules` when needed

### Copy rules

- Prefer plain language.
- Keep labels short and specific.
- Make error text actionable.
- Avoid culture-specific metaphors unless product-specific.
- Preserve meaning parity across locales.
- Ensure async state text is specific, such as loading, saving, uploaded, retrying, failed, or completed.

## WCAG 2.2 AA baseline

Design and implement to satisfy all applicable WCAG 2.2 Level A and AA success criteria for the work being changed. Do not claim legal certification; implement against the standard and report verification scope.

Pay special attention to these areas because they frequently break in product UI:
- text alternatives for informative and functional images
- semantic structure and relationships
- meaningful sequence
- color contrast
- reflow and zoom up to 400%
- keyboard access
- visible focus
- focus order and no unexpected focus loss
- descriptive labels, names, and instructions
- status messages and validation errors
- pointer target size and spacing
- drag alternatives
- no motion-only or hover-only critical access
- consistent navigation and identification
- language of page and language changes
- reduced motion support for non-essential animation

For new WCAG 2.2 criteria, explicitly check:
- `2.4.11 Focus Not Obscured (Minimum)`
- `2.4.12 Focus Not Obscured (Enhanced)` when feasible as a stretch target
- `2.4.13 Focus Appearance`
- `2.5.7 Dragging Movements`
- `2.5.8 Target Size (Minimum)`
- `3.2.6 Consistent Help`
- `3.3.7 Redundant Entry`
- `3.3.8 Accessible Authentication (Minimum)`
- `3.3.9 Accessible Authentication (Enhanced)` when feasible as a stretch target

## Dynamic accessibility integration

This skill must handle dynamic interfaces, not only static markup.

### Dynamic-state rule

Every meaningful UI state must be accessible as a first-class experience:
- initial load
- skeleton or loading state
- partial refresh
- optimistic update
- success state
- empty state
- validation failure
- server error
- offline or degraded state
- modal or drawer open state
- expanded or collapsed state
- filtered, sorted, paginated, or virtualized state

Do not validate only the default view. Validate the transitions and announcements too.

### Live regions and runtime messaging

Use the smallest correct pattern for announcements:
- `role="status"` or polite live regions for non-blocking status updates
- `role="alert"` for important non-modal errors that need immediate announcement
- `role="alertdialog"` only when interruption and response are required

Rules:
- Do not move focus for non-blocking status updates.
- Do not spam live regions with high-frequency updates.
- Batch or debounce repeated announcements when data updates rapidly.
- Keep messages short, localized, and action-oriented.
- If a status region is reused, replace content predictably so assistive technologies announce the change.

### Focus management during DOM updates

When DOM changes dynamically:
- preserve focus when the user's current control still exists and meaningfully remains active
- move focus intentionally when a new context opens, such as dialog, drawer, stepper step, route, or inline editor
- restore focus to a logical trigger after overlays close
- never drop focus onto `body`
- if content is removed while focused, move focus to the nearest logical successor
- if async updates insert content above the viewport, ensure focus and reading order do not become confusing

### Async loading and busy states

- Use visible loading indicators with text, not spinner-only feedback.
- Expose loading status programmatically when the user needs to know the system is busy.
- Use `aria-busy` on containers during multi-step updates when appropriate, and clear it when updates finish.
- Distinguish initial page load from incremental background refresh.
- If actions take time, reflect pending state on the triggering control and prevent duplicate submissions when appropriate.

### Overlays and transient UI

For modal dialogs, drawers, popovers, menus, and tooltips:
- choose the correct pattern for the job; do not make every popup a dialog
- keep keyboard interaction aligned with APG patterns
- ensure modal content makes background content inert for all users, not only screen reader users
- ensure dismiss controls are always reachable and visible
- ensure escape behavior is predictable when the pattern supports it
- if focus trapping is used, trap only while the overlay is active
- do not hide critical information in hover-only tooltips

### Composite widgets

For tabs, accordions, carousels, comboboxes, listboxes, menus, grids, trees, feeds, and custom pickers:
- prefer native elements when possible before creating a custom composite widget
- if building a custom composite widget, follow the corresponding APG pattern
- document keyboard commands when the interaction is not obvious
- ensure roving tabindex or active-descendant models are implemented correctly
- ensure selection state, expanded state, and current item state are programmatically exposed
- verify behavior in both keyboard and screen reader scenarios

### Infinite scroll, feeds, virtualization, and large data UI

- Prefer explicit pagination or load-more controls when they can simplify accessibility.
- If infinite scrolling is kept, provide a reliable accessible structure and visible progress feedback.
- For feeds, keep article boundaries, labels, and position metadata meaningful.
- For virtualized lists or tables, ensure the accessibility tree still communicates useful item context.
- Do not make keyboard users tab through unbounded item lists when a composite pattern or paging model is more appropriate.
- If rows or cards mount and unmount dynamically, test that focus and announcements remain stable.

### Data tables, grids, and sorting/filtering

- Use native `table` for static tabular data whenever possible.
- Use `grid` only when the interaction truly requires composite-widget behavior.
- Announce sorting changes, filter results, row additions, and inline edit outcomes.
- Keep sticky headers from obscuring focused cells or controls.
- Ensure column visibility toggles and row actions remain keyboard reachable.

### Form interactivity and validation flows

- Inline validation must not depend on color alone.
- If validation occurs on blur or input, ensure announcements are timely but not noisy.
- Associate error text to fields programmatically.
- Summarize blocking errors near the top for long forms, and preserve links or focus routing to invalid fields.
- Redundant entry should be avoided where the product flow permits.
- Multi-step forms must communicate current step, progress, and completion state.

### Motion, transitions, and state changes

- UI transitions must not be the only signal that content changed.
- Respect `prefers-reduced-motion` for drawers, modals, toasts, carousels, and page transitions.
- Auto-rotating or auto-advancing content must be pausable when applicable.
- Animations must not obscure focus indicators or delay essential announcements.

### Realtime and collaborative UI

For notifications, chat, logs, live dashboards, background sync, or collaborative cursors:
- separate critical alerts from routine updates
- allow users to review updates without losing context
- do not hijack focus for routine incoming content
- ensure timestamp, sender, and state labels are exposed in localized text
- throttle announcement noise in rapidly updating views

## axe-core verification workflow

Use `axe-core` as the default automated accessibility engine when the project stack supports browser-context execution.

### When to use it

- after meaningful UI changes
- before declaring UI work production-ready
- in E2E or browser-driven tests when available
- in local audit scripts or CI checks when the repo already has an audit path
- on dynamic states, not only the first render

### Implementation rules

- Prefer integrating `axe-core` into the repo's existing browser test flow instead of inventing a detached script.
- Run scans on real rendered states, not only on isolated markup strings.
- Scan every important state that becomes visible: initial page, dialogs, drawers, menus, tabs, validation errors, loading-complete state, post-submit state, filtered state, and async update state.
- Treat `violations` as defects to fix or consciously document.
- Treat `incomplete` results as manual review items, not as passes.
- Do not rely on automated checks as proof of full WCAG conformance.
- For dynamic interfaces, trigger state changes before scanning and verify the resulting DOM, focus, and announcements.

### Stack-specific guidance

- If the repo uses Playwright or another browser E2E runner, execute `axe.run()` in the browser context after the target UI is visible.
- If the repo uses component previews or Storybook-like rendering, run `axe-core` against those rendered states where supported by the existing toolchain.
- If the repo only has static HTML, inject `axe.min.js` into the rendered page or local preview instead of trying to audit raw source files.
- If the repo uses JSDOM-only tests, note that some checks are limited there; do not treat JSDOM scans as complete browser-equivalent coverage.
- If a flow depends on async data, waits, or transitions, scan only after the UI reaches the intended stable state.

### Reporting rules

Whenever you use this skill for code changes, report:
- whether `axe-core` was already present or newly wired
- where the scan ran
- which dynamic states were scanned
- whether any `violations` remained
- whether any `incomplete` items need manual review
- what manual checks still remain outside automation

## Accessibility implementation rules

## Accessibility comment guidance in generated code

When this skill generates or refactors code, it must add meaningful developer-facing comments in the code for accessibility-critical logic when those comments materially improve maintainability, reviewability, or future regression safety.

Do not add noisy comments for obvious markup or trivial styling. Add comments where a future engineer could otherwise remove, simplify, or break an accessibility behavior without understanding the consequence.

### Language rule for comments

The language of accessibility comments in generated code must match the language of the requested deliverable unless the user explicitly asks otherwise.

Examples:
- if the UI and handoff language are Turkish, comments should be in Turkish
- if the UI and handoff language are English, comments should be in English
- if the repository has an established comment language, prefer that language unless the user requests a different one

### Required comment content

For accessibility-relevant code paths, comments should explain as applicable:
- what the code is doing
- which user need it supports
- which WCAG 2.2 success criterion or criteria it relates to
- why this implementation was chosen instead of a simpler but less accessible alternative
- what can break if the behavior is removed or changed carelessly

Use comments to preserve intent, not to restate syntax.

### Where comments are expected

Add targeted comments when implementing or modifying:
- focus management
- keyboard interaction models
- live regions and status announcements
- dialog, drawer, menu, tabs, accordion, carousel, combobox, or other composite widget behavior
- form validation/error association
- reduced motion behavior
- target-size or pointer-alternative accommodations
- localization-sensitive accessibility attributes such as `lang`, `dir`, accessible names, and runtime announcements
- DOM updates that preserve screen reader context or prevent focus loss

### WCAG reference rule

When a comment explains a non-obvious accessibility behavior, include the most relevant WCAG 2.2 criterion reference where it helps future maintenance.

Prefer compact references such as:
- `WCAG 2.2 - 2.1.1 Keyboard`
- `WCAG 2.2 - 2.4.3 Focus Order`
- `WCAG 2.2 - 2.4.11 Focus Not Obscured (Minimum)`
- `WCAG 2.2 - 2.4.13 Focus Appearance`
- `WCAG 2.2 - 3.3.1 Error Identification`
- `WCAG 2.2 - 4.1.3 Status Messages`

Do not mechanically attach WCAG references to every comment. Use them for meaningful implementation decisions, especially where the code enforces behavior that is easy to regress.

### Comment style rules

- Keep comments close to the code they explain.
- Prefer short explanatory blocks above the relevant logic.
- Explain intent and user impact in plain language.
- Avoid legalistic or standards-dump comments.
- Avoid excessive multi-line comments on simple markup.
- If a behavior maps to multiple criteria, cite only the most relevant criteria unless multiple are genuinely needed for understanding.
- When the implementation follows an APG pattern or platform accessibility pattern, mention that pattern briefly if it helps future maintenance.

### Recommended comment template

Use a shape like this when appropriate:

```ts
// Keeps keyboard focus inside the active dialog while it is open and restores
// focus to the trigger on close. This prevents focus loss for keyboard and
// screen reader users. WCAG 2.2 - 2.1.1 Keyboard, 2.4.3 Focus Order.
```

Or:

```ts
// Bu canlı bölge, filtreleme sonrası sonuç sayısını ekran okuyucuya duyurur.
// Odağı taşımadan durum bilgisini iletir. WCAG 2.2 - 4.1.3 Status Messages.
```

### Minimum documentation expectation for non-trivial accessibility logic

If the code includes non-trivial accessibility logic, the generated output should usually contain at least some inline comments covering:
- focus behavior
- keyboard behavior
- dynamic announcements or state exposure

If the logic is especially complex, also add a short summary comment near the component or module entry point describing the accessibility model used by that component.

### Developer guidance rule

When comments are added for accessibility logic, they should help future developers answer:
- why does this code exist
- which users depend on it
- which WCAG behavior does it protect
- what should be preserved during refactors

The goal is not only accessible output, but output that remains accessible after future edits by engineers who did not author the original code.

## General code-comment guidance in generated UI code

When this skill generates or refactors UI code, it should also be capable of adding detailed developer-facing comments across HTML, CSS, and JavaScript when those comments materially improve maintainability, onboarding, review quality, or regression safety.

This applies beyond accessibility-only logic. The comments should help future developers understand:
- structure
- component intent
- state behavior
- layout strategy
- responsive rules
- interaction design
- why a certain implementation path was chosen

Do not turn the file into comment noise. The purpose is guided maintainability, not line-by-line narration.

### Project-language rule

Comments in generated code must match the dominant language of the project or requested deliverable unless the user explicitly asks for a different language.

Use these defaults:
- Turkish project/request: comments in Turkish
- English project/request: comments in English
- mixed repo: follow the dominant existing code-comment language

If the repository already has a strong comment style, follow it.

### HTML comment directives

Add HTML comments when they help explain:
- major page sections
- landmark boundaries
- repeated content groups
- interactive regions
- modal, drawer, carousel, or panel boundaries
- areas that are intentionally grouped for semantics or accessibility

Good examples:
- section purpose
- why a region has a certain label relationship
- why a block is separate from another similar block

Avoid comments like:
- `<!-- product title -->` immediately above an obvious heading
- `<!-- button -->` above a button

### CSS comment directives

Add CSS comments when they help explain:
- token groups
- layout systems
- breakpoint intent
- focus styles
- state styles
- reduced-motion handling
- sticky or layered positioning
- why a selector structure is intentionally constrained

Good uses:
- comment a group of custom properties
- explain a grid or flex composition strategy
- explain why a component switches layout at a breakpoint
- explain why some state style must not be removed

Avoid:
- comments that restate obvious declarations
- one comment per property

### JavaScript comment directives

Add JS comments when they help explain:
- state synchronization
- event handling decisions
- live-region updates
- focus logic
- keyboard behavior
- dynamic rendering logic
- API response shaping for the UI
- limits, constraints, or business rules in the interaction

Good uses:
- why focus stays in place after an action
- why unchecked compare items become disabled at the limit
- why a timeout is used before updating a live region
- why a render function updates a certain subtree

Avoid:
- comments that simply translate code into prose
- comments on trivial assignments

### Comment density rule

Use a moderate density by default:
- comment each major HTML area
- comment each meaningful CSS section
- comment each non-trivial JS behavior block

Do not comment every small block unless the user explicitly asks for heavily documented output.

### Comment format rule

Prefer short explanatory blocks immediately above the relevant structure.

Good shapes:

```html
<!-- Ürün kartı listesi: tekrar eden içerikler liste yapısı ile sunulur ki
yardımcı teknolojiler toplam ve öğe mantığını anlayabilsin. -->
```

```css
/* Compare paneli masaüstünde sticky kalır; mobilde statik akışa döner.
Bu ayrım, dar ekranlarda görünür alanı gereksiz daraltmamak için uygulanır. */
```

```js
// Canlı durum mesajını kısa gecikmeyle yeniden yazarak ekran okuyucunun
// aynı bölgedeki ardışık güncellemeleri daha tutarlı anons etmesini sağlarız.
```

### Structured section-comment rule

For non-trivial files, generated code should usually include comments for:
- file-level purpose
- major section boundaries
- key state/interaction logic
- accessibility-critical behavior
- responsive or layout-critical behavior

### Comment quality rule

Every substantial comment should ideally answer one or more of these:
- what is this block responsible for
- why is it structured this way
- what would likely break if simplified carelessly
- which user need or product rule does it serve
- which layout/interaction constraint is being preserved

### Do-not-overcomment rule

Do not add heavy comments to:
- obvious headings
- simple wrappers
- basic spacing declarations
- direct semantic HTML with no special reasoning
- trivial click handlers with no special logic

### Documentation mode escalation

If the user asks for:
- detailed code explanation
- training-oriented output
- handoff-ready code
- junior-friendly code
- audit-heavy output

then increase comment depth across HTML, CSS, and JS while still avoiding noise.

### Keyboard and focus

- Every interactive element must be reachable and operable by keyboard.
- Never remove focus outlines without replacing them with a stronger visible focus style.
- Ensure focus order follows meaning and task flow.
- On dialogs, menus, tabs, disclosures, and composite widgets, implement predictable keyboard behavior.
- Do not trap focus except in components that require it, such as modal dialogs.
- Return focus to a sensible location after dismissing overlays.
- Ensure sticky headers, banners, and overlays do not hide the focused element.

### Targets and pointer interactions

- Default interactive target size to at least 24x24 CSS px for WCAG 2.2 AA.
- Prefer 44x44 CSS px for primary controls when layout allows.
- Add spacing between adjacent small targets.
- If drag exists, provide a non-drag alternative.
- Do not rely on hover only for critical content or actions.

### Forms

- Every field needs a programmatic label.
- Group related controls with `fieldset` and `legend`.
- Mark required fields clearly.
- Put instructions where assistive tech can read them.
- Announce errors in text, near the field, and summarize when needed.
- Preserve user input after validation failures.
- Do not use placeholder text as the only label.
- Avoid unnecessary timeouts; if needed, provide extension or save options.
- For authentication, do not force memory-only tasks when alternatives are possible.

### Content and structure

- Use one clear `h1` per page or view region unless the app architecture justifies otherwise.
- Keep heading levels sequential.
- Use lists for lists and tables for data.
- Provide skip links when pages are long or navigation is repeated.
- Keep repeated navigation and major landmarks consistent.
- Avoid images of text except where essential.

### Motion and animation

- Respect `prefers-reduced-motion`.
- Avoid automatic motion that distracts, obscures, or shifts focus.
- For carousels or auto-advancing content, provide pause/stop controls.
- Use animation to clarify state changes, not as decoration only.

### Color and contrast

- Meet WCAG contrast requirements for text, controls, focus indicators, and essential graphics.
- Do not use color as the only means of conveying status or state.
- Ensure disabled and muted UI remain legible.
- Verify designs in forced colors or high-contrast settings when possible.

## React rules

Use when the project is already React-based.

- Prefer composable primitives over monolithic page-specific widgets.
- Separate structure, content, and behavior cleanly.
- Centralize tokens in CSS variables or theme files already used by the repo.
- Keep interactive semantics in native elements first.
- Preserve semantic HTML in JSX; do not wrap lists, definition lists, or tables with meaningless container nodes that break structure.
- Use `React.Fragment` when grouping is needed without adding extra DOM that harms semantics.
- Use `htmlFor` correctly for labels in JSX.
- Keep locale, direction, and formatting available through a shared provider or utility layer.
- Preserve semantic announcements across rerenders; avoid tearing down and recreating nodes unnecessarily when a simple update would preserve context.
- Programmatically manage focus with refs only when runtime updates disturb normal keyboard flow; restore focus logically after overlays and transient UI close.
- Avoid pointer-only patterns such as outside-click-only dismissal; keyboard and focus-aware behavior must remain equivalent.
- For custom widgets, follow WAI-ARIA APG patterns and keyboard behavior.
- Do not add memoization or abstraction by default unless the repo already uses it or performance requires it.

### React accessibility reminders

When working in React, explicitly check these:
- JSX still follows plain HTML accessibility rules
- `aria-*` attributes remain hyphen-cased in JSX
- forms use real labels and expose validation text
- focus outline is never removed without a clear replacement
- skip links and landmarks still work after client-side navigation
- rerenders, conditionals, portals, and modals do not break focus order
- keyboard users can close or move through transient UI without relying on pointer events

## Android rules

Use when the project includes Android UI surfaces, whether XML Views, custom Views, or Jetpack Compose.

- Prefer platform widgets and semantics before building custom controls.
- Follow Android accessibility principles for labeling, accessibility actions, extending system widgets, non-color cues, and accessible media.
- Ensure every meaningful and interactive element has a clear label or description.
- For text inputs, pair visible labels correctly and expose hint text appropriately.
- In repeated collections, ensure item labels remain unique and contextual.
- Add accessibility actions for custom gestures or multi-step interactions when needed.
- Do not encode meaning with color alone.
- If custom Views are unavoidable, ensure focus, traversal, role meaning, state exposure, and action handling are explicitly implemented.
- For Compose or dynamic Android UI, verify announcements, semantics, focus movement, and state updates during recomposition.

### Android accessibility reminders

When working on Android-related UI, explicitly check these:
- labels and descriptions are unique and meaningful
- editable fields are associated with visible labels
- collection items expose enough context to be distinguishable
- custom gestures have accessible alternatives or actions
- system widgets are preferred over bespoke controls
- color is not the only cue for status or categorization
- media content includes accessible alternatives where needed

## Flutter rules

Use when the project includes Flutter UI on mobile, desktop, or web.

- Prefer Flutter's built-in widgets and semantics before building bespoke interaction layers.
- Follow Flutter accessibility guidance for screen reader clarity, contrast, tappable target sizing, context stability, undo support, and large scale factor support.
- Ensure all active interactions produce a meaningful result; avoid no-op interactive controls.
- Test important flows with TalkBack and VoiceOver where applicable.
- Keep tappable targets at least 48x48 logical pixels.
- Maintain contrast around 4.5:1 for text and controls, except disabled components where platform guidance allows exceptions.
- Avoid unexpected context switches while users are typing or completing forms.
- Make important actions undoable where feasible, and provide corrective guidance in error states.
- Ensure UIs remain legible and usable at large text and display scale factors.
- For custom painting, gesture-heavy widgets, or non-standard controls, expose meaningful semantics and non-gesture alternatives.
- For dynamic Flutter states, verify accessible announcements, focus movement, snackbar or toast messaging, and semantics updates after rebuilds.

### Flutter accessibility reminders

When working on Flutter-related UI, explicitly check these:
- controls have intelligible screen reader descriptions
- all interactive controls do something meaningful when activated
- tappable targets are at least 48x48 logical pixels
- text and controls maintain adequate contrast
- typing into a field does not unexpectedly change context
- important actions can be undone when appropriate
- errors provide corrective guidance
- UI remains usable at large text scale and display scale
- TalkBack and VoiceOver testing is considered for release-critical flows

## iOS rules

Use when the project includes iOS or other Apple-platform UI with SwiftUI, UIKit, storyboards, or custom accessibility code.

- Prefer system controls and built-in accessibility behavior before creating custom interaction models.
- Follow Apple accessibility guidance for VoiceOver support, clear descriptions, focus behavior, accessible testing, and assistive-technology compatibility.
- Ensure important controls, icons, and custom elements expose accurate labels, values, traits, and hints where appropriate.
- Keep descriptions current as visible UI and state change.
- Support VoiceOver navigation in content-rich experiences and consider rotor-friendly structure where it improves efficiency.
- When using UIKit, leverage built-in accessible views first; only create custom `UIAccessibilityElement` or container behavior when standard views do not cover the interaction.
- When using SwiftUI, apply accessibility modifiers deliberately and verify semantics after dynamic state changes.
- Post accessibility notifications only when needed to keep users informed of meaningful focus or content changes; avoid noisy announcements.
- Test release-critical flows with VoiceOver and Accessibility Inspector.
- Ensure custom gestures have accessible alternatives when assistive technologies change the normal gesture model.

### iOS accessibility reminders

When working on Apple-platform UI, explicitly check these:
- labels for key interface elements are descriptive and current
- meaningful images and infographics have useful descriptions
- custom elements are exposed accessibly when built-in controls are not used
- VoiceOver focus order matches task flow
- important content changes are announced without flooding the user
- custom rotors or structured navigation are considered for dense content where appropriate
- accessibility testing with VoiceOver and Accessibility Inspector is considered for release-critical flows

## HTML/CSS rules

Use when the project is static, server-rendered, generated, or extension-based.

- Prefer progressive enhancement.
- Ensure content and core actions work before JavaScript enhancements.
- Use CSS custom properties for tokens.
- Keep selectors maintainable and predictable.
- Avoid deep specificity and style leakage.
- If a file generates HTML, preserve that generation model and improve the generated semantics and CSS rather than replacing the stack.

## Visual design defaults

If the repo has no strong design system, use these defaults:
- clear type hierarchy
- generous whitespace
- strong focus ring distinct from hover state
- restrained surface count
- 1-2 accent colors maximum
- clean tables with sticky headers only when focus visibility remains intact
- cards and panels with obvious titles and actions
- mobile-first layouts that scale to desktop without hidden critical actions

Do not default to purple gradients, glassmorphism, low-contrast gray text, or tiny hit areas.

## Implementation checklist

Before finishing UI work, verify at minimum:
- stack choice matches the repo
- no unnecessary framework migration occurred
- language metadata is correct
- keyboard-only flow works
- focus is always visible and not obscured
- all controls have accessible names
- forms have labels, instructions, and error text
- color contrast is sufficient
- target size is sufficient
- layout works at mobile width and at 400% zoom equivalent conditions
- copy is localized or localization-ready
- empty/loading/error/success states exist where needed
- dynamic state transitions are accessible
- live announcements are used correctly and not excessively
- overlays, tabs, accordions, menus, and grids follow appropriate patterns
- motion respects reduced-motion
- tables, images, and icons use correct semantics
- `axe-core` was run when feasible
- remaining manual-review items are called out explicitly

## Response shape when using this skill

When delivering UI work:
- state which stack was detected
- state whether the work follows existing patterns or introduces a minimal system extension
- mention any WCAG-sensitive decisions
- mention whether `axe-core` checks were run or wired
- mention which dynamic states and interactions were verified
- mention what you verified and what remains unverified

When delivering Jira-ready planning output:
- state the detected stack or explicitly say when the stack is assumed
- group tasks by epic, surface, or execution sequence when the scope is broad
- include implementation and QA coverage, not implementation alone
- include accessibility acceptance criteria in each relevant task
- call out assumptions, blockers, and unverified areas explicitly

## Techniques usage rule

When implementing or reviewing accessibility details, consult the W3C WCAG Techniques index as a supporting library of implementation patterns and failure patterns.

Use it this way:
- treat WCAG success criteria as the requirement
- use W3C Techniques as implementation guidance, not as the requirement itself
- check relevant technique groups for the current task: ARIA, HTML, CSS, client-side script, general techniques, and common failures
- explicitly look at failure patterns when building dynamic UI, custom controls, form validation, focus handling, and hover or motion interactions
- when a technique conflicts with simpler native HTML, prefer the simpler native HTML solution

For dynamic UI work, pay special attention to techniques and failures around:
- status messages and live regions
- DOM-inserted content
- focus styling and focus preservation
- keyboard activation for scripted controls
- hover or focus-triggered overlays
- reduced motion and auto-updating content
- error identification and validation text inserted by script

## Techniques mapping matrix

Use this matrix to choose the most relevant W3C Techniques groups before implementing or reviewing UI work. This is a routing aid, not an exhaustive checklist.

### Forms and validation

Focus first on:
- HTML techniques for native labels, grouping, instructions, and error association
- client-side script techniques for validation, inline errors, and preserving user input
- ARIA techniques only when native semantics cannot expose status or relationships cleanly
- common failures for missing labels, placeholder-only labeling, auto-submission, and unclear errors

Use for:
- sign-in flows
- checkout forms
- settings forms
- multi-step forms
- inline edit forms

### Navigation and page structure

Focus first on:
- HTML techniques for landmarks, headings, lists, and link purpose
- CSS techniques for skip links, focus visibility, and reflow
- common failures for broken heading order, repeated unlabeled links, and keyboard traps

Use for:
- dashboards
- admin shells
- content-heavy pages
- side navigation
- breadcrumb flows

### Dialogs, drawers, popovers, and menus

Focus first on:
- ARIA techniques and APG patterns for dialog, alertdialog, disclosure, menu button, and popup state
- client-side script techniques for focus movement, escape handling, open-close state, and restoration
- common failures for focus loss, hidden background interaction, and hover-only disclosure

Use for:
- confirm dialogs
- filter drawers
- action menus
- contextual popovers
- onboarding overlays

### Tabs, accordions, carousels, and composite widgets

Focus first on:
- ARIA techniques and APG patterns for tabs, accordion-like disclosures, carousel controls, listbox, tree, and combobox behavior
- client-side script techniques for keyboard interaction and selected or expanded state updates
- common failures for fake widgets without keyboard support or incorrect state exposure

Use for:
- settings panels
- report explorers
- media carousels
- searchable pickers
- segmented content views

### Tables, grids, sorting, and large data UI

Focus first on:
- HTML techniques for native tables, captions, header associations, and summaries where needed
- ARIA/APG grid guidance only when interaction truly requires grid behavior
- client-side script techniques for sorting, inline editing, row updates, and preserving focus in dynamic data
- common failures for clickable cells without semantics, obscured focus, and unreadable virtualized updates

Use for:
- audit result tables
- permission matrices
- financial data views
- log explorers
- editable admin tables

### Dynamic updates, live regions, and async UI

Focus first on:
- ARIA techniques for `status`, `alert`, live regions, busy states, and progress semantics
- client-side script techniques for DOM updates, async completion, preserving context, and announcing meaningful changes
- common failures for silent updates, noisy announcements, and focus unexpectedly resetting during rerenders

Use for:
- toasts
- save states
- background sync
- incremental search results
- infinite scroll and feed updates

### Motion, hover, and interaction feedback

Focus first on:
- CSS techniques for focus indication, target size support, text spacing, reduced motion, and non-color differentiation
- client-side script techniques for pausing auto-advancing content and avoiding hover-only access
- common failures for motion-only cues, inaccessible hover cards, and weak focus indicators

Use for:
- animated navigation
- metric cards
- tooltip systems
- hover previews
- auto-rotating content

### Multilingual and localization-sensitive UI

Focus first on:
- HTML and general techniques for language declaration and language changes
- client-side script techniques for runtime locale switching without losing context
- common failures for untranslated status text, incorrect `lang`, broken direction handling, and string concatenation

Use for:
- locale switchers
- bilingual dashboards
- RTL-compatible forms
- date and number formatting flows

### Custom controls and scripted interactions

Focus first on:
- native HTML alternatives before any ARIA technique
- ARIA techniques for accessible name, role, state, and property exposure only when custom controls are unavoidable
- client-side script techniques for keyboard parity with pointer interaction
- common failures for clickable `div`s, missing names, and inaccessible drag-only interactions

Use for:
- custom toggles
- bespoke dropdowns
- drag and drop surfaces
- canvas-adjacent controls
- extension popup actions

## References

Load [official-sources.md](references/official-sources.md) when you need the standards, techniques, and rationale behind the rules in this skill.
Load [wcag-2-2-coverage-map.md](references/wcag-2-2-coverage-map.md) when you need a practical criterion-to-surface review map for complete WCAG 2.2 A/AA coverage.







