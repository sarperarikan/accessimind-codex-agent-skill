# Usage Guide

Current version: `1.0.0.4`

## Overview

AccessiMind Accessible UI Agent Skill is intended for Codex users who want UI work that is:
- accessibility-first
- production-ready
- multilingual by architecture
- respectful of the existing project stack
- suitable for both static and dynamic interfaces

This guide explains how to install, invoke, and use the skill effectively.

## Install the Integrated Skill Bundle

### Option 1: Install with the bundled script

From the repository root:

```powershell
.\scripts\install-skill.ps1
```

### Option 2: Install manually

Copy this folder:

```text
skills/accessimind-accessible-ui-agent-skill
```

Into your Codex skills directory:

```text
$HOME\.codex\skills\
```

After installation, the expected paths are:

```text
$HOME\.codex\skills\accessimind-accessible-ui-agent-skill\SKILL.md
$HOME\.codex\skills\playwright\SKILL.md
$HOME\.codex\skills\senior-developer-20y\SKILL.md
$HOME\.codex\skills\nvda-portable-a11y-audit\SKILL.md
$HOME\.codex\skills\full-persona-a11y-audit\SKILL.md
```

## Package the Bundle for Sharing

To create a distributable zip archive:

```powershell
.\scripts\package-skill.ps1
```

The package will be created here:

```text
dist/accessimind-integrated-skill-bundle.zip
```

## Validate the Skill

If Python is available:

```powershell
python .\scripts\quick_validate.py .\skills\accessimind-accessible-ui-agent-skill
```

This validation checks the skill frontmatter and naming rules.

Validate the bundled runtime harnesses:

```powershell
node --check .\skills\accessimind-accessible-ui-agent-skill\scripts\nvda_web_audit.mjs
node --check .\skills\accessimind-accessible-ui-agent-skill\scripts\low_vision_web_audit.mjs
node --check .\skills\accessimind-accessible-ui-agent-skill\scripts\motor_web_audit.mjs
```

## When to Use This Skill

Use this skill when you want Codex to:
- build or refactor UI in an existing project
- preserve the current stack instead of introducing a new one
- improve accessibility without treating it as an afterthought
- handle dynamic UI states such as dialogs, toasts, overlays, tabs, async loads, and live updates
- design multilingual UI architecture instead of scattering strings inline
- evaluate or implement accessibility for React, HTML/CSS, Android, Flutter, or iOS surfaces

## Integrated Methodology

This repository is now intentionally multi-skill.

Use this execution order:
1. `accessimind-accessible-ui-agent-skill` for WCAG 2.2 interpretation, implementation rules, and severity.
2. `playwright` for deterministic browser runtime evidence (keyboard, focus, DOM transitions).
3. `nvda-portable-a11y-audit` for mandatory live screen-reader evidence and screenshot artifacts using portable NVDA.
4. `full-persona-a11y-audit` for one-command blind/low-vision/motor persona coverage.
5. `senior-developer-20y` for architecture rigor, regression control, and production release hardening.

This ensures the workflow is not checklist-only and can support production-grade delivery decisions.

## NVDA Portable Runner

From repository root:

```powershell
.\skills\nvda-portable-a11y-audit\scripts\invoke-nvda-playwright-audit.ps1 -Urls "https://www.arcelik.com.tr/kampanyalar","https://www.arcelik.com.tr/destek"
```

This runner uses the repository-local `NVDA/` directory as the default screen-reader runtime.

## Core Web Evidence Harnesses

The main AccessiMind skill includes direct web-audit harnesses under:

```text
skills/accessimind-accessible-ui-agent-skill/scripts/
```

Install runtime dependencies in the workspace where you run the audit:

```powershell
cmd /c npm.cmd install playwright @guidepup/guidepup @guidepup/setup
cmd /c npx.cmd @guidepup/setup
```

Use PowerShell `npm.cmd` and `npx.cmd` when execution policy blocks `npm.ps1` or `npx.ps1`.

### NVDA web-only evidence

Use this when the report needs real NVDA speech output from a live browser page:

```powershell
node .\skills\accessimind-accessible-ui-agent-skill\scripts\nvda_web_audit.mjs `
  --url https://www.example.com `
  --selector "#main" `
  --out output\nvda-web-audit.json `
  --next 80 `
  --previous 20 `
  --tab 30
