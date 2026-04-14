const fs = require('fs');
const path = require('path');
const CDP = require('chrome-remote-interface');

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

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function getCdpOptions(cdpUrl) {
  const parsed = new URL(cdpUrl);
  return {
    host: parsed.hostname,
    port: Number(parsed.port || 9222),
    secure: parsed.protocol === 'https:',
  };
}

async function waitForLoad(Page) {
  await new Promise((resolve) => {
    let done = false;
    const finish = () => {
      if (!done) {
        done = true;
        resolve();
      }
    };
    Page.loadEventFired(finish);
    setTimeout(finish, 15000);
  });
}

async function evaluate(Runtime, expression, returnByValue = true) {
  const result = await Runtime.evaluate({
    expression,
    returnByValue,
    awaitPromise: true,
  });
  if (result.exceptionDetails) {
    throw new Error(result.exceptionDetails.text || 'Runtime.evaluate failed.');
  }
  return returnByValue ? result.result.value : result.result;
}

async function collectByEval(Runtime, jsExpression) {
  return evaluate(Runtime, `(${jsExpression})()`);
}

async function collectScrollCoverage(Runtime) {
  const checkpoints = [0, 20, 40, 60, 80, 100];
  const results = [];
  for (const checkpoint of checkpoints) {
    const sample = await evaluate(
      Runtime,
      `(() => {
        const doc = document.documentElement;
        const max = Math.max(0, doc.scrollHeight - window.innerHeight);
        const y = Math.round(max * (${checkpoint} / 100));
        window.scrollTo(0, y);
        return {
          checkpoint: ${checkpoint},
          scrollY: window.scrollY,
          scrollHeight: doc.scrollHeight,
          viewportHeight: window.innerHeight
        };
      })()`
    );
    results.push(sample);
    await sleep(200);
  }
  await evaluate(Runtime, '(() => { window.scrollTo(0, 0); return true; })()');
  return results;
}

async function collectCookieState(Runtime) {
  return evaluate(
    Runtime,
    `(() => {
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
    })()`
  );
}

async function collectStatefulCoverage(Runtime) {
  return evaluate(
    Runtime,
    `(() => {
      const results = [];
      const seen = new Set();
      const pushResult = (el, kind) => {
        const key = \`\${kind}|\${el.tagName}|\${el.id || ''}|\${(el.getAttribute('aria-label') || el.textContent || '').trim().slice(0, 80)}\`;
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
    })()`
  );
}

async function collectDom(Runtime) {
  return evaluate(
    Runtime,
    `(() => {
      const all = Array.from(document.querySelectorAll('*'));
      const getCssPath = (el) => {
        if (!(el instanceof Element)) return '';
        const parts = [];
        let current = el;
        while (current && current.nodeType === Node.ELEMENT_NODE && parts.length < 8) {
          let part = current.tagName.toLowerCase();
          if (current.id) {
            part += \`#\${current.id}\`;
            parts.unshift(part);
            break;
          }
          const cls = Array.from(current.classList || []).filter(Boolean).slice(0, 2);
          if (cls.length) {
            part += \`.\${cls.join('.')}\`;
          }
          if (current.parentElement) {
            const sameTagSiblings = Array.from(current.parentElement.children).filter((child) => child.tagName === current.tagName);
            if (sameTagSiblings.length > 1) {
              const position = sameTagSiblings.indexOf(current) + 1;
              part += \`:nth-of-type(\${position})\`;
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
    })()`
  );
}

async function collectLocalization(Runtime) {
  return evaluate(
    Runtime,
    `(() => {
      const html = document.documentElement;
      const texts = Array.from(document.querySelectorAll('body *'))
        .map((el) => (el.innerText || el.textContent || '').trim())
        .filter(Boolean)
        .slice(0, 250);
      const localeChars = texts.filter((text) => /[^A-Za-z0-9\\s.,:;!?'\"()\\-/_]/.test(text)).length;
      const asciiOnly = texts.filter((text) => /^[\\x00-\\x7F\\s.,:;!?'\"()\\-/_]+$/.test(text)).length;
      return {
        lang: html.lang || '',
        dir: html.dir || '',
        localizedSampleCount: texts.length,
        containsLocaleSpecificText: localeChars > 0,
        asciiOnlyCount: asciiOnly,
      };
    })()`
  );
}

async function dispatchTab(Input) {
  await Input.dispatchKeyEvent({ type: 'rawKeyDown', windowsVirtualKeyCode: 9, nativeVirtualKeyCode: 9, code: 'Tab', key: 'Tab' });
  await Input.dispatchKeyEvent({ type: 'keyUp', windowsVirtualKeyCode: 9, nativeVirtualKeyCode: 9, code: 'Tab', key: 'Tab' });
}

async function collectFocusTrail(Runtime, Input, tabSteps) {
  const focusTrail = [];
  for (let step = 1; step <= tabSteps; step += 1) {
    await dispatchTab(Input);
    await sleep(120);
    const sample = await evaluate(
      Runtime,
      `(() => {
        const el = document.activeElement;
        const style = el ? getComputedStyle(el) : null;
        return {
          step: ${step},
          tag: el ? el.tagName : null,
          id: el ? el.id : null,
          name: (el && (el.getAttribute('aria-label') || el.textContent || '') || '').trim().slice(0, 80),
          outlineStyle: style ? style.outlineStyle : null,
          outlineWidth: style ? style.outlineWidth : null,
        };
      })()`
    );
    focusTrail.push(sample);
  }
  const uniqueFocusTargets = new Set(
    focusTrail.filter((item) => item && (item.tag || item.id || item.name)).map((item) => `${item.tag || ''}|${item.id || ''}|${item.name || ''}`)
  ).size;
  return { focusTrail, uniqueFocusTargets };
}

