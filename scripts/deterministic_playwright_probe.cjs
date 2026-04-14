const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

function parseArgs(argv) {
  const result = {};
  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (!token.startsWith('--')) continue;
    const key = token.slice(2);
    const value = argv[i + 1];
    if (!value || value.startsWith('--')) {
      result[key] = 'true';
      continue;
    }
    result[key] = value;
    i += 1;
  }
  return result;
}

async function collectScrollCoverage(page) {
  const checkpoints = [0, 20, 40, 60, 80, 100];
  const results = [];
  for (const checkpoint of checkpoints) {
    const sample = await page.evaluate((pct) => {
      const doc = document.documentElement;
      const max = Math.max(0, doc.scrollHeight - window.innerHeight);
      const y = Math.round(max * (pct / 100));
      window.scrollTo(0, y);
      return {
        checkpoint: pct,
        scrollY: window.scrollY,
        scrollHeight: doc.scrollHeight,
        viewportHeight: window.innerHeight,
      };
    }, checkpoint);
    results.push(sample);
    await page.waitForTimeout(200);
  }
  await page.evaluate(() => {
    window.scrollTo(0, 0);
  });
  return results;
}

async function collectCookieState(page) {
  return page.evaluate(() => {
    const elements = Array.from(document.querySelectorAll('*'));
    const dialogs = elements.filter((el) => {
      const id = (el.id || '').toLowerCase();
      const cls = (el.className || '').toString().toLowerCase();
      return el.matches('[role="dialog"], dialog, .modal') || id.includes('cookie') || cls.includes('cookie');
    });
    const visibleDialogs = dialogs.filter((dialog) => {
      const style = window.getComputedStyle(dialog);
      const rect = dialog.getBoundingClientRect();
      return style.display !== 'none' && style.visibility !== 'hidden' && rect.width > 0 && rect.height > 0;
    });
    const candidates = Array.from(document.querySelectorAll('button, [role="button"], a')).filter((el) => {
      const text = ((el.getAttribute('aria-label') || el.textContent || '').trim()).toLowerCase();
      return text.includes('accept') || text.includes('kabul') || text.includes('allow all') || text.includes('tum cerezleri kabul');
    });
    const clicked = [];
    if (visibleDialogs.length > 0 && candidates.length > 0) {
      for (const candidate of candidates.slice(0, 3)) {
        try {
          candidate.click();
          clicked.push((candidate.getAttribute('aria-label') || candidate.textContent || '').trim().slice(0, 120));
        } catch (_) {}
      }
    }
    window.scrollTo(0, 0);
    return {
      inspected: true,
      dialogCount: visibleDialogs.length,
      accepted: clicked.length > 0,
      acceptedActions: clicked,
    };
  });
}

async function collectStatefulCoverage(page) {
  return page.evaluate(() => {
    const results = [];
    const seen = new Set();
    const pushResult = (el, kind) => {
      const key = `${kind}|${el.tagName}|${el.id || ''}|${(el.getAttribute('aria-label') || el.textContent || '').trim().slice(0, 80)}`;
      if (seen.has(key)) return;
      seen.add(key);
      results.push({
        kind,
        name: (el.getAttribute('aria-label') || el.textContent || '').trim().slice(0, 120),
        role: el.getAttribute('role') || '',
        tag: el.tagName,
        expanded: el.getAttribute('aria-expanded') || '',
      });
    };
    const clickIfPossible = (el, kind) => {
      const rect = el.getBoundingClientRect();
      const style = window.getComputedStyle(el);
      if (rect.width <= 0 || rect.height <= 0 || style.visibility === 'hidden' || style.display === 'none') return;
      try {
        el.click();
        pushResult(el, kind);
      } catch (_) {}
    };

    const candidates = [
      ...Array.from(document.querySelectorAll('summary')).slice(0, 3).map((el) => ({ el, kind: 'summary-toggle' })),
      ...Array.from(document.querySelectorAll('[aria-expanded]')).slice(0, 5).map((el) => ({ el, kind: 'expandable-control' })),
      ...Array.from(document.querySelectorAll('[role="tab"]')).slice(0, 5).map((el) => ({ el, kind: 'tab-control' })),
      ...Array.from(document.querySelectorAll('[aria-haspopup="dialog"], [data-bs-toggle="modal"], [data-modal-trigger]')).slice(0, 3).map((el) => ({ el, kind: 'dialog-trigger' })),
    ];

    for (const candidate of candidates) {
      clickIfPossible(candidate.el, candidate.kind);
    }
    return results;
  });
}

