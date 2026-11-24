# Türkiye Aile ve Sosyal Hizmetler Bakanlığı checklist

Use the versioned question IDs alongside the normative WCAG 2.2 catalog. Both checklists map to the same 31 WCAG A criteria. For an A/AA audit, evaluate the extra 24 AA criteria separately. Inclusion in the catalog does not establish legal applicability.

| Requested edition | Version | Questions | Rule data |
| --- | --- | ---: | --- |
| 122 questions, or an existing report using its numbering | v2.2.20.00 | 122 | [122-question catalog](turkey-ashb-122.tsv) |
| Current official checklist, or unspecified Turkish checklist | V2.2.30.01 | 126 | [126-question catalog](turkey-ashb-126.tsv) |

The Ministry's access page linked V2.2.30.01 on 24 November 2026. Verify the link again for a request that depends on the currently applicable edition. Keep the requested historical edition when the user asks for it. For both editions, reuse underlying evidence while recording each edition's answer independently. The TSVs contain original test-topic summaries and physical PDF page numbers starting at 1. Consult the official question before resolving exceptions or an ambiguous result. [Ministry access page](https://aile.gov.tr/eyhgm/sayfalar/hizli-erisim-erisilebilirlik/) · [122-question official PDF](https://www.aile.gov.tr/media/257527/web_siteleri_ve_mobil_uygulamalarin_erisilebilirligi_kontrol_listesi_.pdf) · [126-question official PDF](https://www.aile.gov.tr/media/325317/kontrol_listesi_a_seviyesi_web_siteleri_ve_mobil_uygulamalar.pdf)

## Evaluate a view or process

1. Use the edition, physical PDF page, Ministry criterion number (BK), question number and normative WCAG ID together. Example `v2.2.20.00/Q95 → BK25 → 3.2.1`. Account for every question for each evaluated state or view, including the reason each skipped question was inapplicable. Use process evidence for cross-view rules such as consistent help and redundant entry.
2. A `gate` determines applicability or the next question. Record its Yes/No answer without counting it as a pass or fail. A `check-yes` is fulfilled by Yes. A `check-no` is fulfilled by No. Reverse-polarity questions are Q95 in the 122 edition and Q52, Q81 and Q106 in the 126 edition.
3. Apply `on_yes`, `on_no` and `on_exception` when the answer or established exception matches. Empty cells continue to the next question. `end` ends the checklist. Unverified gates leave the dependent questions unverified until applicability is established. Record unknown or blocked outcomes without inferring a No. A skipped check is not a passed check.
4. Store edition, question, raw answer, applicability or branch reason, checklist outcome, criterion, tested state, modality and evidence. Record the normative WCAG verdict separately when the checklist uses a specific technique, wider conditions or wording with a different threshold. A question may surface relevant evidence for an additional WCAG criterion after its independent conditions are checked.
5. Report tested, failed, conditionally skipped, unverified and blocked coverage by edition. Keep compatibility with an existing report by carrying its edition and question IDs into regression results. Version changes can split or merge questions, so a shared WCAG ID alone does not imply the same test.

## Decisions that need independent WCAG judgment

- In the 122 edition, Q68 and Q70 can skip to Q76. Preserve the source path and still check any actual motion and flash independently under WCAG 2.2.2 and 2.3.1.
- The 122 edition's Q74–75 use flash-frequency and screen-area shorthand. Apply the W3C frequency and general/red flash definitions independently. Use frame analysis for suspected unsafe samples instead of viewing the content directly. [WCAG 2.3.1](https://www.w3.org/TR/WCAG22/#three-flashes-or-below-threshold)
- The 122 edition's Q78 is an unstarred gate. Its No branch skips Q79. A missing meaningful page title can still fail WCAG 2.4.2. The 126 edition's Q84 tests title presence directly.
- The 122 edition's Q89 and 126 edition's Q100 use same/start wording. WCAG 2.5.3 requires the accessible name to contain the visible text. Beginning the name with visible text is best practice. [WCAG 2.5.3](https://www.w3.org/TR/WCAG22/#label-in-name)
- The 122 edition's Q96–97 test specific warnings and a confirmation mechanism. WCAG 3.2.2 allows a change of context on input when the user is advised before using the component. Its requirements do not mandate both a visual and an audible warning. [WCAG 3.2.2](https://www.w3.org/TR/WCAG22/#on-input)
- The 122 edition's Q99–100 ask about position and order. Separately judge WCAG 3.2.6 on relative order within a set of pages, with its user-initiated change exception. [WCAG 3.2.6](https://www.w3.org/TR/WCAG22/#consistent-help)
- The 122 edition's Q105–110 include implementation checks and success feedback. Judge WCAG 3.3.1 by textual identification and description of detected input errors. Test whether a success notification qualifies for WCAG 4.1.3 separately. [WCAG 3.3.1](https://www.w3.org/TR/WCAG22/#error-identification) · [WCAG 4.1.3](https://www.w3.org/TR/WCAG22/#status-messages)

## Example

A menu opens with Enter, closes with Escape and returns focus to its trigger. The trigger still exposes expanded=true after close. Record the exact transition and fail WCAG 4.1.2. In the 122 edition this evidence is relevant to Q122; in the 126 edition it supports Q126. Check Q125 separately by inspecting the initial state and exposed properties. The keyboard operation and return of focus must be judged under their own criteria.
