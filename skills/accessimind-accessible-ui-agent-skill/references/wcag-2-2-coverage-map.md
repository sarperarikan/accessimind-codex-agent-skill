# WCAG 2.2 Coverage Map

Use this reference when a task needs explicit WCAG 2.2 A/AA review coverage, especially for production-ready UI work, audits, PR reviews, design-system changes, or dynamic interaction work.

How to use it:
- start from the changed UI surface, not from the entire product
- mark each criterion as `applicable`, `not applicable`, or `needs manual verification`
- use this file to avoid missing less-obvious criteria outside basic keyboard and contrast checks
- pair it with `official-sources.md` when you need standards wording or primary-source rationale

This is a routing and review aid, not a legal certification artifact.

## Perceivable

### Text alternatives

- `1.1.1 Non-text Content`
  Use for images, icons, charts, controls, canvases, captchas, illustrations, and decorative media decisions.
  Verify that informative content has useful alternatives and decorative content is hidden appropriately.

### Time-based media

- `1.2.1 Audio-only and Video-only (Prerecorded)`
  Use when the UI includes standalone prerecorded audio or silent video.
- `1.2.2 Captions (Prerecorded)`
  Use for prerecorded video with sound.
- `1.2.3 Audio Description or Media Alternative (Prerecorded)`
  Use when meaningful visual-only information exists in prerecorded video.
- `1.2.4 Captions (Live)`
  Use for live media with speech.
- `1.2.5 Audio Description (Prerecorded)`
  Use when prerecorded video requires additional spoken context.

### Adaptable

- `1.3.1 Info and Relationships`
  Use for headings, lists, tables, field groups, cards, filters, tabs, accordions, and dashboards.
  Verify that structure is programmatically exposed, not only visual.
- `1.3.2 Meaningful Sequence`
  Use when DOM order, reading order, or CSS reordering might diverge.
- `1.3.3 Sensory Characteristics`
  Use when instructions reference position, color, shape, or sound alone.
- `1.3.4 Orientation`
  Use for mobile, tablet, kiosk, and responsive app surfaces.
- `1.3.5 Identify Input Purpose`
  Use on user-data forms where input purpose tokens apply.
- `1.3.6 Identify Purpose`
  Stretch review for regions and controls where personalization semantics could help.

### Distinguishable

- `1.4.1 Use of Color`
  Use for status badges, validation, selected state, charts, and filters.
- `1.4.2 Audio Control`
  Use if any audio auto-plays for more than three seconds.
- `1.4.3 Contrast (Minimum)`
  Use for text, controls, placeholder-adjacent text, badges, and secondary content that remains essential.
- `1.4.4 Resize Text`
  Use for all text-bearing UI.
- `1.4.5 Images of Text`
  Use when designs propose flattened text in images.
- `1.4.10 Reflow`
  Use for responsive layouts, dense admin UI, tables, dialogs, drawers, and mobile breakpoints.
- `1.4.11 Non-text Contrast`
  Use for icons, focus styles, charts, boundaries, toggles, inputs, and state indicators.
- `1.4.12 Text Spacing`
  Use when typography or truncation is tightly controlled.
- `1.4.13 Content on Hover or Focus`
  Use for tooltips, hover cards, previews, submenus, and disclosure surfaces.

## Operable

### Keyboard accessible

- `2.1.1 Keyboard`
  Use for every interactive surface.
- `2.1.2 No Keyboard Trap`
  Use for modals, menus, editors, embedded widgets, and custom composites.
- `2.1.4 Character Key Shortcuts`
  Use when single-character shortcuts exist.

### Enough time

- `2.2.1 Timing Adjustable`
  Use for session timers, OTP windows, quizzes, and timed tasks.
- `2.2.2 Pause, Stop, Hide`
  Use for autoplay, carousels, marquees, tickers, and moving dashboards.

### Seizures and physical reactions

- `2.3.1 Three Flashes or Below Threshold`
  Use for animation-heavy marketing UI, media, and loading effects.

### Navigable

- `2.4.1 Bypass Blocks`
  Use for repeated navigation, admin shells, and dense site chrome.
- `2.4.2 Page Titled`
  Use for routed views, modal documents, and browser-level navigation states.
- `2.4.3 Focus Order`
  Use for every task flow and dynamic insertion/removal path.
- `2.4.4 Link Purpose (In Context)`
  Use for repeated CTA labels, cards, tables, and lists of links.
- `2.4.5 Multiple Ways`
  Use on larger sites or apps with discoverability needs.
- `2.4.6 Headings and Labels`
  Use for forms, cards, dashboards, settings, and data explorers.
- `2.4.7 Focus Visible`
  Use for all controls and custom widgets.
- `2.4.11 Focus Not Obscured (Minimum)`
  Use for sticky headers, cookie bars, drawers, chat widgets, and anchored toolbars.
- `2.4.12 Focus Not Obscured (Enhanced)`
  Stretch review when layout control allows it.