async function collectDom(page) {
  return page.evaluate(() => {
    const all = Array.from(document.querySelectorAll('*'));
    const getCssPath = (el) => {
      if (!(el instanceof Element)) return '';
      const parts = [];
      let current = el;
      while (current && current.nodeType === Node.ELEMENT_NODE && parts.length < 8) {
        let part = current.tagName.toLowerCase();
        if (current.id) {
          part += `#${current.id}`;
          parts.unshift(part);
          break;
        }
        const cls = Array.from(current.classList || []).filter(Boolean).slice(0, 2);
        if (cls.length) {
          part += `.${cls.join('.')}`;
        }
        if (current.parentElement) {
          const sameTagSiblings = Array.from(current.parentElement.children).filter((child) => child.tagName === current.tagName);
          if (sameTagSiblings.length > 1) {
            const position = sameTagSiblings.indexOf(current) + 1;
            part += `:nth-of-type(${position})`;
          }
        }
        parts.unshift(part);
        current = current.parentElement;
      }
      return parts.join(' > ');
    };
    const isFocusable = (el) => {
      const ti = el.getAttribute('tabindex');
      if (ti && Number(ti) >= 0) return true;
      const tag = el.tagName.toLowerCase();
      return ['a', 'button', 'input', 'select', 'textarea', 'summary'].includes(tag) || el.getAttribute('role') === 'button';
    };
    return {
      title: document.title,
      count: all.length,
      interactiveCount: all.filter((el) => isFocusable(el)).length,
      elements: all.map((el, idx) => {
        const rect = el.getBoundingClientRect();
        return {
          idx: idx + 1,
          tag: el.tagName,
          id: el.id || '',
          role: el.getAttribute('role') || '',
          href: el.getAttribute('href') || '',
          alt: el.getAttribute('alt') || '',
          name: (el.getAttribute('aria-label') || el.getAttribute('title') || el.textContent || '').trim().slice(0, 120),
          focusable: isFocusable(el),
          width: Math.round(rect.width),
          height: Math.round(rect.height),
          x: Math.round(rect.left + window.scrollX),
          y: Math.round(rect.top + window.scrollY),
          viewportX: Math.round(rect.left),
          viewportY: Math.round(rect.top),
          cssPath: getCssPath(el),
        };
      }),
    };
  });
}

