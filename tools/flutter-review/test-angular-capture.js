// Captures the Angular original of the test lesson (screen 10): question, selection, feedback, completion, results.
// Needs `npx ng serve --port 4300`. Usage: node test-angular-capture.js <outdir> [w h]
const { chromium } = require('playwright');
const data = require('../../src/assets/data/content/assessments/assessment-lesson-1.json');
// Even steps answer right (to capture the correct feedback), odd steps wrong.
const correctTexts = (qText) => {
  const q = data.questions.find((x) => qText.includes(x.text.slice(0, 12)));
  if (!q || !q.options) return [];
  const c = Array.isArray(q.correctAnswer) ? q.correctAnswer : [q.correctAnswer];
  return q.options.filter((o) => c.includes(o.id)).map((o) => o.text);
};
const out = process.argv[2];
const W = +(process.argv[3] || 1844), H = +(process.argv[4] || 853);
(async () => {
  const b = await chromium.launch();
  const p = await b.newPage({ viewport: { width: W, height: H } });
  p.on('console', (m) => { if (m.type() === 'error') console.log('ERR', m.text().slice(0, 150)); });
  await p.goto('http://localhost:4300/courses/01-tajweed-fundamentals/units/assessment-fundamentals/lessons/assessment-lesson-1');
  await p.waitForTimeout(4000);
  let n = 0;
  const shot = async (name) => { await p.screenshot({ path: `${out}/${String(++n).padStart(2, '0')}-${name}.png` }); };
  await shot('question');
  const keep = (q) => q < 4 || q === 5 || q === 7;
  for (let q = 0; q < 10; q++) {
    const opts = await p.$$('.option-item');
    const tf = await p.$$('.true-false-buttons button');
    const input = await p.$('.text-answer-input');
    const qText = (await p.textContent('.question-text')) || '';
    const right = correctTexts(qText);
    if (opts.length) {
      for (const o of opts) {
        const t = ((await o.textContent()) || '').trim();
        const isRight = right.some((r) => t.includes(r));
        if ((q % 2 === 0) === isRight) { await o.click(); if (q % 2) break; }
      }
    }
    else if (tf.length) await tf[0].click();
    else if (input) await input.fill('من يعمل');
    await p.waitForTimeout(400);
    if (keep(q)) await shot(`q${q + 1}-selected`);
    await p.click('.submit-button', { timeout: 3000 }).catch(() => console.log('no submit', q));
    await p.waitForTimeout(1200);
    if (keep(q)) await shot(`q${q + 1}-feedback`);
    await p.click('.dismiss-feedback', { timeout: 3000 }).catch(() => {});
    await p.waitForTimeout(600);
    if (q < 2) await shot(`q${q + 1}-after`);
    const next = await p.$('.next-button');
    const fin = await p.$('.finish-button');
    if (next) await next.click(); else if (fin) { await fin.click(); break; }
    await p.waitForTimeout(700);
  }
  await p.waitForTimeout(1500); await shot('completion');
  await p.waitForTimeout(9000); await shot('results');
  const r = await p.$('.question-result-item');
  if (r) { await r.click(); await p.waitForTimeout(900); await shot('details'); }
  await b.close();
})();