async function collectStructuredLists(Runtime) {
  return evaluate(
    Runtime,
    `(() => ({
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
    }))()`
  );
}

async function collectAxe(Runtime) {
  const axePath = require.resolve('axe-core/axe.min.js');
  const axeSource = fs.readFileSync(axePath, 'utf8');
  await Runtime.evaluate({ expression: axeSource, awaitPromise: true });
  return evaluate(
    Runtime,
    `(() => axe.run(document, {
      runOnly: { type: 'tag', values: ['wcag2a', 'wcag2aa', 'wcag21aa', 'wcag22aa', 'best-practice'] },
      resultTypes: ['violations', 'incomplete']
    }).then((result) => {
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
    }))()`
  );
}

async function collectVisionEvidence(Runtime) {
  return evaluate(
    Runtime,
    `(() => {
      const focusables = Array.from(document.querySelectorAll('a,button,input,select,textarea,[role="button"],[tabindex]'));
      const smallTargets = focusables.filter((el) => {
        const rect = el.getBoundingClientRect();
        return rect.width > 0 && rect.height > 0 && (rect.width < 44 || rect.height < 44);
      }).length;
      const offscreenFocusables = focusables.filter((el) => {
        const rect = el.getBoundingClientRect();
        return rect.width > 0 && rect.height > 0 && (rect.bottom < 0 || rect.right < 0);
      }).length;
      const lowOutline = focusables.filter((el) => {
        const style = getComputedStyle(el);
        return style.outlineStyle === 'none' || style.outlineWidth === '0px';
      }).length;
      return {
        screenshotRequired: true,
        cropEvidenceRequired: true,
        smallTargetCandidates: smallTargets,
        offscreenFocusableCandidates: offscreenFocusables,
        noVisibleOutlineCandidates: lowOutline,
      };
    })()`
  );
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
    signals: matched ? [matched.label, title || 'no-title', headings[0] || 'no-heading'] : [],
    excerpt: bodyText,
  };
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (!args.url) throw new Error('--url is required');
  if (!args.screenshot) throw new Error('--screenshot is required');
  if (!args['cdp-url']) throw new Error('--cdp-url is required for CDP-native collector');

  const tabSteps = Number(args['tab-steps'] || '50');
  const screenshotPath = path.resolve(args.screenshot);
  fs.mkdirSync(path.dirname(screenshotPath), { recursive: true });

  let browser;
  let client;
  try {
    browser = await CDP(getCdpOptions(args['cdp-url']));
    const { Target } = browser;
    const createResult = await Target.createTarget({ url: args.url, newWindow: false, background: false });
    const targetId = createResult.targetId;
    client = await CDP({ ...getCdpOptions(args['cdp-url']), target: targetId });
    const { Page, Runtime, DOMSnapshot, Accessibility, Input } = client;

    await Promise.all([Page.enable(), Runtime.enable(), DOMSnapshot.enable(), Accessibility.enable()]);
    await Target.activateTarget({ targetId });
    await Page.bringToFront();
    await Page.navigate({ url: args.url });
    await waitForLoad(Page);
    await sleep(1200);

    const cookieDialog = await collectCookieState(Runtime);
    await sleep(300);
    const scrollCoverage = await collectScrollCoverage(Runtime);
    const statefulCoverage = await collectStatefulCoverage(Runtime);
    await sleep(300);

    const layoutMetrics = await Page.getLayoutMetrics();
    const contentSize = layoutMetrics.contentSize || { width: 1440, height: 900 };
    const screenshot = await Page.captureScreenshot({
      format: 'png',
      captureBeyondViewport: true,
      clip: {
        x: 0,
        y: 0,
        width: Math.max(1, Math.ceil(contentSize.width)),
        height: Math.max(1, Math.ceil(contentSize.height)),
        scale: 1,
      },
    });
    fs.writeFileSync(screenshotPath, screenshot.data, 'base64');

    const meta = await evaluate(
      Runtime,
      `(() => ({
        url: location.href,
        title: document.title,
        status: 200,
        statusText: '',
        acquisitionMode: 'cdp-native'
      }))()`
    );
    const dom = await collectDom(Runtime);
    const localization = await collectLocalization(Runtime);
    const { focusTrail, uniqueFocusTargets } = await collectFocusTrail(Runtime, Input, tabSteps);
    const structured = await collectStructuredLists(Runtime);
    const axe = await collectAxe(Runtime);
    const cdpAccessibility = await (async () => {
      const fullTree = await Accessibility.getFullAXTree();
      const nodes = fullTree.nodes || [];
      const roleCounts = {};
      const sampleNodes = [];
      for (const node of nodes) {
        const role = node.role && node.role.value ? node.role.value : '';
        if (role) roleCounts[role] = (roleCounts[role] || 0) + 1;
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
    })();
    const vision = await collectVisionEvidence(Runtime);
    const accessBarrier = detectAccessBarrier(meta, dom, structured);
    const domSnapshot = await DOMSnapshot.captureSnapshot({
      computedStyles: ['display', 'visibility', 'outline-style', 'outline-width'],
      includeDOMRects: true,
      includePaintOrder: true,
    });

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
      vision,
      domSnapshotSummary: {
        documentCount: (domSnapshot.documents || []).length,
        stringCount: (domSnapshot.strings || []).length,
      },
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
    if (client) {
      await client.close().catch(() => {});
    }
    if (browser) {
      await browser.close().catch(() => {});
    }
  }
}

main().catch((error) => {
  console.error(error.stack || error.message || String(error));
  process.exit(1);
});
