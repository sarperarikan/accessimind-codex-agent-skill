#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import { createRequire } from "node:module";

const requireFromCwd = createRequire(path.join(process.cwd(), "package.json"));
const { chromium } = requireFromCwd("playwright");

const args = parseArgs(process.argv.slice(2));
const targetUrl = requiredArg(args, "url");
const targetSelector = args.selector || "body";
const outPath = args.out || path.resolve(process.cwd(), "motor-web-audit.json");
const artifactDir = args.artifacts || path.join(path.dirname(outPath), "motor-artifacts");
const browserChannel = args.channel || "chrome";
const maxFocusSteps = Number(args.focusSteps || 60);
const maxActionabilityChecks = Number(args.actionabilityChecks || 40);

const scenarios = [
  { id: "desktop-pointer", width: 1280, height: 720, isMobile: false, hasTouch: false },
  { id: "desktop-keyboard", width: 1280, height: 720, isMobile: false, hasTouch: false },
  { id: "mobile-touch", width: 390, height: 844, isMobile: true, hasTouch: true },
];

const result = {
  url: targetUrl,
  selector: targetSelector,
  startedAt: new Date().toISOString(),
  browserChannel,
  thresholds: {
    wcagMinimumTargetCssPx: 24,
    enhancedTargetCssPx: 44,
    denseSpacingCssPx: 8,
  },
  scenarios: [],
  findings: [],
  limitations: [],
};

let browser;

try {
  fs.mkdirSync(path.dirname(path.resolve(outPath)), { recursive: true });
  fs.mkdirSync(path.resolve(artifactDir), { recursive: true });
  browser = await launchBrowser(browserChannel);

  for (const scenario of scenarios) {
    const context = await browser.newContext({
      viewport: { width: scenario.width, height: scenario.height },
      isMobile: scenario.isMobile,
      hasTouch: scenario.hasTouch,
      colorScheme: "light",
    });
    const page = await context.newPage();
    await page.goto(targetUrl, { waitUntil: "domcontentloaded", timeout: 60000 });
    await page.waitForLoadState("networkidle", { timeout: 20000 }).catch(() => {});
    await dismissCommonOverlays(page);
    await page.locator(targetSelector).first().scrollIntoViewIfNeeded({ timeout: 10000 }).catch(() => {});
    await page.waitForTimeout(500);

    const screenshot = path.join(artifactDir, `${scenario.id}.png`);
    await page.screenshot({ path: screenshot, fullPage: false, scale: "css" });

    const measurement = await measureScenario(page, targetSelector, scenario);
    measurement.screenshot = screenshot;
    measurement.keyboardTrace = await collectKeyboardTrace(page, targetSelector, maxFocusSteps);
    measurement.pointerActionability = await collectPointerActionability(page, targetSelector, maxActionabilityChecks);

    result.scenarios.push(measurement);
    result.findings.push(...deriveFindings(measurement));
    await context.close();
  }

  result.finishedAt = new Date().toISOString();
} catch (error) {
  result.error = error?.stack || error?.message || String(error);
  process.exitCode = 1;
} finally {
  if (browser) await browser.close().catch(() => {});
  fs.writeFileSync(outPath, JSON.stringify(result, null, 2), "utf8");
  console.log(JSON.stringify(result, null, 2));
}

async function launchBrowser(channel) {
  try {
    return await chromium.launch({ channel, headless: false, args: ["--disable-notifications"] });
  } catch (error) {
    if (channel !== "msedge") {
      result.limitations.push(`Could not launch ${channel}; falling back to msedge. ${error.message}`);
      return chromium.launch({ channel: "msedge", headless: false, args: ["--disable-notifications"] });
    }
    throw error;
  }
}

