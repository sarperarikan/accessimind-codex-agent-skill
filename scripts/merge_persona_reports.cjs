const fs = require('fs');
const path = require('path');

function parseArgs(argv) {
  const args = {};
  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (!token.startsWith('--')) {
      continue;
    }
    const key = token.slice(2);
    const next = argv[i + 1];
    if (!next || next.startsWith('--')) {
      args[key] = 'true';
      continue;
    }
    args[key] = next;
    i += 1;
  }
  return args;
}

function readJsonIfPresent(filePath) {
  if (!filePath) {
    return null;
  }
  const resolved = path.resolve(filePath);
  if (!fs.existsSync(resolved)) {
    return null;
  }
  return JSON.parse(fs.readFileSync(resolved, 'utf8'));
}

function computeSeverityCounts(pages) {
  const counters = { high: 0, medium: 0, low: 0, info: 0, unknown: 0 };
  for (const page of pages) {
    for (const finding of page.findings || []) {
      const key = (finding.severity || '').toLowerCase();
      if (Object.prototype.hasOwnProperty.call(counters, key)) {
        counters[key] += 1;
      } else {
        counters.unknown += 1;
      }
    }
  }
  return counters;
}

function buildMarkdown(summary, discovery, nvdaWorker) {
  const pageLines = (summary.pages || []).map((page) => {
    const findings = Array.isArray(page.findings) ? page.findings.length : 0;
    return `- ${page.url} | coverage=${page.coverageStatus || 'unknown'} | findings=${findings} | elements=${page.elementCount || 0}`;
  });

  const severity = computeSeverityCounts(summary.pages || []);
  const discoveryInfo = discovery
    ? `- Discovery source: same-domain crawl\n- Requested pages: ${discovery.maxPages}\n- Crawled pages: ${(discovery.pages || []).length}\n- Blocked pages: ${(discovery.blocked || []).length}`
    : '- Discovery source: explicit URL list';

  const nvdaInfo = nvdaWorker
    ? `- Windows NVDA worker: connected\n- Session count: ${nvdaWorker.sessionCount || 0}\n- Last sync: ${nvdaWorker.syncedAt || 'unknown'}`
    : '- Windows NVDA worker: not attached';

  return [
    '# OpenClaw Accessibility Audit Summary',
    '',
    `- Project: ${summary.projectName || 'unknown'}`,
    `- Created at: ${summary.createdAt || 'unknown'}`,
    `- Output directory: ${summary.outputDir || 'unknown'}`,
    '',
    '## Coverage',
    discoveryInfo,
    nvdaInfo,
    `- Audited pages: ${(summary.pages || []).length}`,
    '',
    '## Severity Totals',
    `- High: ${severity.high}`,
    `- Medium: ${severity.medium}`,
    `- Low: ${severity.low}`,
    `- Info: ${severity.info}`,
    `- Unknown: ${severity.unknown}`,
    '',
    '## Audited Pages',
    ...pageLines,
    '',
    '## Persona Defaults',
    '- Browser-first audit uses rendered DOM, interactive traversal, focus evidence, and screenshots.',
    '- Blind persona output should prefer real NVDA worker evidence when available; otherwise the local runtime evidence remains heuristic.',
    '- Findings should be converted into remediation actions for Dev, BA, and PO handoff.',
    '',
  ].join('\n');
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const summaryPath = args.summary;
  const outputMd = args['output-md'];
  const outputJson = args['output-json'];

  if (!summaryPath || !outputMd || !outputJson) {
    throw new Error('Usage: node scripts/merge_persona_reports.cjs --summary reports/summary.json --output-md reports/openclaw-summary.md --output-json reports/openclaw-summary.json [--discovery reports/discovery.json] [--nvda-worker reports/windows-nvda.json]');
  }

  const summary = readJsonIfPresent(summaryPath);
  if (!summary) {
    throw new Error(`Summary JSON not found: ${summaryPath}`);
  }
  const discovery = readJsonIfPresent(args.discovery);
  const nvdaWorker = readJsonIfPresent(args['nvda-worker']);

  const merged = {
    projectName: summary.projectName || 'unknown',
    createdAt: new Date().toISOString(),
    sourceSummary: path.resolve(summaryPath),
    outputDir: summary.outputDir || path.dirname(path.resolve(outputMd)),
    pageCount: Array.isArray(summary.pages) ? summary.pages.length : 0,
    severityTotals: computeSeverityCounts(summary.pages || []),
    discovery,
    nvdaWorker,
  };

  const markdown = buildMarkdown(summary, discovery, nvdaWorker);
  fs.mkdirSync(path.dirname(path.resolve(outputMd)), { recursive: true });
  fs.writeFileSync(path.resolve(outputMd), markdown, 'utf8');
  fs.writeFileSync(path.resolve(outputJson), JSON.stringify(merged, null, 2), 'utf8');

  process.stdout.write(JSON.stringify(merged, null, 2));
}

try {
  main();
} catch (error) {
  console.error(error.message || error);
  process.exit(1);
}
