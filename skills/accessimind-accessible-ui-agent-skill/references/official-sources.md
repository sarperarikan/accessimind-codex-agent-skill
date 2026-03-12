# Official sources

Use these as the primary references for this skill. Prefer official sources over blog posts.

## WCAG and WAI

- WCAG 2.2 Recommendation: https://www.w3.org/TR/wcag/
- WCAG 2.1 Techniques index: https://www.w3.org/WAI/WCAG21/Techniques/
- About WCAG Techniques: https://www.w3.org/WAI/WCAG21/Understanding/understanding-techniques
- WCAG 2 Overview: https://www.w3.org/WAI/standards-guidelines/wcag/
- What is new in WCAG 2.2: https://www.w3.org/WAI/standards-guidelines/wcag/new-in-22/
- ARIA Authoring Practices Guide: https://www.w3.org/WAI/ARIA/apg/
- APG Practices: https://www.w3.org/WAI/ARIA/apg/practices/
- WAI Tutorials index: https://www.w3.org/WAI/tutorials/
- Page Structure Tutorial: https://www.w3.org/WAI/tutorials/page-structure/
- Forms Tutorial: https://www.w3.org/WAI/tutorials/forms/
- Form Instructions: https://www.w3.org/WAI/tutorials/forms/instructions/
- Images Tutorial: https://www.w3.org/WAI/tutorials/images/
- Alt Decision Tree: https://www.w3.org/WAI/tutorials/images/decision-tree/
- Tables Tutorial: https://www.w3.org/WAI/tutorials/tables/
- Target Size (Minimum) Understanding: https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum
- Technique ARIA22 role=status: https://www.w3.org/WAI/WCAG21/Techniques/aria/ARIA22

## Dynamic interaction patterns

- Dialog (Modal) Pattern: https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/
- Alert Dialog Pattern: https://www.w3.org/WAI/ARIA/apg/patterns/alertdialog/
- Tabs Pattern: https://www.w3.org/WAI/ARIA/apg/patterns/tabs/
- Carousel Pattern: https://www.w3.org/WAI/ARIA/apg/patterns/carousel/
- Feed Pattern: https://www.w3.org/WAI/ARIA/apg/patterns/feed/
- Grid Pattern: https://www.w3.org/WAI/ARIA/apg/patterns/grid/
- Table Pattern: https://www.w3.org/WAI/ARIA/apg/patterns/table/
- Alert Pattern: https://www.w3.org/WAI/ARIA/apg/patterns/alert/

## Internationalization

- Authoring HTML: Language declarations: https://www.w3.org/International/docs/bp-html-lang/
- Declaring language in HTML: https://www.w3.org/International/questions/qa-html-language-declarations

## axe-core

- Axe-core documentation: https://www.deque.com/axe/core-documentation/
- Axe-core GitHub repository: https://github.com/dequelabs/axe-core
- Axe-core package: https://www.npmjs.com/package/axe-core

## React accessibility

- React Accessibility (legacy docs): https://legacy.reactjs.org/docs/accessibility.html

## Android accessibility

- Principles for improving app accessibility: https://developer.android.com/guide/topics/ui/accessibility/principles

## Flutter accessibility

- Flutter accessibility: https://docs.flutter.dev/ui/accessibility

## Apple accessibility

- Accessibility: https://developer.apple.com/documentation/accessibility/
- Accessibility for UIKit: https://developer.apple.com/documentation/uikit/accessibility-for-uikit
- VoiceOver: https://developer.apple.com/documentation/accessibility/voiceover
- Apple HIG VoiceOver: https://developer.apple.com/design/human-interface-guidelines/voiceover

## Production design systems

- USWDS Accessibility: https://designsystem.digital.gov/documentation/accessibility/
- GOV.UK Design System Accessibility: https://design-system.service.gov.uk/accessibility/
- GOV.UK Accessibility strategy: https://design-system.service.gov.uk/accessibility/accessibility-strategy/

## Techniques index coverage notes

The W3C Techniques index includes implementation guidance across these groups:
- ARIA techniques
- client-side script techniques
- CSS techniques
- general techniques
- HTML techniques
- common failures

For this skill, the most relevant groups for modern product UI are usually:
- ARIA techniques for naming, state, status, landmarks, and error exposure
- client-side script techniques for keyboard support, dynamic DOM updates, validation, motion control, and hover or focus behavior
- CSS techniques for focus indication, reflow, target sizing, reduced motion, and text spacing
- common failures for focus loss, fake controls, bad tab order, auto-submission, unexpected window changes, and inaccessible dynamic updates

## Notes extracted from current sources

- W3C recommends using WCAG 2.2 as the latest WCAG 2 version.
- WCAG 2.2 is a W3C Recommendation and, as of 2025, also approved as ISO/IEC 40500:2025.
- Content that conforms to WCAG 2.2 also conforms to WCAG 2.1 and WCAG 2.0.
- The four WCAG principles remain POUR: perceivable, operable, understandable, robust.
- For multilingual pages, set the default language on the `html` element, and mark inline language changes with `lang` on the relevant element.
- The React accessibility guide states that React supports accessible websites through standard HTML techniques, recommends preserving semantic HTML in JSX, using Fragments to avoid broken list or table semantics, using `htmlFor` for labels, and repairing focus flow with refs only when runtime DOM changes disturb keyboard navigation.
- Android's accessibility principles emphasize labeling meaningful elements, adding accessibility actions for critical flows, extending system widgets instead of replacing them unnecessarily, using cues beyond color, and making media content more accessible.
- Flutter's accessibility guidance recommends including accessibility checks before release, testing with screen readers, keeping text and controls high-contrast, avoiding automatic context changes during input, maintaining at least 48x48 tappable targets, making important actions undoable, and ensuring usability at large text and display scale factors.
- Apple accessibility documentation emphasizes testing with assistive technologies, relying on built-in accessible controls where possible, exposing accurate descriptions for key and custom elements, supporting VoiceOver well, and using platform accessibility APIs to communicate meaningful content and focus changes.
- Technique ARIA22 notes that `role="status"` has an implicit polite live region and an atomic behavior suitable for status updates.
- The APG dialog pattern requires focus to move into an opened dialog, remain within the modal dialog while active, and return logically after close.
- The APG tabs pattern defines tab, tablist, and tabpanel relationships and keyboard arrow navigation expectations.
- The APG carousel pattern emphasizes that auto-rotation must stop when focus enters the carousel and that users need explicit rotation control.
- The APG feed pattern explains that dynamically loading feed content needs reliable article structure, focus management, and `aria-busy` during updates.
- The APG grid pattern distinguishes static tables from interactive grids and warns that grid behavior requires author-managed focus movement.
- APG alert guidance says alerts are announced dynamically and should not move keyboard focus.
- Deque describes axe-core as an accessibility engine for automated web UI testing and positions it for integration with existing test environments.
- The axe-core project states that its rules cover WCAG 2.0, 2.1, and 2.2 and that automated checks catch only part of WCAG issues; manual review remains necessary.
- The axe-core project also notes that some checks, including known cases like `color-contrast`, have limitations in JSDOM and are better validated in real browser contexts.
- Practical enterprise UI work should still include manual page-level testing; design systems alone do not guarantee accessibility.