async function measureScenario(page, selector, scenario) {
  return page.evaluate(({ selectorValue, scenarioValue }) => {
    const interactiveSelector = [
      "a[href]",
      "button",
      "input",
      "select",
      "textarea",
      "summary",
      "[role='button']",
      "[role='link']",
      "[role='menuitem']",
      "[role='tab']",
      "[role='slider']",
      "[role='switch']",
      "[role='checkbox']",
      "[tabindex]:not([tabindex='-1'])",
    ].join(",");
    const target = document.querySelector(selectorValue) || document.body;
    const controls = [...target.querySelectorAll(interactiveSelector)]
      .filter(isVisible)
      .slice(0, 180)
      .map((el, index) => inspectElement(el, index));

    const withSpacing = controls.map((control, index) => {
      const nearest = nearestNeighbor(control, controls, index);
      return { ...control, nearestInteractive: nearest };
    });

    const dragCandidates = [...target.querySelectorAll([
      "[draggable='true']",
      "[role='slider']",
      "[role='separator'][aria-orientation]",
      "input[type='range']",
      "[class*='drag' i]",
      "[class*='slider' i]",
      "[class*='swiper' i]",
      "[class*='carousel' i]",
      "[class*='resize' i]",
    ].join(","))]
      .filter(isVisible)
      .slice(0, 80)
      .map((el, index) => {
        const inspected = inspectElement(el, index);
        const keyboardAlternative = Boolean(
          el.matches("input[type='range'],[role='slider'],button,a[href],[tabindex]:not([tabindex='-1'])") ||
          el.querySelector("button,a[href],input[type='range'],[role='button'],[tabindex]:not([tabindex='-1'])")
        );
        return { ...inspected, keyboardAlternative };
      });

    const hoverDisclosureCandidates = [...target.querySelectorAll("[title],[aria-describedby],[class*='tooltip' i],[class*='dropdown' i],[class*='menu' i],[class*='hover' i]")]
      .filter(isVisible)
      .slice(0, 80)
      .map((el, index) => inspectElement(el, index));

    return {
      scenario: scenarioValue,
      viewport: { width: innerWidth, height: innerHeight },
      target: inspectElement(target, -1),
      controls: withSpacing,
      dragCandidates,
      hoverDisclosureCandidates,
      documentMetrics: {
        scrollWidth: document.documentElement.scrollWidth,
        scrollHeight: document.documentElement.scrollHeight,
        horizontalOverflow: document.documentElement.scrollWidth > innerWidth,
      },
    };

    function inspectElement(el, index) {
      const rect = el.getBoundingClientRect();
      const role = el.getAttribute("role") || implicitRole(el);
      const name = accessibleNameApprox(el);
      const disabled = el.disabled === true || el.getAttribute("aria-disabled") === "true";
      return {
        index,
        selector: stableSelector(el),
        tag: el.tagName,
        id: el.id || null,
        className: String(el.className || "").replace(/\s+/g, " ").trim().slice(0, 160),
        role,
        name,
        type: el.getAttribute("type"),
        tabindex: el.getAttribute("tabindex"),
        disabled,
        ariaDisabled: el.getAttribute("aria-disabled"),
        rect: box(rect),
        center: { x: Math.round(rect.left + rect.width / 2), y: Math.round(rect.top + rect.height / 2) },
        targetTooSmall24: rect.width < 24 || rect.height < 24,
        targetBelowEnhanced44: rect.width < 44 || rect.height < 44,
        clipped: rect.left < 0 || rect.top < 0 || rect.right > innerWidth || rect.bottom > innerHeight,
        focusableByDefault: focusableByDefault(el),
      };
    }

    function nearestNeighbor(control, controlsValue, index) {
      let nearest = null;
      for (let i = 0; i < controlsValue.length; i += 1) {
        if (i === index) continue;
        const other = controlsValue[i];
        const distance = rectDistance(control.rect, other.rect);
        if (!nearest || distance < nearest.distance) {
          nearest = {
            distance,
            selector: other.selector,
            role: other.role,
            name: other.name,
            rect: other.rect,
            overlapping: distance === 0 && rectanglesOverlap(control.rect, other.rect),
          };
        }
      }
      return nearest;
    }

    function rectDistance(a, b) {
      const ax2 = a.x + a.width;
      const ay2 = a.y + a.height;
      const bx2 = b.x + b.width;
      const by2 = b.y + b.height;
      const dx = Math.max(b.x - ax2, a.x - bx2, 0);
      const dy = Math.max(b.y - ay2, a.y - by2, 0);
      return Math.round(Math.sqrt(dx * dx + dy * dy));
    }

    function rectanglesOverlap(a, b) {
      return a.x < b.x + b.width && a.x + a.width > b.x && a.y < b.y + b.height && a.y + a.height > b.y;
    }

    function isVisible(el) {
      const rect = el.getBoundingClientRect();
      const cs = getComputedStyle(el);
      return rect.width > 0 && rect.height > 0 && cs.display !== "none" && cs.visibility !== "hidden";
    }

    function box(rect) {
      return {
        x: Math.round(rect.x),
        y: Math.round(rect.y),
        width: Math.round(rect.width),
        height: Math.round(rect.height),
      };
    }

    function accessibleNameApprox(el) {
      const labelledBy = el.getAttribute("aria-labelledby");
      if (labelledBy) {
        const value = labelledBy.split(/\s+/).map((id) => document.getElementById(id)?.innerText || "").join(" ");
        if (value.trim()) return normalize(value);
      }
      return normalize(
        el.getAttribute("aria-label") ||
        el.getAttribute("alt") ||
        el.innerText ||
        el.getAttribute("title") ||
        el.getAttribute("value") ||
        ""
      );
    }

    function normalize(value) {
      return String(value).replace(/\s+/g, " ").trim().slice(0, 180);
    }

    function implicitRole(el) {
      const tag = el.tagName.toLowerCase();
      if (tag === "button") return "button";
      if (tag === "a" && el.hasAttribute("href")) return "link";
      if (tag === "select") return "combobox";
      if (tag === "textarea") return "textbox";
      if (tag === "summary") return "button";
      if (tag === "input") {
        const type = (el.getAttribute("type") || "text").toLowerCase();
        if (type === "checkbox") return "checkbox";
        if (type === "radio") return "radio";
        if (type === "range") return "slider";
        if (type === "submit" || type === "button" || type === "reset") return "button";
        return "textbox";
      }
      return null;
    }

    function focusableByDefault(el) {
      return el.matches("a[href],button,input,select,textarea,summary,[tabindex]:not([tabindex='-1'])") && !el.disabled;
    }

    function stableSelector(el) {
      if (el.id) return `#${CSS.escape(el.id)}`;
      const parts = [];
      let node = el;
      while (node && node.nodeType === 1 && parts.length < 4) {
        let part = node.tagName.toLowerCase();
        const className = String(node.className || "").trim().split(/\s+/).filter(Boolean)[0];
        if (className) part += `.${CSS.escape(className)}`;
        const parent = node.parentElement;
        if (parent) {
          const siblings = [...parent.children].filter((child) => child.tagName === node.tagName);
          if (siblings.length > 1) part += `:nth-of-type(${siblings.indexOf(node) + 1})`;
        }
        parts.unshift(part);
        node = parent;
      }
      return parts.join(" > ");
    }
  }, { selectorValue: selector, scenarioValue: scenario });
}

