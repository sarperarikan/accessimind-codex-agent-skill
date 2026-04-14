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

function normalizeUrl(rawUrl, baseUrl) {
  try {
    const parsed = baseUrl ? new URL(rawUrl, baseUrl) : new URL(rawUrl);
    parsed.hash = '';
    if ((parsed.protocol !== 'http:') && (parsed.protocol !== 'https:')) {
      return null;
    }
    const normalizedPath = parsed.pathname.replace(/\/{2,}/g, '/');
    parsed.pathname = normalizedPath === '' ? '/' : normalizedPath;
    if (parsed.pathname.length > 1 && parsed.pathname.endsWith('/')) {
      parsed.pathname = parsed.pathname.slice(0, -1);
    }
    return parsed.toString();
  } catch (_) {
    return null;
  }
}

function extractLinks(html, baseUrl) {
  const hrefPattern = /\bhref\s*=\s*(?:"([^"]+)"|'([^']+)'|([^\s>]+))/gi;
  const links = [];
  let match;
  while ((match = hrefPattern.exec(html)) !== null) {
    const candidate = match[1] || match[2] || match[3] || '';
    if (!candidate) {
      continue;
    }
    if (/^(mailto:|tel:|javascript:|data:)/i.test(candidate)) {
      continue;
    }
    const normalized = normalizeUrl(candidate, baseUrl);
    if (normalized) {
      links.push(normalized);
    }
  }
  return links;
}

async function fetchHtml(url) {
  const response = await fetch(url, {
    redirect: 'follow',
    headers: {
      'user-agent': 'AccessiMind-OpenClaw-Discovery/1.0',
      'accept': 'text/html,application/xhtml+xml',
    },
  });
  if (!response.ok) {
    throw new Error(`HTTP ${response.status} for ${url}`);
  }
  const contentType = response.headers.get('content-type') || '';
  if (!contentType.toLowerCase().includes('text/html')) {
    throw new Error(`Non-HTML content for ${url}: ${contentType}`);
  }
  return {
    finalUrl: response.url,
    html: await response.text(),
  };
}

function dedupe(items) {
  return Array.from(new Set(items));
}

async function discover(rootUrl, maxPages) {
  const normalizedRoot = normalizeUrl(rootUrl);
  if (!normalizedRoot) {
    throw new Error(`Invalid root URL: ${rootUrl}`);
  }

  const rootHost = new URL(normalizedRoot).host;
  const queue = [normalizedRoot];
  const visited = new Set();
  const pages = [];
  const blocked = [];

  while (queue.length > 0 && pages.length < maxPages) {
    const current = queue.shift();
    if (!current || visited.has(current)) {
      continue;
    }
    visited.add(current);

    try {
      const payload = await fetchHtml(current);
      const currentUrl = normalizeUrl(payload.finalUrl) || current;
      const currentHost = new URL(currentUrl).host;
      if (currentHost !== rootHost) {
        continue;
      }

      const titleMatch = payload.html.match(/<title[^>]*>([\s\S]*?)<\/title>/i);
      const title = titleMatch ? titleMatch[1].replace(/\s+/g, ' ').trim() : '';
      const links = extractLinks(payload.html, currentUrl)
        .filter((item) => new URL(item).host === rootHost);

      const pageRecord = {
        url: currentUrl,
        title,
        discoveredLinks: dedupe(links).slice(0, 50),
      };
      pages.push(pageRecord);

      for (const link of pageRecord.discoveredLinks) {
        if (!visited.has(link) && !queue.includes(link) && pages.length + queue.length < maxPages * 4) {
          queue.push(link);
        }
      }
    } catch (error) {
      blocked.push({
        url: current,
        reason: error.message,
      });
    }
  }

  return {
    rootUrl: normalizedRoot,
    discoveredAt: new Date().toISOString(),
    maxPages,
    pages,
    blocked,
  };
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  const rootUrl = args.url || process.argv[2];
  const maxPages = Number.parseInt(args['max-pages'] || process.argv[3] || '3', 10);
  const output = args.output ? path.resolve(args.output) : '';

  if (!rootUrl) {
    throw new Error('Usage: node scripts/accessmind_discover.cjs --url https://example.com --max-pages 3 [--output reports/discovery.json]');
  }
  if (!Number.isFinite(maxPages) || maxPages <= 0) {
    throw new Error(`Invalid max pages value: ${maxPages}`);
  }

  const result = await discover(rootUrl, maxPages);
  const serialized = JSON.stringify(result, null, 2);

  if (output) {
    fs.mkdirSync(path.dirname(output), { recursive: true });
    fs.writeFileSync(output, serialized, 'utf8');
  }

  process.stdout.write(serialized);
}

main().catch((error) => {
  console.error(error.message || error);
  process.exit(1);
});
