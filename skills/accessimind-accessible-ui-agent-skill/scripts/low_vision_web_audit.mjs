#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import { createRequire } from "node:module";

const requireFromCwd = createRequire(path.join(process.cwd(), "package.json"));
const { chromium } = requireFromCwd("playwright");

const args = parseArgs(process.argv.slice(2));
const targetUrl = requiredArg(args, "url");
const targetSelector = args.selector || "body";
const outPath = args.out || path.resolve(process.cwd(), "low-vision-web-audit.json");
const artifactDir = args.artifacts || path.join(path.dirname(outPath), "low-vision-artifacts");
const browserChannel = args.channel || "chrome";

const scenarios = [
  { id: "desktop", width: 1280, height: 720, textSpacing: false, forcedColors: false },
  { id: "mobile", width: 390, height: 844, textSpacing: false, forcedColors: false },
  { id: "zoom-200-equivalent", width: 640, height: 720, textSpacing: false, forcedColors: false },
  { id: "zoom-400-equivalent", width: 320, height: 720, textSpacing: false, forcedColors: false },
  { id: "text-spacing", width: 640, height: 720, textSpacing: true, forcedColors: false },
  { id: "forced-colors", width: 640, height: 720, textSpacing: false, forcedColors: true },
];

const result = {
  url: targetUrl,
  selector: targetSelector,
  startedAt: new Date().toISOString(),
  browserChannel,
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
      colorScheme: "light",
    });
    const page = await context.newPage();
    if (scenario.forcedColors) {
      await page.emulateMedia({ forcedColors: "active" }).catch((error) => {
        result.limitations.push(`forced-colors emulation failed: ${error.message}`);
      });
    }
    await page.goto(targetUrl, { waitUntil: "domcontentloaded", timeout: 60000 });
    await page.waitForLoadState("networkidle", { timeout: 20000 }).catch(() => {});
    await dismissCommonOverlays(page);
    if (scenario.textSpacing) await injectTextSpacing(page);
    await page.locator(targetSelector).first().scrollIntoViewIfNeeded({ timeout: 10000 }).catch(() => {});
    await page.waitForTimeout(500);

    const screenshot = path.join(artifactDir, `${scenario.id}.png`);
    await page.screenshot({ path: screenshot, fullPage: false, scale: "css" });
    const measurement = await measureScenario(page, targetSelector, scenario);
    measurement.screenshot = screenshot;
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
  const focusRows = [];
  const focusable = await page.locator(`${selector} a[href], ${selector} button, ${selector} input, ${selector} select, ${selector} textarea, ${selector} [tabindex]:not([tabindex="-1"])`).count().catch(() => 0);
  for (let i = 0; i < Math.min(focusable, 20); i += 1) {
    const locator = page.locator(`${selector} a[href], ${selector} button, ${selector} input, ${selector} select, ${selector} textarea, ${selector} [tabindex]:not([tabindex="-1"])`).nth(i);
    await locator.focus({ timeout: 1000 }).catch(() => {});
    focusRows.push(await page.evaluate(() => {
      const el = document.activeElement;
      const rect = el?.getBoundingClientRect?.();
      const cs = el ? getComputedStyle(el) : null;
      return {
        tag: el?.tagName || null,
        id: el?.id || null,
        className: String(el?.className || "").slice(0, 120),
        name: (el?.getAttribute?.("aria-label") || el?.innerText || el?.getAttribute?.("title") || "").replace(/\s+/g, " ").trim().slice(0, 180),
        role: el?.getAttribute?.("role"),
        rect: rect ? box(rect) : null,
        outlineStyle: cs?.outlineStyle,
        outlineWidth: cs?.outlineWidth,
        outlineColor: cs?.outlineColor,
        boxShadow: cs?.boxShadow,
        clipped: rect ? rect.top < 0 || rect.left < 0 || rect.bottom > innerHeight || rect.right > innerWidth : null,
      };
    }));
  }

  return page.evaluate(({ selectorValue, scenarioValue, focusRowsValue }) => {
    const target = document.querySelector(selectorValue) || document.body;
    const visible = (el) => {
      const rect = el.getBoundingClientRect();
      const cs = getComputedStyle(el);
      return rect.width > 0 && rect.height > 0 && cs.display !== "none" && cs.visibility !== "hidden";
    };
    const text = [...target.querySelectorAll("h1,h2,h3,h4,h5,h6,p,a,button,label,span,li")]
      .filter(visible)
      .slice(0, 80)
      .map((el) => inspectElement(el));
    const controls = [...target.querySelectorAll("a[href],button,input,select,textarea,[role='button'],[tabindex]:not([tabindex='-1'])")]
      .filter(visible)
      .slice(0, 80)
      .map((el) => inspectElement(el));
    const targetRect = target.getBoundingClientRect();
    const overflow = {
      documentScrollWidth: document.documentElement.scrollWidth,
      viewportWidth: innerWidth,
      horizontalOverflow: document.documentElement.scrollWidth > innerWidth,
      targetClipped: targetRect.left < 0 || targetRect.top < 0 || targetRect.right > innerWidth || targetRect.bottom > innerHeight,
    };
    return {
      scenario: scenarioValue,
      viewport: { width: innerWidth, height: innerHeight },
      target: inspectElement(target),
      overflow,
      text,
      controls,
      focusRows: focusRowsValue,
    };

    function inspectElement(el) {
      const rect = el.getBoundingClientRect();
      const cs = getComputedStyle(el);
      const fg = cs.color;
      const bg = effectiveBackground(el);
      return {
        tag: el.tagName,
        id: el.id || null,
        className: String(el.className || "").slice(0, 120),
        role: el.getAttribute("role"),
        name: (el.getAttribute("aria-label") || el.innerText || el.getAttribute("title") || el.getAttribute("alt") || "").replace(/\s+/g, " ").trim().slice(0, 180),
        rect: box(rect),
        fontSize: cs.fontSize,
        lineHeight: cs.lineHeight,
        color: fg,
        backgroundColor: bg,
        contrast: contrastRatio(fg, bg),
        overflowX: cs.overflowX,
        overflowY: cs.overflowY,
        clipped: rect.left < 0 || rect.top < 0 || rect.right > innerWidth || rect.bottom > innerHeight,
        targetTooSmall: (el.matches("a,button,input,select,textarea,[role='button'],[tabindex]") && (rect.width < 24 || rect.height < 24)),
      };
    }

    function effectiveBackground(el) {
      let node = el;
      while (node && node.nodeType === 1) {
        const bg = getComputedStyle(node).backgroundColor;
        if (bg && !/rgba?\(0,\s*0,\s*0,\s*0\)|transparent/i.test(bg)) return bg;
        node = node.parentElement;
      }
      return "rgb(255, 255, 255)";
    }

    function box(rect) {
      return {
        x: Math.round(rect.x),
        y: Math.round(rect.y),
        width: Math.round(rect.width),
        height: Math.round(rect.height),
      };
    }

    function contrastRatio(foreground, background) {
      const fg = rgb(foreground);
      const bg = rgb(background);
      if (!fg || !bg) return null;
      const l1 = luminance(fg);
      const l2 = luminance(bg);
      const lighter = Math.max(l1, l2);
      const darker = Math.min(l1, l2);
      return Number(((lighter + 0.05) / (darker + 0.05)).toFixed(2));
    }

    function rgb(value) {
      const match = String(value).match(/rgba?\((\d+),\s*(\d+),\s*(\d+)/i);
      if (!match) return null;
      return [Number(match[1]), Number(match[2]), Number(match[3])];
    }

    function luminance(parts) {
      const [r, g, b] = parts.map((v) => {
        const s = v / 255;
        return s <= 0.03928 ? s / 12.92 : Math.pow((s + 0.055) / 1.055, 2.4);
      });
      return 0.2126 * r + 0.7152 * g + 0.0722 * b;
    }
  }, { selectorValue: selector, scenarioValue: scenario, focusRowsValue: focusRows });
}

