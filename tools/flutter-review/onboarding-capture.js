// Screen 30 (onboarding) captures: node tools/flutter-review/onboarding-capture.js <outdir> [names]
// Web build on :8765. Desktop 1844x853 (dpr 1, reference size) and phone 915x412 (dpr 2.625).
const { chromium } = require('playwright');
(async () => {
  const d = process.argv[2];
  const all = {};
  for (const s of ['a', 'b', 'c']) {
    all[`${s}-dark`] = [`onboarding=1&step=${s}`, 1844, 853, 1];
    all[`${s}-light`] = [`onboarding=1&step=${s}&theme=light`, 1844, 853, 1];
    all[`${s}-phone-dark`] = [`onboarding=1&step=${s}`, 915, 412, 2.625];
    all[`${s}-phone-light`] = [`onboarding=1&step=${s}&theme=light`, 915, 412, 2.625];
  }
  for (const e of ['none', 'green', 'dark']) {
    all[`emblem-${e}`] = [`onboarding=1&theme=light&emblemL=${e}`, 1844, 853, 1];
  }
  all['a-phone-text110'] = ['onboarding=1&textScale=1.1', 915, 412, 2.625];
  const pick = process.argv[3] ? process.argv[3].split(',') : Object.keys(all);
  const b = await chromium.launch();
  for (const name of pick) {
    const [q, w, h, dpr] = all[name];
    const p = await b.newPage({ viewport: { width: w, height: h }, deviceScaleFactor: dpr });
    await p.goto(`http://localhost:8765/?${q}`, { waitUntil: 'networkidle' });
    await p.waitForTimeout(7000);
    await p.screenshot({ path: `${d}/${name}.png` });
    await p.close();
  }
  await b.close();
})();
