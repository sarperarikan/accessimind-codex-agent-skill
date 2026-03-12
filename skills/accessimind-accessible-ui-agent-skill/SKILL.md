---
name: accessimind-accessible-ui-agent-skill
description: Use when the user wants production-ready modern UI work for existing projects or new screens in React, HTML, or CSS, with stack-aware implementation, enterprise-grade multilingual architecture, consistent design systems, WCAG 2.2-compliant output, axe-core-backed accessibility verification, and strong support for dynamic and stateful interfaces.
---

# AccessiMind Accessible UI Agent Skill

Use this skill when building or refactoring UI in web projects that must be modern, consistent, multilingual, accessibility-first, and production-ready.

Keep this skill practical. Prefer shipping code over writing design essays.

## Outcomes

Produce UI that is:
- modern but not trendy for its own sake
- usable with keyboard, screen reader, zoom, forced colors, and reduced motion
- structurally correct in semantic HTML first
- consistent through tokens, states, spacing, and component rules
- multilingual by architecture, not by string scattering
- aligned with the current project's existing stack and patterns
- verified with automated accessibility checks plus explicit manual review notes
- resilient for both static layouts and dynamic, stateful application behavior

## Required workflow

1. Detect the stack before proposing or writing UI.
2. Inspect local files to determine whether the project uses React, static HTML/CSS/JS, templates, extensions, server-rendered pages, or generated HTML.
3. Reuse the current stack unless the user explicitly asks for a migration.
4. Build semantic HTML first, then CSS, then JS behavior.
5. Use ARIA only when native HTML cannot express the interaction correctly.
6. Design and code to WCAG 2.2 AA by default.
7. Run or wire automated `axe-core` checks where the stack allows it.
8. Verify static and dynamic states: keyboard flow, focus visibility, naming, contrast, target size, errors, responsiveness, language metadata, motion behavior, async updates, overlays, and live announcements.
9. Explain any remaining accessibility risk or unverified area.

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