```

The NVDA harness captures:
- foreground browser ownership
- unique page-title token
- accepted web speech
- filtered OS or unrelated application noise
- forward browse traversal
- reverse browse traversal
- keyboard Tab traversal
- DOM inventory and coverage comparison

Do not treat a short or empty NVDA log as production evidence. If foreground ownership cannot be proven or all speech is filtered, the result must be reported as blocked or unverified.

### Low-vision evidence

Use this when the report needs measured visual-accessibility evidence:

```powershell
node .\skills\accessimind-accessible-ui-agent-skill\scripts\low_vision_web_audit.mjs `
  --url https://www.example.com `
  --selector "#main" `
  --out output\low-vision-audit.json `
  --artifacts output\low-vision
```

The low-vision harness captures:
- desktop viewport
- mobile viewport
- 200% equivalent viewport
- 400% equivalent viewport
- WCAG text-spacing condition
- forced-colors condition where browser support is available
- screenshots
- bounding boxes
- contrast ratios
- focus style data
- clipping and overflow indicators
- target cluster density signals

### Motor accessibility evidence

Use this when the report needs measured motor-accessibility evidence:

```powershell
node .\skills\accessimind-accessible-ui-agent-skill\scripts\motor_web_audit.mjs `
  --url https://www.example.com `
  --selector "#main" `
  --out output\motor-audit.json `
  --artifacts output\motor `
  --focusSteps 80 `
  --actionabilityChecks 60