async function collectKeyboardTrace(page, selector, maxSteps) {
  const rows = [];
  await page.keyboard.press("Home").catch(() => {});
  for (let step = 0; step < maxSteps; step += 1) {
    await page.keyboard.press("Tab");
    await page.waitForTimeout(80);
    const row = await page.evaluate((selectorValue) => {
      const target = document.querySelector(selectorValue) || document.body;
      const el = document.activeElement;
      if (!el) return { step: null, insideTarget: false };
      const rect = el.getBoundingClientRect();
      const cs = getComputedStyle(el);
      return {
        insideTarget: target.contains(el),
        tag: el.tagName,
        id: el.id || null,
        className: String(el.className || "").replace(/\s+/g, " ").trim().slice(0, 160),
        role: el.getAttribute("role"),
        name: (el.getAttribute("aria-label") || el.innerText || el.getAttribute("title") || "").replace(/\s+/g, " ").trim().slice(0, 180),
        tabindex: el.getAttribute("tabindex"),
        rect: {
          x: Math.round(rect.x),
          y: Math.round(rect.y),
          width: Math.round(rect.width),
          height: Math.round(rect.height),
        },
        clipped: rect.left < 0 || rect.top < 0 || rect.right > innerWidth || rect.bottom > innerHeight,
        outlineStyle: cs.outlineStyle,
        outlineWidth: cs.outlineWidth,
        boxShadow: cs.boxShadow,
      };
    }, selector);
    rows.push({ step: step + 1, ...row });
  }
  return rows;
}

async function collectPointerActionability(page, selector, maxChecks) {
  const rows = [];
  const locator = page.locator(`${selector} a[href], ${selector} button, ${selector} input, ${selector} select, ${selector} textarea, ${selector} summary, ${selector} [role='button'], ${selector} [role='link'], ${selector} [role='tab'], ${selector} [role='slider'], ${selector} [tabindex]:not([tabindex="-1"])`);
  const count = await locator.count().catch(() => 0);
  for (let i = 0; i < Math.min(count, maxChecks); i += 1) {
    const item = locator.nth(i);
    const identity = await item.evaluate((el) => ({
      tag: el.tagName,
      id: el.id || null,
      role: el.getAttribute("role"),
      name: (el.getAttribute("aria-label") || el.innerText || el.getAttribute("title") || "").replace(/\s+/g, " ").trim().slice(0, 180),
    })).catch(() => ({ tag: null, id: null, role: null, name: "" }));
    let actionable = true;
    let error = null;
    await item.click({ trial: true, timeout: 1500 }).catch((trialError) => {
      actionable = false;
      error = trialError.message.split("\n")[0];
    });
    rows.push({ index: i, ...identity, actionable, error });
  }
  return rows;
}

