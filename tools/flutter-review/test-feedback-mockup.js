// Renders the screen 10 feedback proposals (test-feedback-mockup.html) to <outdir>/feedback-{a,b}-{ok,ko}.png
const { chromium } = require('playwright');
const path = require('path');
const out = process.argv[2];
(async () => {
  const b = await chromium.launch();
  const p = await b.newPage({ viewport: { width: 1842, height: 854 } });
  const url = 'file://' + path.resolve(__dirname, 'test-feedback-mockup.html');
  for (const v of ['a', 'b']) for (const r of ['ok', 'ko']) {
    await p.goto(`${url}?v=${v}&r=${r}`);
    await p.waitForTimeout(500);
    await p.screenshot({ path: `${out}/feedback-${v}-${r}.png` });
  }
  await b.close();
})();