```

The motor harness captures:
- desktop pointer condition
- desktop keyboard condition
- mobile touch condition
- interactive element inventory
- target size measurements
- nearest-neighbor target spacing
- viewport clipping
- keyboard Tab trace
- non-destructive pointer actionability checks
- drag, slider, carousel, resize, and swipe-like candidates
- whether detected precision widgets expose a keyboard or button alternative

Motor findings must stay atomic. For example, report `carousel next button is 18x18px in mobile-touch condition` instead of `carousel is difficult for motor users`.

## Professional HTML Audit Reports

When asking Codex to produce an audit deliverable, request an HTML report explicitly:

```text
Use $accessimind-accessible-ui-agent-skill to audit https://www.example.com.
Create a professional HTML report for PO, developers, and business analysts.
Include table of contents, evidence, WCAG mapping, Jira summary, Jira description, remediation guidance, and verification plan.
Use NVDA, low-vision, and motor evidence where available.
```

The report should include:
- executive summary
- scope and tested surfaces
- methodology
- evidence artifact paths
- findings ordered by severity
- WCAG 2.2 references
- screen-reader evidence section
- low-vision evidence section
- motor evidence section
- Jira-ready summary and description
- remediation plan
- regression checks
- production gate decision: `PASS`, `PASS_WITH_RISK`, or `FAIL`

Screen-reader, low-vision, and motor sections must not contain summary-only findings. Each finding must identify the tested condition, element, observed evidence, expected behavior, impact, WCAG reference, remediation direction, and confidence.

## Full Persona Runner

From repository root:

```powershell
.\skills\full-persona-a11y-audit\scripts\invoke-full-persona-audit.ps1 -Urls "https://www.arcelik.com.tr/kampanyalar","https://www.arcelik.com.tr/destek"
```

This produces:
- `blind.md`
- `low-vision.md`
- `motor.md`
- `summary.md`
- `summary.json`

## What the Skill Optimizes For

The skill pushes Codex toward:
- semantic structure first
- native controls before custom ARIA-heavy abstractions
- WCAG 2.2-aware implementation
- stack-aware UI changes
- design consistency
- dynamic accessibility behavior
- explicit verification and residual-risk reporting

## How the Skill Chooses the Technology Path

The skill inspects the local project first. It looks at files such as:
- `package.json`
- `tsconfig.json`
- lockfiles
- app entry files
- component directories
- template directories
- browser extension files
- Android modules
- Flutter modules
- iOS modules

Based on what it finds, it prefers the least invasive path:
- stay in React if the project is already React
- stay in static HTML/CSS/JS if the project is not React-based
- preserve generated HTML flows if the UI is server-generated
- respect extension runtime constraints
- reuse existing accessibility tooling when present

## Accessibility Scope

The skill is not limited to static markup. It also covers dynamic and stateful behavior, including:
- loading states
- validation states
- success and error states
- dialogs and drawers
- tabs and accordions
- popovers and menus
- live region announcements
- infinite scroll and feeds
- sorting, filtering, and table updates
- motion and reduced-motion behavior
- focus preservation during DOM changes

## Multilingual and Localization Support

The skill treats localization as part of architecture.

It expects Codex to:
- centralize strings
- support locale, language, and direction
- set `lang` and `dir` correctly
- avoid fragile string concatenation
- handle text expansion
- account for RTL languages
- account for CJK layouts
- keep runtime status and validation text localized

## Accessibility Verification Strategy

The skill uses multiple layers of verification:

### 1. Structural implementation review

Codex is expected to check:
- semantics
- labels
- focus behavior
- keyboard access
- contrast-sensitive decisions
- naming and state exposure

### 2. `axe-core` verification

Where feasible, the skill expects Codex to:
- use existing browser-based audit flows
- run scans on rendered states, not only source markup
- check dynamic states, not only first render
- treat `violations` as defects or explicitly documented exceptions
- treat `incomplete` results as manual review items

### 3. Manual review reporting

The skill expects Codex to report:
- what was verified
- which dynamic states were tested
- whether `axe-core` was run or wired
- what still requires manual review

## Platform-Specific Coverage

### Web / HTML / CSS

The skill prefers:
- semantic HTML
- progressive enhancement
- CSS custom properties for tokens
- accessible focus indicators
- durable responsive behavior

### React

The skill expects:
- semantic JSX
- `React.Fragment` when wrappers would harm semantics
- correct `htmlFor` usage
- accessible rerender and focus behavior
- avoidance of pointer-only interaction patterns

### Android

The skill expects:
- platform widgets where possible
- meaningful labels and descriptions
- accessible alternatives for custom gestures
- non-color status cues
- dynamic state verification in Views or Compose

### Flutter

The skill expects:
- semantics-aware widget usage
- 48x48 logical pixel targets
- screen reader testing awareness
- large text scale support
- undo-friendly critical actions where feasible

### iOS

The skill expects:
- built-in accessible controls first
- correct labels, values, traits, and hints
- VoiceOver-aware focus flow
- Accessibility Inspector consideration
- appropriate platform accessibility notifications

## How to Prompt Codex with This Skill

Effective prompt examples:

```text
Use $accessimind-accessible-ui-agent-skill to refactor this dashboard for WCAG 2.2 and multilingual support.
```

```text
Use $accessimind-accessible-ui-agent-skill to improve this React modal flow and verify dynamic accessibility behavior.
```

```text
Use $accessimind-accessible-ui-agent-skill to review this Android screen for accessibility regressions.
```

```text
Use $accessimind-accessible-ui-agent-skill to make this Flutter form production-ready and accessible.
```

```text
Use $accessimind-accessible-ui-agent-skill to audit this iOS SwiftUI flow for VoiceOver and state-change behavior.
```

```text
Use $accessimind-accessible-ui-agent-skill to audit this Swiper carousel with real NVDA output, low-vision measurement, motor measurement, and a professional HTML report.
```

## Recommended Working Pattern

For best results, ask Codex to:
1. inspect the current stack first
2. explain the chosen implementation path briefly
3. make the actual UI changes
4. call out WCAG-sensitive decisions
5. run or wire `axe-core` if feasible
6. summarize verified and unverified areas

## Included Reference Families

The skill routes work through these guidance families:
- WCAG 2.2
- W3C WCAG Techniques
- WAI-ARIA Authoring Practices
- `axe-core`
- React accessibility guidance
- Android accessibility guidance
- Flutter accessibility guidance
- Apple accessibility guidance

## Limitations

This skill improves implementation quality and verification discipline, but it does not replace:
- legal review
- full assistive-technology QA
- user testing with disabled users
- platform-specific certification or compliance processes

## Files You Will Usually Care About

- `skills/accessimind-accessible-ui-agent-skill/SKILL.md`
- `skills/accessimind-accessible-ui-agent-skill/references/official-sources.md`
- `skills/accessimind-accessible-ui-agent-skill/agents/openai.yaml`

## License and Reuse

Review the repository license and your organization's policy before redistributing the skill in packaged form.

---

# Türkçe Kullanım Kılavuzu

## Genel Bakış

AccessiMind Accessible UI Agent Skill, Codex ile erişilebilirlik odaklı UI geliştirme, refactor, canlı sayfa denetimi ve profesyonel raporlama yapmak için tasarlanmış entegre bir skill paketidir.

Bu paket şu işleri destekler:
- WCAG 2.2 odaklı UI geliştirme ve denetim
- React, HTML/CSS, Android, Flutter ve iOS yüzeyleri için erişilebilirlik incelemesi
- Playwright ile gerçek tarayıcı runtime kanıtı
- NVDA ile gerçek ekran okuyucu konuşma çıktısı
- az gören kullanıcılar için ölçüme dayalı simülasyon
- motor beceri kısıtları için ölçüme dayalı simülasyon
- PO, geliştirici ve iş analisti için profesyonel HTML raporu
- Jira summary ve Jira description üretimi
- production gate kararı: `PASS`, `PASS_WITH_RISK`, `FAIL`

## Kurulum

Repo kökünden:

```powershell
.\scripts\install-skill.ps1
```

Manuel kurulum için `skills/` altındaki skill klasörlerini şu dizine kopyalayın:

```text
$HOME\.codex\skills\
```

Beklenen ana yollar:

```text
$HOME\.codex\skills\accessimind-accessible-ui-agent-skill\SKILL.md
$HOME\.codex\skills\playwright\SKILL.md
$HOME\.codex\skills\senior-developer-20y\SKILL.md
$HOME\.codex\skills\nvda-portable-a11y-audit\SKILL.md
$HOME\.codex\skills\full-persona-a11y-audit\SKILL.md
```

## Doğrulama

Skill yapısını doğrulayın:

```powershell
python .\scripts\quick_validate.py .\skills\accessimind-accessible-ui-agent-skill
```

Harness scriptlerini doğrulayın:

```powershell
node --check .\skills\accessimind-accessible-ui-agent-skill\scripts\nvda_web_audit.mjs
node --check .\skills\accessimind-accessible-ui-agent-skill\scripts\low_vision_web_audit.mjs
node --check .\skills\accessimind-accessible-ui-agent-skill\scripts\motor_web_audit.mjs
```

## Codex İçinde Nasıl Tetiklenir

Örnek istekler:

```text
Bu sayfayı $accessimind-accessible-ui-agent-skill ile WCAG 2.2 açısından denetle.
```

```text
Swiper carousel için NVDA, az gören ve motor beceri kanıtlarıyla profesyonel HTML rapor oluştur.
```

```text
Bu React modal akışını $accessimind-accessible-ui-agent-skill ile production-ready ve erişilebilir hale getir.
```

```text
Bu Android ekranını TalkBack ve genel erişilebilirlik regresyonları açısından incele.
```

## Önerilen Çalışma Akışı

1. Kapsamı belirleyin: URL, component, selector, ekran veya kullanıcı akışı.
2. Codex’ten önce mevcut stack’i ve runtime koşullarını incelemesini isteyin.
3. Tarayıcı/DOM kanıtını Playwright ile alın.
4. Ekran okuyucu gerekiyorsa NVDA kanıtını gerçek speech log ile alın.
5. Az gören kullanıcılar için zoom, reflow, text spacing, contrast, forced-colors ve focus ölçümlerini alın.
6. Motor beceri için hedef boyutu, hedef aralığı, klavye sırası, pointer actionability ve drag alternatifi ölçümlerini alın.
7. Bulguları WCAG 2.2, kullanıcı etkisi, severity ve remediation ile raporlayın.
8. HTML raporda Jira summary ve Jira description bölümlerini ekleyin.
9. Sonucu `PASS`, `PASS_WITH_RISK` veya `FAIL` olarak kapatın.

## NVDA Web Kanıtı

Çalışma alanında bağımlılıkları kurun:

```powershell
cmd /c npm.cmd install playwright @guidepup/guidepup @guidepup/setup
cmd /c npx.cmd @guidepup/setup
```

NVDA web-only audit örneği:

```powershell
node .\skills\accessimind-accessible-ui-agent-skill\scripts\nvda_web_audit.mjs `
  --url https://www.example.com `
  --selector "#main" `
  --out output\nvda-web-audit.json `
  --next 80 `
  --previous 20 `
  --tab 30