async function collectLocalization(page) {
  return page.evaluate(() => {
    const html = document.documentElement;
    const texts = Array.from(document.querySelectorAll('body *'))
      .map((el) => (el.innerText || el.textContent || '').trim())
      .filter(Boolean)
      .slice(0, 250);
    const localeChars = texts.filter((text) => /[^A-Za-z0-9\s.,:;!?'"()\-/_]/.test(text)).length;
    const asciiOnly = texts.filter((text) => /^[\x00-\x7F\s.,:;!?'"()\-/_]+$/.test(text)).length;
    return {
      lang: html.lang || '',
      dir: html.dir || '',
      localizedSampleCount: texts.length,
      containsLocaleSpecificText: localeChars > 0,
      asciiOnlyCount: asciiOnly,
    };
  });
}

async function collectFocusTrail(page, tabSteps) {
  const focusTrail = [];
  for (let step = 1; step <= tabSteps; step += 1) {
    await page.keyboard.press('Tab');
    const sample = await page.evaluate((currentStep) => {
      const el = document.activeElement;
      const style = el ? getComputedStyle(el) : null;
      return {
        step: currentStep,
        tag: el ? el.tagName : null,
        id: el ? el.id : null,
        name: (el && (el.getAttribute('aria-label') || el.textContent || '') || '').trim().slice(0, 80),
        outlineStyle: style ? style.outlineStyle : null,
        outlineWidth: style ? style.outlineWidth : null,
      };
    }, step);
    focusTrail.push(sample);
  }
  const uniqueFocusTargets = new Set(
    focusTrail
      .filter((item) => item && (item.tag || item.id || item.name))
      .map((item) => `${item.tag || ''}|${item.id || ''}|${item.name || ''}`)
  ).size;
  return { focusTrail, uniqueFocusTargets };
}

async function collectStructuredLists(page) {
  return page.evaluate(() => ({
    headings: Array.from(document.querySelectorAll('h1,h2,h3,h4,h5,h6')).map((h, i) => ({
      index: i + 1,
      level: Number(h.tagName.substring(1)),
      text: (h.textContent || '').trim().substring(0, 120),
    })),
    landmarks: Array.from(document.querySelectorAll('main,nav,aside,header,footer,section,[role="banner"],[role="main"],[role="navigation"],[role="contentinfo"],[role="region"]')).map((l, i) => ({
      index: i + 1,
      tag: l.tagName,
      role: l.getAttribute('role') || '',
      name: (l.getAttribute('aria-label') || l.textContent || '').trim().substring(0, 120),
    })),
    links: Array.from(document.querySelectorAll('a[href]')).map((a, i) => {
      const href = (a.getAttribute('href') || '').trim();
      return {
        index: i + 1,
        href,
        name: (a.getAttribute('aria-label') || a.textContent || '').trim().substring(0, 120),
        badHref: href === '' || href === '#' || href.toLowerCase().startsWith('javascript:'),
      };
    }),
    forms: Array.from(document.querySelectorAll('input,select,textarea,[role="textbox"],[role="combobox"],[role="checkbox"],[role="radio"]')).map((f, i) => ({
      index: i + 1,
      tag: f.tagName,
      type: f.getAttribute('type') || '',
      id: f.id || '',
      name: (f.getAttribute('aria-label') || f.getAttribute('title') || f.value || '').toString().trim().substring(0, 120),
    })),
    buttons: Array.from(document.querySelectorAll('button,[role="button"],input[type="button"],input[type="submit"]')).map((b, i) => ({
      index: i + 1,
      tag: b.tagName,
      id: b.id || '',
      name: (b.getAttribute('aria-label') || b.textContent || '').trim().substring(0, 120),
    })),
    graphics: Array.from(document.querySelectorAll('img,[role="img"]')).map((g, i) => {
      const alt = g.getAttribute('alt') || '';
      return {
        index: i + 1,
        tag: g.tagName,
        alt,
        missingAlt: g.tagName === 'IMG' && alt === '',
      };
    }),
  }));
}

async function collectAxe(page) {
  const axePath = require.resolve('axe-core/axe.min.js');
  const axeSource = fs.readFileSync(axePath, 'utf8');
  await page.addScriptTag({ content: axeSource });
  return page.evaluate(async () => {
    const result = await window.axe.run(document, {
      runOnly: {
        type: 'tag',
        values: ['wcag2a', 'wcag2aa', 'wcag21aa', 'wcag22aa', 'best-practice'],
      },
      resultTypes: ['violations', 'incomplete'],
    });
    const summarizeNode = (node) => ({
      target: node.target || [],
      html: (node.html || '').slice(0, 240),
      impact: node.impact || '',
      failureSummary: (node.failureSummary || '').slice(0, 400),
    });
    return {
      violationCount: (result.violations || []).length,
      incompleteCount: (result.incomplete || []).length,
      violations: (result.violations || []).map((violation) => ({
        id: violation.id,
        impact: violation.impact || '',
        help: violation.help || '',
        helpUrl: violation.helpUrl || '',
        description: violation.description || '',
        tags: violation.tags || [],
        nodes: (violation.nodes || []).slice(0, 12).map(summarizeNode),
      })),
      incomplete: (result.incomplete || []).map((violation) => ({
        id: violation.id,
        impact: violation.impact || '',
        help: violation.help || '',
        helpUrl: violation.helpUrl || '',
        description: violation.description || '',
        tags: violation.tags || [],
        nodes: (violation.nodes || []).slice(0, 8).map(summarizeNode),
      })),
    };
  });
}

async function collectCdpAccessibility(context, page) {
  const client = await context.newCDPSession(page);
  await client.send('Accessibility.enable');
  const fullTree = await client.send('Accessibility.getFullAXTree');
  const nodes = fullTree.nodes || [];
  const roleCounts = {};
  const sampleNodes = [];
  for (const node of nodes) {
    const role = node.role && node.role.value ? node.role.value : '';
    if (role) {
      roleCounts[role] = (roleCounts[role] || 0) + 1;
    }
    if (sampleNodes.length < 40) {
      sampleNodes.push({
        role,
        name: node.name && node.name.value ? String(node.name.value).slice(0, 160) : '',
        description: node.description && node.description.value ? String(node.description.value).slice(0, 160) : '',
        ignored: Boolean(node.ignored),
      });
    }
  }
  return {
    nodeCount: nodes.length,
    ignoredNodeCount: nodes.filter((node) => node.ignored).length,
    roleCounts,
    sampleNodes,
  };
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (!args.url) {
    throw new Error('--url is required');
  }
  if (!args.screenshot) {
    throw new Error('--screenshot is required');
  }
  const tabSteps = Number(args['tab-steps'] || '50');
  const keepPageOpen = String(args['keep-page-open'] || 'false').toLowerCase() === 'true';
  const screenshotPath = path.resolve(args.screenshot);
  fs.mkdirSync(path.dirname(screenshotPath), { recursive: true });

  const launchConfig = {
    viewport: { width: 1440, height: 900 },
    locale: 'en-US',
    ignoreHTTPSErrors: true,
  };

  let browser;
  let context;
  let page;
  let connectedOverCDP = false;
  let gotoResponse = null;

  if (args['cdp-url']) {
    connectedOverCDP = true;
    browser = await chromium.connectOverCDP(args['cdp-url']);
    context = browser.contexts()[0] || await browser.newContext();
    page = await context.newPage();
  } else {
    browser = await chromium.launch({ headless: true });
    if (args['storage-state']) {
      launchConfig.storageState = path.resolve(args['storage-state']);
    }
    context = await browser.newContext(launchConfig);
    page = await context.newPage();
  }

  function detectAccessBarrier(meta, dom, structured) {
    const title = (meta.title || '').trim();
    const bodyText = ((dom.elements || [])
      .filter((item) => item.tag === 'BODY' || item.tag === 'HTML' || item.tag === 'MAIN')
      .map((item) => item.name || '')
      .join(' ')
      .trim()
      .slice(0, 2500));
    const headings = (structured.headings || []).map((h) => (h.text || '').trim()).filter(Boolean);
    const combined = `${title}\n${headings.join('\n')}\n${bodyText}`.toLowerCase();
    const patterns = [
      { type: 'access_denied', label: 'Access denied surface', match: /(access denied|permission to access|errors\.edgesuite\.net)/ },
      { type: 'captcha_challenge', label: 'Captcha or challenge surface', match: /(captcha|verify you are human|challenge|robot check|cloudflare)/ },
      { type: 'login_wall', label: 'Authentication wall', match: /(sign in|login|log in|oturum aç|giriş yap)/ },
      { type: 'bot_mitigation', label: 'Bot mitigation page', match: /(akamai|bot manager|request blocked|temporarily unavailable)/ },
    ];
    const matched = patterns.find((entry) => entry.match.test(combined));
    return {
      detected: Boolean(matched),
      type: matched ? matched.type : '',
      label: matched ? matched.label : '',
      title,
      headings,
      signals: matched ? [
        matched.label,
        title || 'no-title',
        headings[0] || 'no-heading',
      ] : [],
      excerpt: bodyText,
    };
  }

  try {
    gotoResponse = await page.goto(args.url, { waitUntil: 'domcontentloaded', timeout: 60000 });
    await page.waitForTimeout(1200);

    const cookieDialog = await collectCookieState(page);
    await page.waitForTimeout(300);
    const scrollCoverage = await collectScrollCoverage(page);
    const statefulCoverage = await collectStatefulCoverage(page);
    await page.waitForTimeout(300);
    await page.screenshot({ path: screenshotPath, fullPage: true });

    const meta = {
      url: page.url(),
      title: await page.title(),
      status: gotoResponse ? gotoResponse.status() : null,
      statusText: gotoResponse ? gotoResponse.statusText() : '',
      acquisitionMode: args['cdp-url'] ? 'cdp' : (args['storage-state'] ? 'storage-state' : 'fresh-context'),
    };
    const dom = await collectDom(page);
    const localization = await collectLocalization(page);
    const { focusTrail, uniqueFocusTargets } = await collectFocusTrail(page, tabSteps);
    const structured = await collectStructuredLists(page);
    const axe = await collectAxe(page);
    const cdpAccessibility = await collectCdpAccessibility(context, page);
    const accessBarrier = detectAccessBarrier(meta, dom, structured);

    const result = {
      meta,
      screenshot: screenshotPath,
      accessBarrier,
      cookieDialog,
      scrollCoverage,
      statefulCoverage,
      dom,
      axe,
      cdpAccessibility,
      localization,
      focusTrail,
      uniqueFocusTargets,
      headings: structured.headings,
      landmarks: structured.landmarks,
      links: structured.links,
      formFields: structured.forms,
      buttons: structured.buttons,
      graphics: structured.graphics,
    };

    process.stdout.write(JSON.stringify(result));
  } finally {
    if (!keepPageOpen) {
      await page.close().catch(() => {});
    }
    if (!connectedOverCDP) {
      await context.close().catch(() => {});
    }
    await browser.close().catch(() => {});
  }
}

main().catch((error) => {
  console.error(error.stack || error.message || String(error));
  process.exit(1);
});