function deriveFindings(measurement) {
  const findings = [];
  if (measurement.overflow.horizontalOverflow) {
    findings.push(finding(measurement, "horizontal-overflow", measurement.target, "Horizontal overflow is present.", "No horizontal scrolling at reflow/zoom conditions."));
  }
  for (const control of measurement.controls || []) {
    if (control.targetTooSmall) {
      findings.push(finding(measurement, "target-too-small", control, `Target is ${control.rect.width}x${control.rect.height}px.`, "Interactive targets should be at least 24x24 CSS px for WCAG 2.5.8."));
    }
    if (control.contrast !== null && control.contrast < 3) {
      findings.push(finding(measurement, "control-contrast-low", control, `Computed contrast is ${control.contrast}:1.`, "Controls and essential graphics need sufficient contrast."));
    }
  }
  for (const row of measurement.focusRows || []) {
    if (row.outlineStyle === "none" && (!row.boxShadow || row.boxShadow === "none")) {
      findings.push(finding(measurement, "focus-not-visible", row, "Focused element has no outline or box-shadow.", "Focused controls need a visible focus indicator."));
    }
    if (row.clipped) {
      findings.push(finding(measurement, "focus-clipped", row, "Focused element is clipped or outside the viewport.", "Focus must remain visible and not obscured."));
    }
  }
  return findings;
}

function finding(measurement, type, element, observed, expected) {
  return {
    type,
    scenario: measurement.scenario.id,
    selector: targetSelector,
    element,
    screenshot: measurement.screenshot,
    observed,
    expected,
    confidence: "medium",
  };
}

async function dismissCommonOverlays(page) {
  const selectors = [
    "#onetrust-reject-all-handler",
    "#onetrust-accept-btn-handler",
    "button:has-text('Tüm Çerezleri Reddet')",
    "button:has-text('Reject All')",
    "button:has-text('Accept All')",
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

async function injectTextSpacing(page) {
  await page.addStyleTag({
    content: `
      * {
        line-height: 1.5 !important;
        letter-spacing: 0.12em !important;
        word-spacing: 0.16em !important;
      }
      p { margin-bottom: 2em !important; }
    `,
  });
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