```

Bu script şunları ayırır:
- gerçek web sayfası konuşmaları
- tarayıcı foreground sahipliği
- sayfa title token doğrulaması
- Windows veya başka uygulamalardan gelen bildirim gürültüsü
- DOM inventory ve coverage karşılaştırması
- ileri/geri NVDA traversal
- Tab traversal

NVDA çıktısı azsa veya foreground doğrulanamıyorsa raporda bunu açıkça `blocked` veya `unverified` olarak işaretleyin. Konuşma çıktısı uydurmayın.

## Az Gören Kullanıcı Kanıtı

Örnek:

```powershell
node .\skills\accessimind-accessible-ui-agent-skill\scripts\low_vision_web_audit.mjs `
  --url https://www.example.com `
  --selector "#main" `
  --out output\low-vision-audit.json `
  --artifacts output\low-vision
```

Bu script şu koşulları ölçer:
- desktop
- mobile
- 200% eşdeğer viewport
- 400% eşdeğer viewport
- WCAG text spacing
- forced colors
- contrast
- focus görünürlüğü
- clipping/overflow
- yoğun hedef kümeleri

Az gören bulguları özet olmamalıdır. Her bulgu ölçülen element, ekran görüntüsü, bounding box, contrast, overflow, focus style veya target spacing gibi somut kanıt içermelidir.

## Motor Beceri Kanıtı

Örnek:

```powershell
node .\skills\accessimind-accessible-ui-agent-skill\scripts\motor_web_audit.mjs `
  --url https://www.example.com `
  --selector "#main" `
  --out output\motor-audit.json `
  --artifacts output\motor `
  --focusSteps 80 `
  --actionabilityChecks 60