- `2.4.13 Focus Appearance`
  Use wherever custom focus styling exists.

### Input modalities

- `2.5.1 Pointer Gestures`
  Use for pinch, swipe, path gestures, maps, and canvas tools.
- `2.5.2 Pointer Cancellation`
  Use for down-event actions, draggable chips, and gesture-triggered controls.
- `2.5.3 Label in Name`
  Use for visible-label buttons, toggles, tabs, and voice-control compatibility.
- `2.5.4 Motion Actuation`
  Use for shake, tilt, or device-motion interactions.
- `2.5.7 Dragging Movements`
  Use for drag-and-drop boards, sliders, range pickers, reorderable lists, and maps.
- `2.5.8 Target Size (Minimum)`
  Use for all interactive targets, especially icon buttons, pills, close controls, and dense toolbars.

## Understandable

### Readable

- `3.1.1 Language of Page`
  Use for every document or app shell.
- `3.1.2 Language of Parts`
  Use when inline language switches occur.

### Predictable

- `3.2.1 On Focus`
  Use where focus triggers previews, validation, navigation, or media.
- `3.2.2 On Input`
  Use for auto-submit filters, step changes, and reactive forms.
- `3.2.3 Consistent Navigation`
  Use across templates, shells, and repeated page structures.
- `3.2.4 Consistent Identification`
  Use across repeated actions and iconography.
- `3.2.6 Consistent Help`
  Use when help, support, contact, or assistance features recur.

### Input assistance

- `3.3.1 Error Identification`
  Use for all forms and inline editors.
- `3.3.2 Labels or Instructions`
  Use for forms, search, filters, and settings.
- `3.3.3 Error Suggestion`
  Use when recoverable corrections can be suggested.
- `3.3.4 Error Prevention (Legal, Financial, Data)`
  Use for destructive or consequential submissions.
- `3.3.7 Redundant Entry`
  Use for multi-step forms and repeated user-information collection.
- `3.3.8 Accessible Authentication (Minimum)`
  Use for sign-in, step-up auth, OTP, passkeys, captcha, and recovery flows.
- `3.3.9 Accessible Authentication (Enhanced)`
  Stretch review for stronger non-memory-based auth support.

## Robust

- `4.1.1 Parsing`
  Legacy criterion removed in WCAG 2.2. Do not include as an active requirement.
- `4.1.2 Name, Role, Value`
  Use for all interactive controls, custom widgets, dynamic states, and scripted UI.
- `4.1.3 Status Messages`
  Use for toasts, async saves, validation summaries, background updates, and result counts.

## Surface-based quick routing

### Forms

Review first:
- `1.3.1`
- `1.3.5`
- `1.4.3`
- `2.1.1`
- `2.4.6`
- `2.5.3`
- `3.3.1`
- `3.3.2`
- `3.3.3`
- `3.3.7`
- `3.3.8`
- `4.1.2`
- `4.1.3`

### Dialogs and drawers

Review first:
- `1.3.1`
- `1.4.10`
- `2.1.1`
- `2.1.2`
- `2.4.3`
- `2.4.7`
- `2.4.11`
- `2.4.13`
- `3.2.1`
- `4.1.2`

### Carousels and auto-rotating content

Review first:
- `1.3.1`
- `1.4.13`
- `2.1.1`
- `2.2.2`
- `2.4.3`
- `2.4.7`
- `2.5.1`
- `2.5.7`
- `2.5.8`
- `4.1.2`
- `4.1.3`

### Tables and large data

Review first:
- `1.3.1`
- `1.4.10`
- `1.4.11`
- `2.1.1`
- `2.4.3`
- `2.4.6`
- `2.4.7`
- `2.4.11`
- `3.2.2`
- `4.1.2`
- `4.1.3`

### Navigation shells

Review first:
- `1.3.1`
- `1.4.10`
- `2.4.1`
- `2.4.2`
- `2.4.3`
- `2.4.4`
- `2.4.6`
- `2.4.7`
- `3.2.3`
- `3.2.4`
- `3.2.6`

### Media and learning content

Review first:
- `1.1.1`
- `1.2.1`
- `1.2.2`
- `1.2.3`
- `1.2.4`
- `1.2.5`
- `1.4.2`
- `2.2.2`
- `2.3.1`

## Manual verification prompts

Use these prompts during review:
- Can a blind screen reader user discover, understand, and complete the task without hidden context?
- At 400% zoom or narrow viewport, does content reflow without clipping, overlap, or hidden actions?
- Can a keyboard-only user complete the full path without trap, confusion, or invisible focus?
- Can a motor-limited user activate every control without precision dragging or tiny targets?
- Can a voice-input user say the visible label and activate the intended control?
- If motion is reduced, paused, or removed, does the experience still make full sense?
- Are help, error recovery, and progress cues explicit enough for users under cognitive load?
- If audio is absent, can the user still receive all essential information?
