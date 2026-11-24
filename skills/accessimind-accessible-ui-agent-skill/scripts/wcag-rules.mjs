import { readFileSync } from 'node:fs';

const profiles = {
  122: { version: 'v2.2.20.00', count: 122, lastPage: 14, gates: 47, reverse: [95] },
  126: { version: 'V2.2.30.01', count: 126, lastPage: 61, gates: 59, reverse: [52, 81, 106] },
};

function readCatalog(name) {
  const file = new URL(`../references/${name}.tsv`, import.meta.url);
  const [header, ...lines] = readFileSync(file, 'utf8').trim().split(/\r?\n/);
  const fields = header.split('\t');
  return lines.map((line, index) => {
    const values = line.split('\t');
    if (values.length !== fields.length) {
      throw new Error(`${name} line ${index + 2} has ${values.length} fields, expected ${fields.length}`);
    }
    return Object.fromEntries(fields.map((field, i) => [field, values[i]]));
  });
}

function requireRule(condition, message) {
  if (!condition) throw new Error(message);
}

function validate(criteria, editions) {
  const counts = { A: 31, AA: 24, AAA: 31 };
  const validIds = new Set(criteria.map(({ id }) => id));
  const validAnchors = new Set(criteria.map(({ anchor }) => anchor));
  requireRule(criteria.length === 86 && validIds.size === 86 && validAnchors.size === 86,
    'Expected 86 unique active WCAG 2.2 criteria and anchors.');
  requireRule(!validIds.has('4.1.1'), 'The retired Parsing criterion cannot be active.');
  const methods = new Set(['semantics', 'visual', 'content', 'speech', 'task', 'media', 'keyboard', 'pointer']);
  for (const { id, level, anchor, evidence, name } of criteria) {
    requireRule(/^\d+\.\d+\.\d+$/.test(id) && level in counts && anchor && name &&
      evidence && evidence.split(',').every((method) => methods.has(method)), `Invalid WCAG row ${id}.`);
  }
  for (const [level, count] of Object.entries(counts)) {
    requireRule(criteria.filter((criterion) => criterion.level === level).length === count,
      `Unexpected count at WCAG level ${level}.`);
  }

  const levelA = criteria.filter((criterion) => criterion.level === 'A').map(({ id }) => id);
  for (const [edition, rows] of Object.entries(editions)) {
    const { count, lastPage, gates, reverse } = profiles[edition];
    requireRule(rows.length === count, `Expected ${count} questions in edition ${edition}.`);
    requireRule(rows.filter((row) => row.type === 'gate').length === gates,
      `Unexpected number of applicability questions in edition ${edition}.`);
    const actualReverse = rows.filter((row) => row.type === 'check-no').map((row) => Number(row.question));
    requireRule(actualReverse.join() === reverse.join(), `Unexpected reverse polarity in edition ${edition}.`);
    rows.forEach((row, index) => {
      const question = index + 1;
      const label = `Edition ${edition} question ${question}`;
      requireRule(row.question === String(question), `${label} is absent or out of order.`);
      requireRule(levelA[Number(row.ministry_criterion) - 1] === row.wcag,
        `${label} maps outside its WCAG A grouping.`);
      requireRule(Number(row.pdf_page) >= 1 && Number(row.pdf_page) <= lastPage,
        `${label} has an invalid physical PDF page.`);
      requireRule(['gate', 'check-yes', 'check-no'].includes(row.type) && row.test_topic,
        `${label} needs a type and test topic.`);
      for (const branch of [row.on_yes, row.on_no, row.on_exception]) {
        requireRule(!branch || branch === 'end' || (/^\d+$/.test(branch) &&
          Number(branch) > question && Number(branch) <= count), `${label} has an invalid branch.`);
      }
    });
    requireRule(new Set(rows.map(({ wcag }) => wcag)).size === levelA.length,
      `Edition ${edition} must cover all 31 WCAG A criteria.`);
  }
}

function run(args) {
  const criteria = readCatalog('wcag-2-2-catalog');
  const editions = Object.fromEntries(
    Object.keys(profiles).map((edition) => [edition, readCatalog(`turkey-ashb-${edition}`)]),
  );
  validate(criteria, editions);

  const [selector, question, ...extra] = args;
  if (selector === '--validate' && question === undefined) {
    return { activeWCAGCriteria: criteria.length, checklistQuestions: { 122: editions[122].length, 126: editions[126].length } };
  }
  if (Object.hasOwn(profiles, selector) && question && extra.length === 0) {
    const row = editions[selector].find((entry) => entry.question === question);
    requireRule(row, `Unknown question ${question} in edition ${selector}.`);
    return { version: profiles[selector].version, ...row };
  }
  if (selector && question === undefined) {
    const criterion = criteria.find(({ id }) => id === selector);
    requireRule(criterion, `Unknown WCAG 2.2 criterion ${selector}.`);
    const ministry = Object.fromEntries(Object.entries(editions).map(([edition, rows]) => [
      profiles[edition].version, rows.filter(({ wcag }) => wcag === selector),
    ]));
    return { ...criterion, url: `https://www.w3.org/TR/WCAG22/#${criterion.anchor}`, ministry };
  }
  throw new Error('Usage: node scripts/wcag-rules.mjs --validate | <WCAG ID> | <122|126> <question>');
}

try {
  console.log(JSON.stringify(run(process.argv.slice(2)), null, 2));
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
}