```

Bu script şu kanıtları üretir:
- desktop pointer senaryosu
- desktop keyboard senaryosu
- mobile touch senaryosu
- interactive element inventory
- hedef boyutu
- en yakın interaktif hedef mesafesi
- Tab sırası
- pointer actionability
- drag/slider/carousel/sürükleme adayları
- klavye veya buton alternatifi olup olmadığı

Motor bulguları da özet olmamalıdır. Örneğin `motor kullanıcılar zorlanır` yerine `mobile-touch koşulunda carousel pagination hedefi 16x16px ve en yakın hedefe 4px uzaklıkta` gibi ölçülü yazılmalıdır.

## Profesyonel HTML Rapor Beklentisi

Rapor şu bölümleri içermelidir:
- içindekiler tablosu
- kapsam
- metodoloji
- executive summary
- kanıt artifact yolları
- WCAG 2.2 bulgu tablosu
- NVDA konuşma çıktıları
- NVDA coverage matrix
- az gören ölçüm tablosu
- motor beceri ölçüm tablosu
- Jira summary
- Jira description
- remediation önerileri
- QA/regression planı
- referanslar
- production gate kararı

Rapor dili PO, geliştirici ve iş analistinin birlikte kullanabileceği netlikte olmalıdır. Teknik detaylar saklanmamalı, ancak her bulgunun iş etkisi ve kullanıcı etkisi anlaşılır yazılmalıdır.

## Jira Alanları

HTML rapor içinde Jira alanlarını ayrı konumlandırın:

```text
Jira Summary:
[Component] Carousel controls are not operable with reliable screen-reader, low-vision, and motor access

Jira Description:
Scope:
Evidence:
Observed:
Expected:
User impact:
WCAG references:
Remediation:
Acceptance criteria:
QA notes:
```

Her kritik veya high bulgu için acceptance criteria ölçülebilir olmalıdır.

## Kalite Kapıları

Rapor sonunda şu kapıları değerlendirin:
- `G1 Coverage`: kapsam ve test edilmeyen alanlar açık mı?
- `G2 Keyboard`: klavye ile temel akış tamamlanabiliyor mu?
- `G3 Semantics`: name, role, state, relationship doğru mu?
- `G4 WCAG`: critical/high bulgular için karar var mı?
- `G5 Evidence`: her ana iddia artifact ile destekli mi?
- `G6 Assistive-tech and visual measurement`: NVDA ve görsel ölçüm kanıtı var mı?

Eksik canlı ekran okuyucu veya pixel-level görsel kanıt varsa production sign-off verilmemelidir.