function deriveFindings(measurement) {
  const findings = [];
  for (const control of measurement.controls || []) {
    if (control.targetTooSmall24) {
      findings.push(finding(measurement, "target-too-small-24", control, `Target is ${control.rect.width}x${control.rect.height}px.`, "Interactive targets should be at least 24x24 CSS px unless a documented exception applies.", "WCAG 2.2 SC 2.5.8 Target Size (Minimum)"));
    }
    if (control.nearestInteractive && control.nearestInteractive.distance < 8) {
      findings.push(finding(measurement, "dense-target-spacing", control, `Nearest interactive target is ${control.nearestInteractive.distance}px away.`, "Adjacent interactive targets should have enough spacing to reduce accidental activation risk.", "WCAG 2.2 SC 2.5.8 Target Size (Minimum)"));
    }
    if (control.clipped) {
      findings.push(finding(measurement, "clipped-target", control, "Interactive target is clipped or outside the viewport.", "Targets should remain fully operable in the tested viewport.", "WCAG 2.1 SC 1.4.10 Reflow"));
    }
  }

  const reached = new Set((measurement.keyboardTrace || []).filter((row) => row.insideTarget).map((row) => `${row.tag}|${row.id}|${row.name}`));
  for (const control of measurement.controls || []) {
    if (!control.disabled && control.focusableByDefault) {
      const key = `${control.tag}|${control.id}|${control.name}`;
      if (!reached.has(key)) {
        findings.push(finding(measurement, "not-reached-in-tab-trace", control, "Control was not reached in the configured Tab traversal trace.", "Keyboard traversal should reach operable controls in a meaningful sequence.", "WCAG 2.1 SC 2.1.1 Keyboard"));
      }
    }
  }

  for (const row of measurement.keyboardTrace || []) {
    if (row.tag === "BODY" || row.tag === "HTML") continue;
    if (row.insideTarget && row.clipped) {
      findings.push(finding(measurement, "focused-target-clipped", row, "Focused element is clipped or outside the viewport.", "Keyboard focus should remain visible and operable.", "WCAG 2.4.11 Focus Appearance"));
    }
    if (row.insideTarget && row.outlineStyle === "none" && (!row.boxShadow || row.boxShadow === "none")) {
      findings.push(finding(measurement, "focused-target-not-visible", row, "Focused element has no outline or box-shadow.", "Keyboard focus should have a visible indicator.", "WCAG 2.4.7 Focus Visible"));
    }
  }

  for (const row of measurement.pointerActionability || []) {
    if (!row.actionable) {
      findings.push(finding(measurement, "pointer-actionability-failed", row, row.error || "Playwright trial click could not verify actionability.", "Pointer-operable controls should be visible, stable, enabled, and receive pointer events.", "WCAG 2.5.8 Target Size (Minimum)"));
    }
  }

  for (const candidate of measurement.dragCandidates || []) {
    if (!candidate.keyboardAlternative) {
      findings.push(finding(measurement, "drag-or-precision-without-keyboard-alternative", candidate, "Detected a drag/slider/carousel-like widget without an evident keyboard or button alternative.", "Dragging or precise pointer gestures should have single-pointer and keyboard-accessible alternatives.", "WCAG 2.2 SC 2.5.7 Dragging Movements"));
    }
  }

  return findings;
}

function finding(measurement, type, element, observed, expected, wcag) {
  return {
    type,
    scenario: measurement.scenario.id,
    selector: targetSelector,
    element,
    screenshot: measurement.screenshot,
    observed,
    expected,
    wcag,
    affectedInteraction: interactionForType(type),
    confidence: type === "drag-or-precision-without-keyboard-alternative" ? "medium" : "high",
  };
}

function interactionForType(type) {
  if (type.includes("keyboard") || type.includes("focus") || type.includes("tab")) return "keyboard-only and switch access";
  if (type.includes("drag")) return "limited dexterity, tremor, keyboard-only, and switch access";
  if (type.includes("pointer") || type.includes("target") || type.includes("spacing")) return "low pointer precision, tremor, and touch access";
  return "motor-limited interaction";
}

async function dismissCommonOverlays(page) {
  const selectors = [
    "#onetrust-reject-all-handler",
    "#onetrust-accept-btn-handler",
    "button:has-text('Tüm Çerezleri Reddet')",
    "button:has-text('Reject All')",
    "button:has-text('Accept All')",
    "button:has-text('Kabul Et')",
  ];
  for (const selector of selectors) {
    const locator = page.locator(selector).first();
    if (await locator.count().catch(() => 0)) {
      await locator.click({ timeout: 2500 }).catch(() => {});
      await page.waitForTimeout(500);
      break;
    }
  }
}

function parseArgs(rawArgs) {
  const parsed = {};
  for (let i = 0; i < rawArgs.length; i += 1) {
    const arg = rawArgs[i];
    if (!arg.startsWith("--")) continue;
    const key = arg.slice(2);
    const next = rawArgs[i + 1];
    if (!next || next.startsWith("--")) parsed[key] = "true";
    else {
      parsed[key] = next;
      i += 1;
    }
  }
  return parsed;
}

function requiredArg(parsed, name) {
  if (!parsed[name]) throw new Error(`Missing required argument --${name}`);
  return parsed[name];
}
